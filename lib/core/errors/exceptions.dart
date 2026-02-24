/// Exception classes for the errors layer.
/// Re-exports from core/error/exceptions.dart and adds additional types.
export '../error/exceptions.dart';

/// Exception thrown when requested resource is not found
class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);
  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown for unauthorized access
class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException(this.message);
  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Exception thrown for input validation failures
class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
  @override
  String toString() => 'ValidationException: $message';
}

/// Base class for app-specific exceptions
class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => 'AppException: $message';
}
