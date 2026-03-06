/// Rich network exception class with named factory constructors.
/// Replaces the simple NetworkException from core/error/exceptions.dart
/// for use in the review and notification features.
sealed class NetworkException implements Exception {
  const NetworkException();

  const factory NetworkException.connectionError() = ConnectionError;
  const factory NetworkException.timeoutError() = TimeoutError;
  const factory NetworkException.badRequest(String message) = BadRequestError;
  const factory NetworkException.unauthorizedError() = UnauthorizedError;
  const factory NetworkException.forbiddenError(String message) =
      ForbiddenError;
  const factory NetworkException.notFound(String message) = NotFoundError;
  const factory NetworkException.conflictError(String message) = ConflictError;
  const factory NetworkException.validationError(String message) =
      ValidationError;
  const factory NetworkException.rateLimitError() = RateLimitError;
  const factory NetworkException.serverError(String message) = ServerError;
  const factory NetworkException.unknownError(String message) =
      UnknownNetworkError;

  /// Pattern-match on the type of network exception
  T when<T>({
    required T Function() connectionError,
    required T Function() timeoutError,
    required T Function(String message) badRequest,
    required T Function() unauthorizedError,
    required T Function(String message) forbiddenError,
    required T Function(String message) notFound,
    required T Function(String message) conflictError,
    required T Function(String message) validationError,
    required T Function() rateLimitError,
    required T Function(String message) serverError,
    required T Function(String message) unknownError,
  }) {
    return switch (this) {
      ConnectionError() => connectionError(),
      TimeoutError() => timeoutError(),
      BadRequestError(:final message) => badRequest(message),
      UnauthorizedError() => unauthorizedError(),
      ForbiddenError(:final message) => forbiddenError(message),
      NotFoundError(:final message) => notFound(message),
      ConflictError(:final message) => conflictError(message),
      ValidationError(:final message) => validationError(message),
      RateLimitError() => rateLimitError(),
      ServerError(:final message) => serverError(message),
      UnknownNetworkError(:final message) => unknownError(message),
    };
  }
}

final class ConnectionError extends NetworkException {
  const ConnectionError();
  @override
  String toString() => 'NetworkException: Connection error';
}

final class TimeoutError extends NetworkException {
  const TimeoutError();
  @override
  String toString() => 'NetworkException: Timeout';
}

final class BadRequestError extends NetworkException {
  final String message;
  const BadRequestError(this.message);
  @override
  String toString() => 'NetworkException: Bad request - $message';
}

final class UnauthorizedError extends NetworkException {
  const UnauthorizedError();
  @override
  String toString() => 'NetworkException: Unauthorized';
}

final class ForbiddenError extends NetworkException {
  final String message;
  const ForbiddenError(this.message);
  @override
  String toString() => 'NetworkException: Forbidden - $message';
}

final class NotFoundError extends NetworkException {
  final String message;
  const NotFoundError(this.message);
  @override
  String toString() => 'NetworkException: Not found - $message';
}

final class ConflictError extends NetworkException {
  final String message;
  const ConflictError(this.message);
  @override
  String toString() => 'NetworkException: Conflict - $message';
}

final class ValidationError extends NetworkException {
  final String message;
  const ValidationError(this.message);
  @override
  String toString() => 'NetworkException: Validation error - $message';
}

final class RateLimitError extends NetworkException {
  const RateLimitError();
  @override
  String toString() => 'NetworkException: Rate limit exceeded';
}

final class ServerError extends NetworkException {
  final String message;
  const ServerError(this.message);
  @override
  String toString() => 'NetworkException: Server error - $message';
}

final class UnknownNetworkError extends NetworkException {
  final String message;
  const UnknownNetworkError(this.message);
  @override
  String toString() => 'NetworkException: Unknown - $message';
}
