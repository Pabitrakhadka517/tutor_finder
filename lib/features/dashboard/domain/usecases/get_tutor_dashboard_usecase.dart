import 'package:injectable/injectable.dart';

import '../../../../core/utils/either.dart';
import '../entities/dashboard_entity.dart';
import '../failures/dashboard_failure.dart';
import '../repositories/dashboard_repository.dart';
import '../value_objects/user_role.dart';
import 'get_student_dashboard_usecase.dart'; // For DateRangeFilter

/// Use case for retrieving tutor dashboard statistics
///
/// This use case handles all business logic for fetching and processing
/// tutor dashboard data including validation, aggregation, performance metrics,
/// and business insights for tutor operations.
@injectable
class GetTutorDashboardUseCase {
  final DashboardRepository _repository;

  const GetTutorDashboardUseCase(this._repository);

  /// Execute the use case to get tutor dashboard
  ///
  /// [tutorId] - The ID of the tutor to get dashboard for
  /// [dateRange] - Optional date range filter for statistics
  /// [forceRefresh] - Force refresh of cached data
  ///
  /// Returns [TutorDashboardEntity] with complete dashboard statistics
  /// or [DashboardFailure] if operation fails
  Future<Either<DashboardFailure, TutorDashboardEntity>> execute(
    String tutorId, {
    DateRangeFilter? dateRange,
    bool forceRefresh = false,
  }) async {
    // Validate input parameters
    final validationResult = _validateInput(tutorId, dateRange);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Check dashboard access permissions
    final accessResult = await _repository.validateDashboardAccess(
      tutorId,
      UserRole.tutor,
    );

    return await accessResult.fold((failure) => Left(failure), (
      hasAccess,
    ) async {
      if (!hasAccess) {
        return const Left(
          DashboardFailure.permissionDenied(
            'Tutor does not have dashboard access rights',
          ),
        );
      }

      // Force refresh cache if requested
      if (forceRefresh) {
        await _repository.refreshDashboardCache(tutorId, UserRole.tutor);
      }

      // Get dashboard data with optional date filtering
      final dashboardResult = dateRange != null
          ? await _repository.getTutorDashboardByDateRange(
              tutorId,
              dateRange.startDate,
              dateRange.endDate,
            )
          : await _repository.getTutorDashboard(tutorId);

      return await dashboardResult.fold((failure) => Left(failure), (
        dashboard,
      ) async {
        // Validate data completeness and business rules
        final dataValidationResult = await _validateDashboardData(dashboard);
        if (dataValidationResult != null) {
          return Left(dataValidationResult);
        }

        // Apply business logic and performance enhancements
        final enhancedDashboard = _enhanceDashboardData(dashboard);
        return Right(enhancedDashboard);
      });
    });
  }

  /// Get dashboard summary for quick overview
  Future<Either<DashboardFailure, Map<String, dynamic>>> getSummary(
    String tutorId,
  ) async {
    // Validate input
    final validationResult = _validateTutorId(tutorId);
    if (validationResult != null) {
      return Left(validationResult);
    }

    return await _repository.getDashboardSummary(tutorId, UserRole.tutor);
  }

  /// Get dashboard trends for specified period
  Future<Either<DashboardFailure, Map<String, List<dynamic>>>> getTrends(
    String tutorId,
    DateTime startDate,
    DateTime endDate, {
    String interval = 'weekly',
  }) async {
    // Validate input
    final validationResult = _validateInput(
      tutorId,
      DateRangeFilter(startDate, endDate),
    );
    if (validationResult != null) {
      return Left(validationResult);
    }

    return await _repository.getDashboardTrends(
      tutorId,
      UserRole.tutor,
      startDate,
      endDate,
      interval,
    );
  }

  /// Get performance comparison between time periods
  Future<Either<DashboardFailure, Map<String, dynamic>>>
  getPerformanceComparison(
    String tutorId,
    DateTime currentStart,
    DateTime currentEnd,
    DateTime previousStart,
    DateTime previousEnd,
  ) async {
    // Validate input
    final currentRange = DateRangeFilter(currentStart, currentEnd);
    final previousRange = DateRangeFilter(previousStart, previousEnd);

    final currentValidation = _validateInput(tutorId, currentRange);
    if (currentValidation != null) return Left(currentValidation);

    final previousValidation = _validateDateRange(previousRange);
    if (previousValidation != null) return Left(previousValidation);

    return await _repository.getDashboardComparison(
      tutorId,
      UserRole.tutor,
      currentStart,
      currentEnd,
      previousStart,
      previousEnd,
    );
  }

  /// Check if tutor has sufficient data for meaningful dashboard
  Future<Either<DashboardFailure, bool>> hasMinimumData(String tutorId) async {
    final validationResult = _validateTutorId(tutorId);
    if (validationResult != null) {
      return Left(validationResult);
    }

    return await _repository.hasMinimumDataForDashboard(
      tutorId,
      UserRole.tutor,
    );
  }

  /// Analyze tutor performance and provide recommendations
  Future<Either<DashboardFailure, TutorPerformanceAnalysis>> analyzePerformance(
    String tutorId, {
    int analysisMonths = 6,
  }) async {
    final validationResult = _validateTutorId(tutorId);
    if (validationResult != null) {
      return Left(validationResult);
    }

    final endDate = DateTime.now();
    final startDate = DateTime(
      endDate.year,
      endDate.month - analysisMonths,
      endDate.day,
    );

    final dashboardResult = await execute(
      tutorId,
      dateRange: DateRangeFilter(startDate, endDate),
    );

    return dashboardResult.fold((failure) => Left(failure), (dashboard) {
      final analysis = _performPerformanceAnalysis(dashboard);
      return Right(analysis);
    });
  }

  // Private validation methods

  DashboardFailure? _validateInput(String tutorId, DateRangeFilter? dateRange) {
    // Validate tutor ID
    final tutorIdValidation = _validateTutorId(tutorId);
    if (tutorIdValidation != null) return tutorIdValidation;

    // Validate date range if provided
    if (dateRange != null) {
      final dateRangeValidation = _validateDateRange(dateRange);
      if (dateRangeValidation != null) return dateRangeValidation;
    }

    return null;
  }

  DashboardFailure? _validateTutorId(String tutorId) {
    if (tutorId.isEmpty) {
      return const DashboardFailure.validationError('Tutor ID cannot be empty');
    }
    if (tutorId.length < 3) {
      return DashboardFailure.invalidUserId(tutorId);
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

    final maxRange = Duration(days: 365); // 1 year max
    if (dateRange.endDate.difference(dateRange.startDate) > maxRange) {
      return const DashboardFailure.invalidDateRange(
        'Date range cannot exceed 365 days',
      );
    }

    return null;
  }

  Future<DashboardFailure?> _validateDashboardData(
    TutorDashboardEntity dashboard,
  ) async {
    // Check for data completeness
    if (dashboard.totalEarnings < 0) {
      return const DashboardFailure.dataIncomplete(
        'Invalid total earnings amount',
      );
    }

    if (dashboard.totalBookings < 0) {
      return const DashboardFailure.dataIncomplete(
        'Invalid total bookings count',
      );
    }

    if (dashboard.averageRating < 0 || dashboard.averageRating > 5) {
      return const DashboardFailure.dataIncomplete(
        'Invalid average rating value',
      );
    }

    // Validate data consistency
    if (dashboard.completedBookings +
            dashboard.pendingBookings +
            dashboard.cancelledBookings >
        dashboard.totalBookings) {
      return const DashboardFailure.dataIncomplete(
        'Booking counts do not match total',
      );
    }

    // Business rule validation
    if (dashboard.totalReviews > dashboard.completedBookings) {
      return const DashboardFailure.dataIncomplete(
        'Reviews cannot exceed completed bookings',
      );
    }

    return null;
  }

  TutorDashboardEntity _enhanceDashboardData(TutorDashboardEntity dashboard) {
    // Add calculated aggregates and business insights
    final aggregates = dashboard.calculateAggregates();

    // Additional business logic could include:
    // - Performance recommendations
    // - Pricing optimization suggestions
    // - Student engagement insights
    // - Schedule optimization
    // - Subject expertise growth tracking

    return dashboard; // Return enhanced dashboard
  }

  TutorPerformanceAnalysis _performPerformanceAnalysis(
    TutorDashboardEntity dashboard,
  ) {
    final aggregates = dashboard.calculateAggregates();

    // Performance scoring
    double performanceScore = _calculatePerformanceScore(dashboard, aggregates);

    // Generate recommendations
    List<String> recommendations = _generateRecommendations(
      dashboard,
      aggregates,
    );

    // Identify strengths and areas for improvement
    List<String> strengths = _identifyStrengths(dashboard, aggregates);
    List<String> improvements = _identifyImprovements(dashboard, aggregates);

    return TutorPerformanceAnalysis(
      performanceScore: performanceScore,
      recommendations: recommendations,
      strengths: strengths,
      areasForImprovement: improvements,
      generatedAt: DateTime.now(),
    );
  }

  double _calculatePerformanceScore(
    TutorDashboardEntity dashboard,
    Map<String, dynamic> aggregates,
  ) {
    double score = 0.0;

    // Rating score (40%)
    score += (dashboard.averageRating / 5.0) * 40;

    // Completion rate score (30%)
    double completionRate = aggregates['completionRate'] ?? 0.0;
    score += (completionRate / 100.0) * 30;

    // Activity score (20%)
    bool isActive = aggregates['isActiveTutor'] ?? false;
    if (isActive) score += 20;

    // Business growth score (10%)
    if (dashboard.totalStudentsWorkedWith > 10)
      score += 10;
    else
      score += (dashboard.totalStudentsWorkedWith / 10.0) * 10;

    return score.clamp(0.0, 100.0);
  }

  List<String> _generateRecommendations(
    TutorDashboardEntity dashboard,
    Map<String, dynamic> aggregates,
  ) {
    List<String> recommendations = [];

    if (dashboard.averageRating < 4.0) {
      recommendations.add(
        'Focus on improving lesson quality and student satisfaction',
      );
    }

    double completionRate = aggregates['completionRate'] ?? 0.0;
    if (completionRate < 80) {
      recommendations.add('Work on reducing cancellations and no-shows');
    }

    if (dashboard.totalStudentsWorkedWith < 5) {
      recommendations.add(
        'Expand your student base through better profile optimization',
      );
    }

    if (dashboard.pendingBookings > dashboard.completedBookings * 0.5) {
      recommendations.add(
        'Consider improving communication and booking confirmation process',
      );
    }

    return recommendations;
  }

  List<String> _identifyStrengths(
    TutorDashboardEntity dashboard,
    Map<String, dynamic> aggregates,
  ) {
    List<String> strengths = [];

    if (dashboard.averageRating >= 4.5) {
      strengths.add('Excellent student satisfaction ratings');
    }

    double completionRate = aggregates['completionRate'] ?? 0.0;
    if (completionRate >= 90) {
      strengths.add('High booking completion rate');
    }

    if (dashboard.totalStudentsWorkedWith > 20) {
      strengths.add('Strong student base and retention');
    }

    if (dashboard.verificationStatus == VerificationStatus.verified) {
      strengths.add('Verified tutor status builds trust');
    }

    return strengths;
  }

  List<String> _identifyImprovements(
    TutorDashboardEntity dashboard,
    Map<String, dynamic> aggregates,
  ) {
    List<String> improvements = [];

    if (dashboard.averageRating < 4.0) {
      improvements.add('Lesson quality and delivery');
    }

    if (dashboard.totalReviews < dashboard.completedBookings * 0.3) {
      improvements.add('Encourage more student reviews');
    }

    double responseRate = aggregates['responseRate'] ?? 0.0;
    if (responseRate < 80) {
      improvements.add('Communication and responsiveness');
    }

    if (dashboard.verificationStatus != VerificationStatus.verified) {
      improvements.add('Complete profile verification process');
    }

    return improvements;
  }
}

/// Performance analysis result for tutors
class TutorPerformanceAnalysis {
  final double performanceScore;
  final List<String> recommendations;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final DateTime generatedAt;

  const TutorPerformanceAnalysis({
    required this.performanceScore,
    required this.recommendations,
    required this.strengths,
    required this.areasForImprovement,
    required this.generatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'performanceScore': performanceScore,
      'recommendations': recommendations,
      'strengths': strengths,
      'areasForImprovement': areasForImprovement,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'TutorPerformanceAnalysis(score: $performanceScore, recommendations: ${recommendations.length})';
  }
}
