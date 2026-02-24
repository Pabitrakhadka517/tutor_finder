import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_failure.freezed.dart';

/// Represents all possible failures that can occur in the dashboard domain
@freezed
sealed class DashboardFailure with _$DashboardFailure {
  // Network and Connectivity Failures
  const factory DashboardFailure.connectionError([String? message]) =
      _ConnectionError;

  const factory DashboardFailure.timeoutError([String? message]) =
      _TimeoutError;

  // Authentication and Authorization Failures
  const factory DashboardFailure.unauthorizedError([String? message]) =
      _UnauthorizedError;

  const factory DashboardFailure.permissionDenied([String? message]) =
      _PermissionDenied;

  const factory DashboardFailure.invalidRole(String providedRole) =
      _InvalidRole;

  // Data and Resource Failures
  const factory DashboardFailure.userNotFound(String userId) = _UserNotFound;

  const factory DashboardFailure.dashboardNotFound(String userId) =
      _DashboardNotFound;

  const factory DashboardFailure.dataIncomplete(String reason) =
      _DataIncomplete;

  // Validation Failures
  const factory DashboardFailure.validationError(String message) =
      _ValidationError;

  const factory DashboardFailure.invalidUserId(String userId) = _InvalidUserId;

  const factory DashboardFailure.invalidDateRange(String reason) =
      _InvalidDateRange;

  // Server and Processing Failures
  const factory DashboardFailure.serverError(String message) = _ServerError;

  const factory DashboardFailure.aggregationError(String reason) =
      _AggregationError;

  const factory DashboardFailure.databaseError(String message) = _DatabaseError;

  // Rate Limiting and Throttling
  const factory DashboardFailure.rateLimitExceeded([String? message]) =
      _RateLimitExceeded;

  const factory DashboardFailure.tooManyRequests() = _TooManyRequests;

  // Cache Failures
  const factory DashboardFailure.cacheError(String message) = _CacheError;

  const factory DashboardFailure.cacheExpired() = _CacheExpired;

  const factory DashboardFailure.cacheMiss(String key) = _CacheMiss;

  // Business Logic Failures
  const factory DashboardFailure.insufficientData(String reason) =
      _InsufficientData;

  const factory DashboardFailure.statisticsUnavailable(String reason) =
      _StatisticsUnavailable;

  const factory DashboardFailure.conflictError(String message) = _ConflictError;

  // Unknown/Unexpected Failures
  const factory DashboardFailure.unknownError(String message) = _UnknownError;

  const factory DashboardFailure.unexpectedError() = _UnexpectedError;
}

/// Extension to provide user-friendly error messages
extension DashboardFailureExtension on DashboardFailure {
  /// Get a user-friendly error message
  String get userMessage {
    return when(
      connectionError: (message) =>
          message ??
          'Unable to connect to the server. Please check your internet connection.',
      timeoutError: (message) =>
          message ?? 'Request timed out. Please try again.',
      unauthorizedError: (message) =>
          message ?? 'You are not authorized to access this dashboard.',
      permissionDenied: (message) =>
          message ?? 'You do not have permission to view this dashboard.',
      invalidRole: (role) =>
          'Invalid user role: $role. Only students and tutors can access dashboards.',
      userNotFound: (userId) =>
          'User not found. Please check your account status.',
      dashboardNotFound: (userId) =>
          'Dashboard data not available for your account.',
      dataIncomplete: (reason) => 'Dashboard data is incomplete: $reason',
      validationError: (message) => 'Invalid request: $message',
      invalidUserId: (userId) => 'Invalid user ID format.',
      invalidDateRange: (reason) => 'Invalid date range: $reason',
      serverError: (message) =>
          'Server error occurred. Please try again later.',
      aggregationError: (reason) =>
          'Unable to calculate dashboard statistics: $reason',
      databaseError: (message) =>
          'Database error occurred. Please try again later.',
      rateLimitExceeded: (message) =>
          message ?? 'Too many requests. Please wait before trying again.',
      tooManyRequests: () =>
          'Too many requests. Please try again in a few minutes.',
      cacheError: (message) => 'Cache error: $message',
      cacheExpired: () => 'Cached data has expired. Refreshing...',
      cacheMiss: (key) => 'No cached data found for: $key',
      insufficientData: (reason) =>
          'Insufficient data to generate dashboard: $reason',
      statisticsUnavailable: (reason) =>
          'Statistics are currently unavailable: $reason',
      conflictError: (message) => 'Conflict error: $message',
      unknownError: (message) => 'An unknown error occurred: $message',
      unexpectedError: () =>
          'An unexpected error occurred. Please contact support.',
    );
  }

  /// Get the error severity level
  DashboardFailureSeverity get severity {
    return when(
      connectionError: (_) => DashboardFailureSeverity.high,
      timeoutError: (_) => DashboardFailureSeverity.medium,
      unauthorizedError: (_) => DashboardFailureSeverity.critical,
      permissionDenied: (_) => DashboardFailureSeverity.critical,
      invalidRole: (_) => DashboardFailureSeverity.critical,
      userNotFound: (_) => DashboardFailureSeverity.high,
      dashboardNotFound: (_) => DashboardFailureSeverity.medium,
      dataIncomplete: (_) => DashboardFailureSeverity.low,
      validationError: (_) => DashboardFailureSeverity.medium,
      invalidUserId: (_) => DashboardFailureSeverity.medium,
      invalidDateRange: (_) => DashboardFailureSeverity.low,
      serverError: (_) => DashboardFailureSeverity.high,
      aggregationError: (_) => DashboardFailureSeverity.medium,
      databaseError: (_) => DashboardFailureSeverity.high,
      rateLimitExceeded: (_) => DashboardFailureSeverity.low,
      tooManyRequests: () => DashboardFailureSeverity.low,
      cacheError: (_) => DashboardFailureSeverity.low,
      cacheExpired: () => DashboardFailureSeverity.minor,
      cacheMiss: (_) => DashboardFailureSeverity.minor,
      insufficientData: (_) => DashboardFailureSeverity.medium,
      statisticsUnavailable: (_) => DashboardFailureSeverity.medium,
      conflictError: (_) => DashboardFailureSeverity.medium,
      unknownError: (_) => DashboardFailureSeverity.high,
      unexpectedError: () => DashboardFailureSeverity.critical,
    );
  }

  /// Check if the failure is recoverable
  bool get isRecoverable {
    return when(
      connectionError: (_) => true,
      timeoutError: (_) => true,
      unauthorizedError: (_) => false,
      permissionDenied: (_) => false,
      invalidRole: (_) => false,
      userNotFound: (_) => false,
      dashboardNotFound: (_) => true,
      dataIncomplete: (_) => true,
      validationError: (_) => false,
      invalidUserId: (_) => false,
      invalidDateRange: (_) => false,
      serverError: (_) => true,
      aggregationError: (_) => true,
      databaseError: (_) => true,
      rateLimitExceeded: (_) => true,
      tooManyRequests: () => true,
      cacheError: (_) => true,
      cacheExpired: () => true,
      cacheMiss: (_) => true,
      insufficientData: (_) => true,
      statisticsUnavailable: (_) => true,
      conflictError: (_) => true,
      unknownError: (_) => false,
      unexpectedError: () => false,
    );
  }
}

/// Severity levels for dashboard failures
enum DashboardFailureSeverity {
  minor,
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case DashboardFailureSeverity.minor:
        return 'Minor';
      case DashboardFailureSeverity.low:
        return 'Low';
      case DashboardFailureSeverity.medium:
        return 'Medium';
      case DashboardFailureSeverity.high:
        return 'High';
      case DashboardFailureSeverity.critical:
        return 'Critical';
    }
  }
}
