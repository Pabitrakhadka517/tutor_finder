import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/user.dart';

/// Repository interface for authentication
/// This defines the contract that data layer must implement
/// Domain layer doesn't know about implementation details
abstract class AuthRepository {
  /// Register a new user
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
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
