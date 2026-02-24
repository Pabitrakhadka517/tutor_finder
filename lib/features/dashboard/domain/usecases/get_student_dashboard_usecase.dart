import 'package:injectable/injectable.dart';

import '../../../../core/utils/either.dart';
import '../entities/dashboard_entity.dart';
import '../failures/dashboard_failure.dart';
import '../repositories/dashboard_repository.dart';
import '../value_objects/user_role.dart';

/// Use case for retrieving student dashboard statistics
///
/// This use case handles all business logic for fetching and processing
/// student dashboard data including validation, aggregation, and formatting.
@injectable
class GetStudentDashboardUseCase {
  final DashboardRepository _repository;

  const GetStudentDashboardUseCase(this._repository);

  /// Execute the use case to get student dashboard
  ///
  /// [studentId] - The ID of the student to get dashboard for
  /// [dateRange] - Optional date range filter for statistics
  ///
  /// Returns [StudentDashboardEntity] with complete dashboard statistics
  /// or [DashboardFailure] if operation fails
  Future<Either<DashboardFailure, StudentDashboardEntity>> execute(
    String studentId, {
    DateRangeFilter? dateRange,
    bool forceRefresh = false,
  }) async {
    // Validate input parameters
    final validationResult = _validateInput(studentId, dateRange);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Check dashboard access permissions
    final accessResult = await _repository.validateDashboardAccess(
      studentId,
      UserRole.student,
    );

    return await accessResult.fold((failure) => Left(failure), (
      hasAccess,
    ) async {
      if (!hasAccess) {
        return const Left(
          DashboardFailure.permissionDenied(
            'Student does not have dashboard access rights',
          ),
        );
      }

      // Force refresh cache if requested
      if (forceRefresh) {
        await _repository.refreshDashboardCache(studentId, UserRole.student);
      }

      // Get dashboard data with optional date filtering
      final dashboardResult = dateRange != null
          ? await _repository.getStudentDashboardByDateRange(
              studentId,
              dateRange.startDate,
              dateRange.endDate,
            )
          : await _repository.getStudentDashboard(studentId);

      return await dashboardResult.fold((failure) => Left(failure), (
        dashboard,
      ) async {
        // Validate data completeness
        final dataValidationResult = await _validateDashboardData(dashboard);
        if (dataValidationResult != null) {
          return Left(dataValidationResult);
        }

        // Apply business logic and enhancements
        final enhancedDashboard = _enhanceDashboardData(dashboard);
        return Right(enhancedDashboard);
      });
    });
  }

  /// Get dashboard summary for quick overview
  Future<Either<DashboardFailure, Map<String, dynamic>>> getSummary(
    String studentId,
  ) async {
    // Validate input
    final validationResult = _validateStudentId(studentId);
    if (validationResult != null) {
      return Left(validationResult);
    }

    return await _repository.getDashboardSummary(studentId, UserRole.student);
  }

  /// Get dashboard trends for specified period
  Future<Either<DashboardFailure, Map<String, List<dynamic>>>> getTrends(
    String studentId,
    DateTime startDate,
    DateTime endDate, {
    String interval = 'weekly',
  }) async {
    // Validate input
    final validationResult = _validateInput(
      studentId,
      DateRangeFilter(startDate, endDate),
    );
    if (validationResult != null) {
      return Left(validationResult);
    }

    return await _repository.getDashboardTrends(
      studentId,
      UserRole.student,
      startDate,
      endDate,
      interval,
    );
  }

  /// Check if student has sufficient data for meaningful dashboard
  Future<Either<DashboardFailure, bool>> hasMinimumData(
    String studentId,
  ) async {
    final validationResult = _validateStudentId(studentId);
    if (validationResult != null) {
      return Left(validationResult);
    }

    return await _repository.hasMinimumDataForDashboard(
      studentId,
      UserRole.student,
    );
  }

  // Private validation methods

  DashboardFailure? _validateInput(
    String studentId,
    DateRangeFilter? dateRange,
  ) {
    // Validate student ID
    final studentIdValidation = _validateStudentId(studentId);
    if (studentIdValidation != null) return studentIdValidation;

    // Validate date range if provided
    if (dateRange != null) {
      final dateRangeValidation = _validateDateRange(dateRange);
      if (dateRangeValidation != null) return dateRangeValidation;
    }

    return null;
  }

  DashboardFailure? _validateStudentId(String studentId) {
    if (studentId.isEmpty) {
      return const DashboardFailure.validationError(
        'Student ID cannot be empty',
      );
    }
    if (studentId.length < 3) {
      return DashboardFailure.invalidUserId(studentId);
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
    StudentDashboardEntity dashboard,
  ) async {
    // Check for data completeness
    if (dashboard.totalBookings < 0) {
      return const DashboardFailure.dataIncomplete(
        'Invalid total bookings count',
      );
    }

    if (dashboard.totalSpent < 0) {
      return const DashboardFailure.dataIncomplete(
        'Invalid total spent amount',
      );
    }

    // Validate data consistency
    if (dashboard.upcomingBookings +
            dashboard.completedBookings +
            dashboard.cancelledBookings >
        dashboard.totalBookings) {
      return const DashboardFailure.dataIncomplete(
        'Booking counts do not match total',
      );
    }

    return null;
  }

  StudentDashboardEntity _enhanceDashboardData(
    StudentDashboardEntity dashboard,
  ) {
    // Add calculated aggregates and business insights
    final aggregates = dashboard.calculateAggregates();

    // You could add additional business logic here such as:
    // - Learning recommendations based on subjects
    // - Budget analysis and suggestions
    // - Performance insights
    // - Goal tracking

    return dashboard; // Return enhanced dashboard
  }
}

/// Data class for date range filtering
class DateRangeFilter {
  final DateTime startDate;
  final DateTime endDate;

  const DateRangeFilter(this.startDate, this.endDate);

  @override
  String toString() {
    return 'DateRangeFilter(start: $startDate, end: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRangeFilter &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}
