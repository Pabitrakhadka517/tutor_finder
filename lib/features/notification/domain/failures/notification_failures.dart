import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_failures.freezed.dart';

/// Domain failures for the Notification module
///
/// These failures represent business logic errors and external system failures
/// that can occur during notification operations. Each failure type maps to
/// specific error scenarios in the notification domain.
@freezed
class NotificationFailure with _$NotificationFailure {
  // Validation Errors
  const factory NotificationFailure.validationError(String message) =
      _ValidationError;

  // Authorization Errors
  const factory NotificationFailure.unauthorizedError(String message) =
      _UnauthorizedError;
  const factory NotificationFailure.forbiddenError(String message) =
      _ForbiddenError;

  // Resource Errors
  const factory NotificationFailure.notFoundError(String message) =
      _NotFoundError;
  const factory NotificationFailure.conflictError(String message) =
      _ConflictError;

  // Network Errors
  const factory NotificationFailure.networkError(String message) =
      _NetworkError;
  const factory NotificationFailure.timeoutError(String message) =
      _TimeoutError;

  // Server Errors
  const factory NotificationFailure.serverError(String message) = _ServerError;

  // Cache Errors
  const factory NotificationFailure.cacheError(String message) = _CacheError;

  // WebSocket Errors
  const factory NotificationFailure.connectionError(String message) =
      _ConnectionError;
  const factory NotificationFailure.subscriptionError(String message) =
      _SubscriptionError;

  // Unknown Errors
  const factory NotificationFailure.unknownError(String message) =
      _UnknownError;
}

extension NotificationFailureX on NotificationFailure {
  /// Get user-friendly error message for display
  String get userMessage {
    return when(
      validationError: (message) => 'Invalid input: $message',
      unauthorizedError: (message) => 'Please log in to continue',
      forbiddenError: (message) => 'Access denied: $message',
      notFoundError: (message) => 'Notification not found',
      conflictError: (message) => 'Operation conflict: $message',
      networkError: (message) => 'Network error. Please check your connection.',
      timeoutError: (message) => 'Request timed out. Please try again.',
      serverError: (message) => 'Server error. Please try again later.',
      cacheError: (message) => 'Data loading error: $message',
      connectionError: (message) => 'Connection error: $message',
      subscriptionError: (message) =>
          'Notification subscription error: $message',
      unknownError: (message) => 'An unexpected error occurred: $message',
    );
  }

  /// Check if this failure is recoverable (e.g., network issues)
  bool get isRecoverable {
    return when(
      validationError: (_) => false,
      unauthorizedError: (_) => true,
      forbiddenError: (_) => false,
      notFoundError: (_) => false,
      conflictError: (_) => false,
      networkError: (_) => true,
      timeoutError: (_) => true,
      serverError: (_) => true,
      cacheError: (_) => true,
      connectionError: (_) => true,
      subscriptionError: (_) => true,
      unknownError: (_) => false,
    );
  }

  /// Check if this failure should trigger a retry mechanism
  bool get shouldRetry {
    return when(
      validationError: (_) => false,
      unauthorizedError: (_) => false,
      forbiddenError: (_) => false,
      notFoundError: (_) => false,
      conflictError: (_) => false,
      networkError: (_) => true,
      timeoutError: (_) => true,
      serverError: (_) => true,
      cacheError: (_) => false,
      connectionError: (_) => true,
      subscriptionError: (_) => true,
      unknownError: (_) => false,
    );
  }

  /// Get the appropriate HTTP status code for this failure
  int get statusCode {
    return when(
      validationError: (_) => 400,
      unauthorizedError: (_) => 401,
      forbiddenError: (_) => 403,
      notFoundError: (_) => 404,
      conflictError: (_) => 409,
      networkError: (_) => 0, // No HTTP status for network errors
      timeoutError: (_) => 408,
      serverError: (_) => 500,
      cacheError: (_) => 0, // No HTTP status for cache errors
      connectionError: (_) => 0, // No HTTP status for connection errors
      subscriptionError: (_) => 0, // No HTTP status for subscription errors
      unknownError: (_) => 500,
    );
  }

  /// Get failure severity for logging purposes
  String get severity {
    return when(
      validationError: (_) => 'warning',
      unauthorizedError: (_) => 'info',
      forbiddenError: (_) => 'warning',
      notFoundError: (_) => 'info',
      conflictError: (_) => 'warning',
      networkError: (_) => 'error',
      timeoutError: (_) => 'warning',
      serverError: (_) => 'error',
      cacheError: (_) => 'warning',
      connectionError: (_) => 'error',
      subscriptionError: (_) => 'error',
      unknownError: (_) => 'critical',
    );
  }
}
