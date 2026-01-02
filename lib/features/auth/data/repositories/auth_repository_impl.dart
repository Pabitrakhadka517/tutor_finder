import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/password_hasher.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Implementation of AuthRepository
/// This coordinates between local and remote data sources
/// Currently only uses local data source (Hive)
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Check if email already exists
      final emailExists = await localDataSource.emailExists(email);
      if (emailExists) {
        return Either.left(const AuthFailure('Email already registered'));
      }

      // Hash the password
      final hashedPassword = PasswordHasher.hashPassword(password);

      // Create user model
      final userModel = UserModel(
        hiveId: DateTime.now().millisecondsSinceEpoch.toString(),
        hiveEmail: email,
        hiveName: name,
        hashedPassword: hashedPassword,
        hiveCreatedAt: DateTime.now(),
      );

      // Save to local storage
      await localDataSource.saveUser(userModel);

      // Set as current user
      await localDataSource.setCurrentUserId(userModel.hiveId);

      // Return domain entity
      return Either.right(userModel.toEntity());
    } catch (e) {
      return Either.left(CacheFailure('Failed to register: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Get user from local storage
      final userModel = await localDataSource.getUserByEmail(email);

      if (userModel == null) {
        return Either.left(const AuthFailure('Invalid email or password'));
      }

      // Verify password
      final isPasswordValid = PasswordHasher.verifyPassword(
        password,
        userModel.hashedPassword,
      );

      if (!isPasswordValid) {
        return Either.left(const AuthFailure('Invalid email or password'));
      }

      // Set as current user
      await localDataSource.setCurrentUserId(userModel.hiveId);

      // Return domain entity
      return Either.right(userModel.toEntity());
    } catch (e) {
      return Either.left(CacheFailure('Failed to login: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.removeCurrentUser();
      return Either.right(null);
    } catch (e) {
      return Either.left(CacheFailure('Failed to logout: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getCurrentUser();
      return Either.right(userModel?.toEntity());
    } catch (e) {
      return Either.right(null);
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final userId = await localDataSource.getCurrentUserId();
      return userId != null;
    } catch (e) {
      return false;
    }
  }
}
