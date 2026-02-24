import 'package:dartz/dartz.dart';

import '../entities/user_entity.dart';
import '../failures/auth_failures.dart';

/// Contract that the data-layer repository must implement.
/// Every method returns `Future<Either<Failure, T>>`.
abstract class AuthRepository {
  /// Register a new student user.
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
    required String role,
  });

  /// Register a new student via dedicated endpoint.
  Future<Either<Failure, UserEntity>> registerUser({
    required String email,
    required String password,
    required String name,
  });

  /// Register a new tutor via dedicated endpoint.
  Future<Either<Failure, UserEntity>> registerTutor({
    required String email,
    required String password,
    required String name,
  });

  /// Authenticate with email + password.
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Request new access token using the persisted refresh token.
  Future<Either<Failure, UserEntity>> refreshToken();

  /// Invalidate the session and clear local tokens.
  Future<Either<Failure, void>> logout();

  /// Send a password-reset email.
  Future<Either<Failure, void>> forgotPassword({required String email});

  /// Reset the password using the token from the email link.
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Fetch the currently authenticated user from `/me`.
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Restore session from local storage on app restart.
  Future<Either<Failure, UserEntity>> restoreSession();
}
