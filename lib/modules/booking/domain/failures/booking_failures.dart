/// Base class for all booking-related failures following Either pattern.
sealed class BookingFailure {
  const BookingFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Server-related failures from API calls
class ServerFailure extends BookingFailure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;

  @override
  String toString() => 'ServerFailure($statusCode): $message';
}

/// Network connectivity failures
class NetworkFailure extends BookingFailure {
  const NetworkFailure(super.message);

  @override
  String toString() => 'NetworkFailure: $message';
}

/// Local cache/storage failures
class CacheFailure extends BookingFailure {
  const CacheFailure(super.message);

  @override
  String toString() => 'CacheFailure: $message';
}

/// Validation failures for user input
class ValidationFailure extends BookingFailure {
  const ValidationFailure(super.message, {this.errors = const []});

  final List<String> errors;

  @override
  String toString() => 'ValidationFailure: $message (${errors.join(', ')})';
}

/// Authorization failures (permission denied)
class AuthorizationFailure extends BookingFailure {
  const AuthorizationFailure(super.message);

  @override
  String toString() => 'AuthorizationFailure: $message';
}

/// Business rule violations
class BusinessRuleFailure extends BookingFailure {
  const BusinessRuleFailure(super.message);

  @override
  String toString() => 'BusinessRuleFailure: $message';
}

/// Booking conflicts (double booking, overlapping sessions)
class ConflictFailure extends BookingFailure {
  const ConflictFailure(super.message, {this.conflictingBookingId});

  final String? conflictingBookingId;

  @override
  String toString() =>
      'ConflictFailure: $message${conflictingBookingId != null ? ' (conflicts with: $conflictingBookingId)' : ''}';
}

/// Payment-related failures
class PaymentFailure extends BookingFailure {
  const PaymentFailure(super.message, {this.paymentErrorCode});

  final String? paymentErrorCode;

  @override
  String toString() =>
      'PaymentFailure: $message${paymentErrorCode != null ? ' (code: $paymentErrorCode)' : ''}';
}

/// Resource not found failures
class NotFoundFailure extends BookingFailure {
  const NotFoundFailure(super.message, {this.resourceType});

  final String? resourceType;

  @override
  String toString() =>
      'NotFoundFailure: $message${resourceType != null ? ' ($resourceType)' : ''}';
}

/// Generic unknown failures
class UnknownFailure extends BookingFailure {
  const UnknownFailure(super.message);

  @override
  String toString() => 'UnknownFailure: $message';
}

/// Extension to provide user-friendly messages
extension BookingFailureMessages on BookingFailure {
  /// Get user-friendly error message for display in UI
  String get userMessage {
    return switch (this) {
      ServerFailure(statusCode: 409) =>
        'This time slot is no longer available. Please choose another time.',
      ServerFailure(statusCode: 400) =>
        'Invalid booking details. Please check your input.',
      ServerFailure(statusCode: 401) => 'You need to log in to make a booking.',
      ServerFailure(statusCode: 403) =>
        'You don\'t have permission to perform this action.',
      ServerFailure(statusCode: 404) => 'The requested booking was not found.',
      ServerFailure() => 'Server error occurred. Please try again later.',
      NetworkFailure() => 'No internet connection. Please check your network.',
      ConflictFailure() => 'This time slot conflicts with another booking.',
      PaymentFailure() =>
        'Payment failed. Please try again or use a different payment method.',
      ValidationFailure() => 'Please check your booking details and try again.',
      AuthorizationFailure() =>
        'You don\'t have permission to access this booking.',
      BusinessRuleFailure() => message, // Use specific business rule message
      NotFoundFailure() => 'The booking you\'re looking for was not found.',
      CacheFailure() => 'Local storage error. Please restart the app.',
      UnknownFailure() => 'An unexpected error occurred. Please try again.',
    };
  }

  /// Check if failure can be retried
  bool get canRetry {
    return switch (this) {
      NetworkFailure() => true,
      ServerFailure(statusCode: final code) when code != null && code >= 500 =>
        true,
      CacheFailure() => true,
      UnknownFailure() => true,
      _ => false,
    };
  }

  /// Get failure severity level
  FailureSeverity get severity {
    return switch (this) {
      ValidationFailure() => FailureSeverity.warning,
      ConflictFailure() => FailureSeverity.warning,
      NetworkFailure() => FailureSeverity.warning,
      AuthorizationFailure() => FailureSeverity.error,
      PaymentFailure() => FailureSeverity.error,
      ServerFailure() => FailureSeverity.error,
      _ => FailureSeverity.critical,
    };
  }
}

/// Failure severity levels for UI handling
enum FailureSeverity {
  warning, // Show snackbar or toast
  error, // Show dialog or error state
  critical, // Show full-screen error
}
