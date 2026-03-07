import 'package:injectable/injectable.dart';

import '../../../../core/utils/either.dart';
import '../failures/dashboard_failure.dart';
import '../repositories/dashboard_repository.dart';
import '../value_objects/user_role.dart';
import 'get_student_dashboard_usecase.dart'; // For DateRangeFilter

/// Use case for advanced dashboard analytics and insights
///
/// This use case handles complex analytics operations including
/// trend analysis, comparative statistics, predictive insights,
/// and cross-role analytics for administrative purposes.
@injectable
class DashboardAnalyticsUseCase {
  final DashboardRepository _repository;

  const DashboardAnalyticsUseCase(this._repository);

  /// Get comprehensive analytics for a user
  ///
  /// [userId] - The ID of the user to analyze
  /// [role] - The role of the user (student or tutor)
  /// [analysisDepth] - Depth of analysis (basic, detailed, comprehensive)
  ///
  /// Returns analytics data or [DashboardFailure] if operation fails
  Future<Either<DashboardFailure, DashboardAnalytics>> getAnalytics(
    String userId,
    UserRole role, {
    AnalysisDepth analysisDepth = AnalysisDepth.detailed,
    DateRangeFilter? dateRange,
  }) async {
    // Validate input parameters
    final validationResult = _validateInput(userId, role);
    if (validationResult != null) {
      return Left(validationResult);
    }

    try {
      // Check dashboard access permissions
      final accessResult = await _repository.validateDashboardAccess(
        userId,
        role,
      );

      return await accessResult.fold((failure) => Left(failure), (
        hasAccess,
      ) async {
        if (!hasAccess) {
          return const Left(
            DashboardFailure.permissionDenied(
              'User does not have analytics access rights',
            ),
          );
        }

        // Gather analytics data based on depth
        final analyticsData = await _gatherAnalyticsData(
          userId,
          role,
          analysisDepth,
          dateRange,
        );

        return analyticsData.fold(
          (failure) => Left(failure),
          (analytics) => Right(analytics),
        );
      });
    } catch (e) {
      return Left(
        DashboardFailure.serverError(
          'Failed to get analytics: ${e.toString()}',
        ),
      );
    }
  }

  /// Get trend analysis for a user
  ///
  /// [userId] - The ID of the user to analyze trends for
  /// [role] - The role of the user (student or tutor)
  /// [startDate] - Start date for trend analysis
  /// [endDate] - End date for trend analysis
  /// [interval] - Time interval for data points (daily, weekly, monthly)
  ///
  /// Returns trend data or [DashboardFailure] if operation fails
  Future<Either<DashboardFailure, TrendAnalysis>> getTrendAnalysis(
    String userId,
    UserRole role,
    DateTime startDate,
    DateTime endDate, {
    String interval = 'weekly',
  }) async {
    // Validate input
    final validationResult = _validateInput(userId, role);
    if (validationResult != null) {
      return Left(validationResult);
    }

    final dateRange = DateRangeFilter(startDate, endDate);
    final dateValidation = _validateDateRange(dateRange);
    if (dateValidation != null) {
      return Left(dateValidation);
    }

    if (!['daily', 'weekly', 'monthly'].contains(interval)) {
      return const Left(
        DashboardFailure.validationError(
          'Interval must be daily, weekly, or monthly',
        ),
      );
    }

    try {
      // Get trend data from repository
      final trendsResult = await _repository.getDashboardTrends(
        userId,
        role,
        startDate,
        endDate,
        interval,
      );

      return trendsResult.fold((failure) => Left(failure), (trendsData) {
        final analysis = _analyzeTrends(trendsData, interval);
        return Right(analysis);
      });
    } catch (e) {
      return Left(
        DashboardFailure.serverError(
          'Failed to get trend analysis: ${e.toString()}',
        ),
      );
    }
  }

  /// Compare performance between two time periods
  ///
  /// [userId] - The ID of the user to compare
  /// [role] - The role of the user (student or tutor)
  /// [currentStart] - Start date of current period
  /// [currentEnd] - End date of current period
  /// [previousStart] - Start date of previous period
  /// [previousEnd] - End date of previous period
  ///
  /// Returns comparison data or [DashboardFailure] if operation fails
  Future<Either<DashboardFailure, PerformanceComparison>> comparePerformance(
    String userId,
    UserRole role,
    DateTime currentStart,
    DateTime currentEnd,
    DateTime previousStart,
    DateTime previousEnd,
  ) async {
    // Validate input
    final validationResult = _validateInput(userId, role);
    if (validationResult != null) {
      return Left(validationResult);
    }

    final currentRange = DateRangeFilter(currentStart, currentEnd);
    final previousRange = DateRangeFilter(previousStart, previousEnd);

    final currentValidation = _validateDateRange(currentRange);
    if (currentValidation != null) return Left(currentValidation);

    final previousValidation = _validateDateRange(previousRange);
    if (previousValidation != null) return Left(previousValidation);

    try {
      // Get comparison data from repository
      final comparisonResult = await _repository.getDashboardComparison(
        userId,
        role,
        currentStart,
        currentEnd,
        previousStart,
        previousEnd,
      );

      return comparisonResult.fold((failure) => Left(failure), (
        comparisonData,
      ) {
        final comparison = _analyzePerformanceComparison(comparisonData, role);
        return Right(comparison);
      });
    } catch (e) {
      return Left(
        DashboardFailure.serverError(
          'Failed to compare performance: ${e.toString()}',
        ),
      );
    }
  }

  /// Get aggregated analytics for multiple users (admin feature)
  ///
  /// [userIds] - List of user IDs to analyze
  /// [role] - The role of the users (student or tutor)
  /// [dateRange] - Optional date range for analysis
  ///
  /// Returns aggregated analytics or [DashboardFailure] if operation fails
  Future<Either<DashboardFailure, AggregatedAnalytics>> getAggregatedAnalytics(
    List<String> userIds,
    UserRole role, {
    DateRangeFilter? dateRange,
  }) async {
    if (userIds.isEmpty) {
      return const Left(
        DashboardFailure.validationError('User IDs list cannot be empty'),
      );
    }

    if (userIds.length > 100) {
      return const Left(
        DashboardFailure.validationError(
          'Cannot analyze more than 100 users at once',
        ),
      );
    }

    try {
      final analyticsResults = <String, DashboardAnalytics>{};

      // Get analytics for each user
      for (final userId in userIds) {
        final analyticsResult = await getAnalytics(
          userId,
          role,
          analysisDepth: AnalysisDepth.basic,
          dateRange: dateRange,
        );

        analyticsResult.fold(
          (failure) => null, // Skip failed users
          (analytics) => analyticsResults[userId] = analytics,
        );
      }

      if (analyticsResults.isEmpty) {
        return const Left(
          DashboardFailure.insufficientData(
            'No analytics data available for provided users',
          ),
        );
      }

      // Aggregate the analytics
      final aggregated = _aggregateAnalytics(analyticsResults, role);
      return Right(aggregated);
    } catch (e) {
      return Left(
        DashboardFailure.serverError(
          'Failed to get aggregated analytics: ${e.toString()}',
        ),
      );
    }
  }

  /// Get predictive insights based on historical data
  ///
  /// [userId] - The ID of the user to predict for
  /// [role] - The role of the user (student or tutor)
  /// [predictionMonths] - Number of months to predict ahead
  ///
  /// Returns predictive insights or [DashboardFailure] if operation fails
  Future<Either<DashboardFailure, PredictiveInsights>> getPredictiveInsights(
    String userId,
    UserRole role, {
    int predictionMonths = 3,
  }) async {
    // Validate input
    final validationResult = _validateInput(userId, role);
    if (validationResult != null) {
      return Left(validationResult);
    }

    if (predictionMonths <= 0 || predictionMonths > 12) {
      return const Left(
        DashboardFailure.validationError(
          'Prediction months must be between 1 and 12',
        ),
      );
    }

    try {
      // Get historical data for prediction
      final endDate = DateTime.now();
      final startDate = DateTime(
        endDate.year - 1, // 1 year of historical data
        endDate.month,
        endDate.day,
      );

      final trendResult = await getTrendAnalysis(
        userId,
        role,
        startDate,
        endDate,
        interval: 'monthly',
      );

      return trendResult.fold((failure) => Left(failure), (trendAnalysis) {
        final insights = _generatePredictiveInsights(
          trendAnalysis,
          role,
          predictionMonths,
        );
        return Right(insights);
      });
    } catch (e) {
      return Left(
        DashboardFailure.serverError(
          'Failed to get predictive insights: ${e.toString()}',
        ),
      );
    }
  }

  // Private methods for analytics processing

  Future<Either<DashboardFailure, DashboardAnalytics>> _gatherAnalyticsData(
    String userId,
    UserRole role,
    AnalysisDepth depth,
    DateRangeFilter? dateRange,
  ) async {
    // Implementation would gather comprehensive analytics data
    // This is a simplified version

    final summaryResult = await _repository.getDashboardSummary(userId, role);

    return summaryResult.fold((failure) => Left(failure), (summary) {
      final analytics = DashboardAnalytics(
        userId: userId,
        role: role,
        summary: summary,
        analysisDepth: depth,
        generatedAt: DateTime.now(),
        dateRange: dateRange,
      );
      return Right(analytics);
    });
  }

  DashboardFailure? _validateInput(String userId, UserRole role) {
    if (userId.isEmpty) {
      return const DashboardFailure.validationError('User ID cannot be empty');
    }

    if (userId.length < 3) {
      return DashboardFailure.invalidUserId(userId);
    }

    return null;
  }

  DashboardFailure? _validateDateRange(DateRangeFilter dateRange) {
    if (dateRange.startDate.isAfter(dateRange.endDate)) {
      return const DashboardFailure.invalidDateRange(
        'Start date cannot be after end date',
      );
    }

    final now = DateTime.now();
    if (dateRange.endDate.isAfter(now)) {
      return const DashboardFailure.invalidDateRange(
        'End date cannot be in the future',
      );
    }

    return null;
  }

  TrendAnalysis _analyzeTrends(
    Map<String, List<dynamic>> trendsData,
    String interval,
  ) {
    // Implementation would analyze trends and provide insights
    return TrendAnalysis(
      data: trendsData,
      interval: interval,
      direction: TrendDirection.stable,
      confidence: 75.0,
      insights: ['Trend analysis in progress'],
      generatedAt: DateTime.now(),
    );
  }

  PerformanceComparison _analyzePerformanceComparison(
    Map<String, dynamic> comparisonData,
    UserRole role,
  ) {
    // Implementation would analyze performance differences
    return PerformanceComparison(
      data: comparisonData,
      role: role,
      improvements: [],
      deteriorations: [],
      overallChange: 0.0,
      generatedAt: DateTime.now(),
    );
  }

  AggregatedAnalytics _aggregateAnalytics(
    Map<String, DashboardAnalytics> analyticsResults,
    UserRole role,
  ) {
    // Implementation would aggregate analytics across users
    return AggregatedAnalytics(
      role: role,
      userCount: analyticsResults.length,
      aggregatedData: {},
      insights: [],
      generatedAt: DateTime.now(),
    );
  }

  PredictiveInsights _generatePredictiveInsights(
    TrendAnalysis trendAnalysis,
    UserRole role,
    int predictionMonths,
  ) {
    // Implementation would generate predictions based on trends
    return PredictiveInsights(
      role: role,
      predictionMonths: predictionMonths,
      predictions: {},
      confidence: 60.0,
      factors: ['Historical trend analysis'],
      generatedAt: DateTime.now(),
    );
  }
}

// Supporting classes for analytics

enum AnalysisDepth { basic, detailed, comprehensive }

enum TrendDirection { increasing, decreasing, stable, volatile }

class DashboardAnalytics {
  final String userId;
  final UserRole role;
  final Map<String, dynamic> summary;
  final AnalysisDepth analysisDepth;
  final DateTime generatedAt;
  final DateRangeFilter? dateRange;

  const DashboardAnalytics({
    required this.userId,
    required this.role,
    required this.summary,
    required this.analysisDepth,
    required this.generatedAt,
    this.dateRange,
  });
}

class TrendAnalysis {
  final Map<String, List<dynamic>> data;
  final String interval;
  final TrendDirection direction;
  final double confidence;
  final List<String> insights;
  final DateTime generatedAt;

  const TrendAnalysis({
    required this.data,
    required this.interval,
    required this.direction,
    required this.confidence,
    required this.insights,
    required this.generatedAt,
  });
}

class PerformanceComparison {
  final Map<String, dynamic> data;
  final UserRole role;
  final List<String> improvements;
  final List<String> deteriorations;
  final double overallChange;
  final DateTime generatedAt;

  const PerformanceComparison({
    required this.data,
    required this.role,
    required this.improvements,
    required this.deteriorations,
    required this.overallChange,
    required this.generatedAt,
  });
}

class AggregatedAnalytics {
  final UserRole role;
  final int userCount;
  final Map<String, dynamic> aggregatedData;
  final List<String> insights;
  final DateTime generatedAt;

  const AggregatedAnalytics({
    required this.role,
    required this.userCount,
    required this.aggregatedData,
    required this.insights,
    required this.generatedAt,
  });
}

class PredictiveInsights {
  final UserRole role;
  final int predictionMonths;
  final Map<String, dynamic> predictions;
  final double confidence;
  final List<String> factors;
  final DateTime generatedAt;

  const PredictiveInsights({
    required this.role,
    required this.predictionMonths,
    required this.predictions,
    required this.confidence,
    required this.factors,
    required this.generatedAt,
  });
}
