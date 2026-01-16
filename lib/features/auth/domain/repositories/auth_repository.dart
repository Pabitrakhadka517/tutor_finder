import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/user.dart';

/// Repository interface for authentication
/// This defines the contract that data layer must implement
/// API only requires email and password
abstract class AuthRepository {
  /// Register a new student
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
  });

  /// Register a new admin
  Future<Either<Failure, User>> registerAdmin({
    required String email,
    required String password,
  });

  /// Register a new tutor
  Future<Either<Failure, User>> registerTutor({
    required String email,
    required String password,
  });

  /// Login with email and password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Logout the current user
  Future<Either<Failure, void>> logout();

  /// Check if user is currently authenticated
  Future<Either<Failure, User?>> getCurrentUser();

  /// Check authentication status
  Future<bool> isAuthenticated();
}
