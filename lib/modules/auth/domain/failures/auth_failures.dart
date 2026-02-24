import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Base Failure
// ─────────────────────────────────────────────────────────────────────────────

/// Base class for all domain-level failures.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────────────────────────────────────
// Concrete Failures
// ─────────────────────────────────────────────────────────────────────────────

/// Generic server error (HTTP 500).
class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Server error. Please try again later.',
  ]);
}

/// Local cache / Hive error.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred.']);
}

/// Authentication-related failure (invalid credentials, expired session, etc.).
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

/// No network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

/// HTTP 400 – validation or bad request.
class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;
  const ValidationFailure([super.message = 'Validation error.', this.errors]);

  @override
  List<Object?> get props => [message, errors];
}

/// HTTP 401 – token expired / invalid credentials.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Unauthorized. Please log in again.',
  ]);
}

/// HTTP 403 – forbidden action (e.g. ADMIN self-registration).
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Access denied.']);
}

/// HTTP 409 – conflict (e.g. duplicate email).
class ConflictFailure extends Failure {
  const ConflictFailure([super.message = 'Resource already exists.']);
}

/// Timeout (connection / send / receive).
class TimeoutFailure extends Failure {
  const TimeoutFailure([
    super.message = 'Connection timed out. Please try again.',
  ]);
}

/// Request was cancelled.
class CancelledFailure extends Failure {
  const CancelledFailure([super.message = 'Request was cancelled.']);
}
