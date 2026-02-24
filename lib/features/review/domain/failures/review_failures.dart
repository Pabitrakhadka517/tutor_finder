sealed class ReviewFailure {
  const ReviewFailure();

  const factory ReviewFailure.networkError(String message) =
      ReviewNetworkFailure;
  const factory ReviewFailure.serverError(String message, {int? statusCode}) =
      ReviewServerFailure;
  const factory ReviewFailure.cacheError(String message) = ReviewCacheFailure;
  const factory ReviewFailure.notFoundError(String message) =
      ReviewNotFoundFailure;
  const factory ReviewFailure.conflictError(String message) =
      ReviewConflictFailure;
  const factory ReviewFailure.forbiddenError(String message) =
      ReviewForbiddenFailure;
  const factory ReviewFailure.validationError(String message) =
      ReviewValidationFailure;
  const factory ReviewFailure.unknownError(String message) =
      ReviewUnknownFailure;
  const factory ReviewFailure.unauthorizedError(String message) =
      ReviewUnauthorizedFailure;
}

final class ReviewNetworkFailure extends ReviewFailure {
  final String message;
  const ReviewNetworkFailure(this.message);
}

final class ReviewServerFailure extends ReviewFailure {
  final String message;
  final int? statusCode;
  const ReviewServerFailure(this.message, {this.statusCode});
}

final class ReviewCacheFailure extends ReviewFailure {
  final String message;
  const ReviewCacheFailure(this.message);
}

final class ReviewNotFoundFailure extends ReviewFailure {
  final String message;
  const ReviewNotFoundFailure(this.message);
}

final class ReviewConflictFailure extends ReviewFailure {
  final String message;
  const ReviewConflictFailure(this.message);
}

final class ReviewForbiddenFailure extends ReviewFailure {
  final String message;
  const ReviewForbiddenFailure(this.message);
}

final class ReviewValidationFailure extends ReviewFailure {
  final String message;
  const ReviewValidationFailure(this.message);
}

final class ReviewUnknownFailure extends ReviewFailure {
  final String message;
  const ReviewUnknownFailure(this.message);
}

final class ReviewUnauthorizedFailure extends ReviewFailure {
  final String message;
  const ReviewUnauthorizedFailure(this.message);
}
