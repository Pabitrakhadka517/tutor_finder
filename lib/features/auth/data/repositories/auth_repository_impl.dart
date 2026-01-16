import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../models/user_model.dart';

/// Implementation of AuthRepository
/// This coordinates between local and remote data sources
/// Uses remote API for authentication and local storage for session management
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Flag to switch between local and remote data source
  // Set to true to use remote API, false to use local Hive storage
  final bool useRemoteApi;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    this.useRemoteApi = true, // Default to using remote API
  });

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
  }) async {
    if (useRemoteApi) {
      return _registerRemote(
        registerFn: () =>
            remoteDataSource.register(email: email, password: password),
      );
    } else {
      return _registerLocal(email: email, password: password, role: 'student');
    }
  }

  @override
  Future<Either<Failure, User>> registerAdmin({
    required String email,
    required String password,
  }) async {
    if (useRemoteApi) {
      return _registerRemote(
        registerFn: () =>
            remoteDataSource.registerAdmin(email: email, password: password),
      );
    } else {
      return _registerLocal(email: email, password: password, role: 'admin');
    }
  }

  @override
  Future<Either<Failure, User>> registerTutor({
    required String email,
    required String password,
  }) async {
    if (useRemoteApi) {
      return _registerRemote(
        registerFn: () =>
            remoteDataSource.registerTutor(email: email, password: password),
      );
    } else {
      return _registerLocal(email: email, password: password, role: 'tutor');
    }
  }

  /// Helper method for remote registration
  Future<Either<Failure, User>> _registerRemote({
    required Future<dynamic> Function() registerFn,
  }) async {
    try {
      final response = await registerFn();
      return Either.right(response.toEntity());
    } catch (e) {
      return Either.left(
        AuthFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  /// Helper method for local registration with role support
  Future<Either<Failure, User>> _registerLocal({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Check if email already exists
      final emailExists = await localDataSource.emailExists(email);
      if (emailExists) {
        return Either.left(const AuthFailure('Email already registered'));
      }

      // Hash the password for local storage
      final hashedPassword = _hashPassword(password);

      // Create user model with role (name derived from email for local storage)
      final userModel = UserModel(
        hiveId: DateTime.now().millisecondsSinceEpoch.toString(),
        hiveEmail: email,
        hiveName: email.split('@').first, // Use email prefix as name
        hashedPassword: hashedPassword,
        hiveCreatedAt: DateTime.now(),
        hiveRole: role,
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
    if (useRemoteApi) {
      try {
        final response = await remoteDataSource.login(
          email: email,
          password: password,
        );
        return Either.right(response.toEntity());
      } catch (e) {
        return Either.left(
          AuthFailure(e.toString().replaceAll('Exception: ', '')),
        );
      }
    } else {
      return _loginLocal(email: email, password: password);
    }
  }

  /// Helper method for local login (legacy support)
  Future<Either<Failure, User>> _loginLocal({
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
      final isPasswordValid = _verifyPassword(
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
      if (useRemoteApi) {
        await remoteDataSource.logout();
      }
      await localDataSource.removeCurrentUser();
      return Either.right(null);
    } catch (e) {
      return Either.left(CacheFailure('Failed to logout: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      if (useRemoteApi) {
        // For remote API, get user data from secure storage
        final userId = await _secureStorage.read(key: 'user_id');
        final email = await _secureStorage.read(key: 'user_email');
        final name = await _secureStorage.read(key: 'user_name');
        final role = await _secureStorage.read(key: 'user_role');
        final token = await _secureStorage.read(key: 'access_token');

        if (email == null || token == null) {
          return Either.right(null);
        }

        return Either.right(
          User(
            id: userId ?? '',
            email: email,
            name: name ?? '',
            role: _parseRole(role ?? 'student'),
            token: token,
            createdAt: DateTime.now(),
          ),
        );
      } else {
        final userModel = await localDataSource.getCurrentUser();
        return Either.right(userModel?.toEntity());
      }
    } catch (e) {
      return Either.right(null);
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      if (useRemoteApi) {
        final token = await _secureStorage.read(key: 'access_token');
        return token != null;
      } else {
        final userId = await localDataSource.getCurrentUserId();
        return userId != null;
      }
    } catch (e) {
      return false;
    }
  }

  /// Parse role string to UserRole enum
  UserRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'tutor':
        return UserRole.tutor;
      default:
        return UserRole.student;
    }
  }

  /// Simple password hashing for local storage (legacy support)
  String _hashPassword(String password) {
    // Using simple hashing for backward compatibility
    // In production, use a proper hashing library like bcrypt
    return password.hashCode.toString();
  }

  /// Verify password for local storage (legacy support)
  bool _verifyPassword(String password, String hashedPassword) {
    return password.hashCode.toString() == hashedPassword;
  }
}
