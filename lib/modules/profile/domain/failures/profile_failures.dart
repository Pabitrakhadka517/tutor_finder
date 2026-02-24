import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Base Failure
// ─────────────────────────────────────────────────────────────────────────────

/// Base class for all profile-related failures.
abstract class ProfileFailure extends Equatable {
  final String message;
  const ProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────────────────────────────────────
// Concrete Failures
// ─────────────────────────────────────────────────────────────────────────────

/// Generic server error (HTTP 500).
class ServerFailure extends ProfileFailure {
  const ServerFailure([
    super.message = 'Server error. Please try again later.',
  ]);
}

/// Local cache / Hive error.
class CacheFailure extends ProfileFailure {
  const CacheFailure([super.message = 'Cache error occurred.']);
}

/// No network connectivity.
class NetworkFailure extends ProfileFailure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

/// HTTP 400 – validation or bad request.
class ValidationFailure extends ProfileFailure {
  final Map<String, dynamic>? errors;
  const ValidationFailure([super.message = 'Validation error.', this.errors]);

  @override
  List<Object?> get props => [message, errors];
}

/// HTTP 401 – token expired / invalid credentials.
class UnauthorizedFailure extends ProfileFailure {
  const UnauthorizedFailure([
    super.message = 'Unauthorized. Please log in again.',
  ]);
}

/// HTTP 403 – forbidden action (e.g. updating other user's profile).
class ForbiddenFailure extends ProfileFailure {
  const ForbiddenFailure([super.message = 'Access denied.']);
}

/// HTTP 404 – profile not found.
class NotFoundFailure extends ProfileFailure {
  const NotFoundFailure([super.message = 'Profile not found.']);
}

/// HTTP 413 – file too large.
class FileTooLargeFailure extends ProfileFailure {
  const FileTooLargeFailure([super.message = 'File size exceeds 5MB limit.']);
}

/// HTTP 415 – unsupported media type.
class UnsupportedFileTypeFailure extends ProfileFailure {
  const UnsupportedFileTypeFailure([
    super.message = 'Only JPG, PNG, and WEBP images are supported.',
  ]);
}

/// Timeout (connection / send / receive).
class TimeoutFailure extends ProfileFailure {
  const TimeoutFailure([
    super.message = 'Connection timed out. Please try again.',
  ]);
}

/// Request was cancelled.
class CancelledFailure extends ProfileFailure {
  const CancelledFailure([super.message = 'Request was cancelled.']);
}

/// Profile-specific business logic error.
class ProfileBusinessFailure extends ProfileFailure {
  const ProfileBusinessFailure(super.message);
}
