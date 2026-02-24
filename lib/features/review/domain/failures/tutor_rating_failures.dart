sealed class TutorRatingFailure {
  const TutorRatingFailure();

  const factory TutorRatingFailure.networkError(String message) =
      TutorRatingNetworkFailure;
  const factory TutorRatingFailure.serverError(
    String message, {
    int? statusCode,
  }) = TutorRatingServerFailure;
  const factory TutorRatingFailure.cacheError(String message) =
      TutorRatingCacheFailure;
  const factory TutorRatingFailure.notFoundError(String message) =
      TutorRatingNotFoundFailure;
  const factory TutorRatingFailure.validationError(String message) =
      TutorRatingValidationFailure;
  const factory TutorRatingFailure.unknownError(String message) =
      TutorRatingUnknownFailure;
  const factory TutorRatingFailure.unauthorizedError(String message) =
      TutorRatingUnauthorizedFailure;
  const factory TutorRatingFailure.forbiddenError(String message) =
      TutorRatingForbiddenFailure;
  const factory TutorRatingFailure.conflictError(String message) =
      TutorRatingConflictFailure;
}

final class TutorRatingNetworkFailure extends TutorRatingFailure {
  final String message;
  const TutorRatingNetworkFailure(this.message);
}

final class TutorRatingServerFailure extends TutorRatingFailure {
  final String message;
  final int? statusCode;
  const TutorRatingServerFailure(this.message, {this.statusCode});
}

final class TutorRatingCacheFailure extends TutorRatingFailure {
  final String message;
  const TutorRatingCacheFailure(this.message);
}

final class TutorRatingNotFoundFailure extends TutorRatingFailure {
  final String message;
  const TutorRatingNotFoundFailure(this.message);
}

final class TutorRatingValidationFailure extends TutorRatingFailure {
  final String message;
  const TutorRatingValidationFailure(this.message);
}

final class TutorRatingUnknownFailure extends TutorRatingFailure {
  final String message;
  const TutorRatingUnknownFailure(this.message);
}

final class TutorRatingUnauthorizedFailure extends TutorRatingFailure {
  final String message;
  const TutorRatingUnauthorizedFailure(this.message);
}

final class TutorRatingForbiddenFailure extends TutorRatingFailure {
  final String message;
  const TutorRatingForbiddenFailure(this.message);
}

final class TutorRatingConflictFailure extends TutorRatingFailure {
  final String message;
  const TutorRatingConflictFailure(this.message);
}
