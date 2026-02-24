/// Review-related failure types for error handling.
/// Follows the established failure pattern from other modules.
abstract class ReviewFailure {
  const ReviewFailure(this.message);

  final String message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewFailure &&
        runtimeType == other.runtimeType &&
        message == other.message;
  }

  @override
  int get hashCode => message.hashCode ^ runtimeType.hashCode;

  @override
  String toString() => '$runtimeType: $message';

  // Factory constructors for common failure types
  factory ReviewFailure.serverError(String message) = ReviewServerFailure;
  factory ReviewFailure.noConnection(String message) = ReviewConnectionFailure;
  factory ReviewFailure.notFound(String message) = ReviewNotFoundFailure;
  factory ReviewFailure.unauthorized(String message) =
      ReviewUnauthorizedFailure;
  factory ReviewFailure.invalidInput(String message) = ReviewValidationFailure;
  factory ReviewFailure.duplicateReview(String message) =
      ReviewDuplicateFailure;
  factory ReviewFailure.invalidBookingStatus(String message) =
      ReviewInvalidBookingFailure;
  factory ReviewFailure.accessDenied(String message) =
      ReviewAccessDeniedFailure;
}

/// Server-related errors
class ReviewServerFailure extends ReviewFailure {
  const ReviewServerFailure(super.message);
}

/// Network connection errors
class ReviewConnectionFailure extends ReviewFailure {
  const ReviewConnectionFailure(super.message);
}

/// Review not found errors
class ReviewNotFoundFailure extends ReviewFailure {
  const ReviewNotFoundFailure(super.message);
}

/// Authentication/authorization errors
class ReviewUnauthorizedFailure extends ReviewFailure {
  const ReviewUnauthorizedFailure(super.message);
}

/// Input validation errors
class ReviewValidationFailure extends ReviewFailure {
  const ReviewValidationFailure(super.message);
}

/// Duplicate review errors (one review per booking rule)
class ReviewDuplicateFailure extends ReviewFailure {
  const ReviewDuplicateFailure(super.message);
}

/// Invalid booking status errors
class ReviewInvalidBookingFailure extends ReviewFailure {
  const ReviewInvalidBookingFailure(super.message);
}

/// Access denied errors
class ReviewAccessDeniedFailure extends ReviewFailure {
  const ReviewAccessDeniedFailure(super.message);
}
