import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../models/forgot_password_response.dart';

/// Implementation of [AuthRepository].
///
/// Coordinates between Remote (Node.js API) and Local (Hive / SecureStorage)
/// data sources.  All token persistence and JWT decoding happen here so the
/// domain layer stays pure.
class AuthRepositoryImpl implements AuthRepository {
  static const String _rememberMeKey = 'remember_me';
  static const String _isLoggedInKey = 'is_logged_in';

  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // ═══════════════════════════════════════════════════════════════
  // SIGN-UP (unified)
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final response = await remoteDataSource.signUp(
        email: email,
        password: password,
        role: role.name,
      );
      return Either.right(response.toEntity());
    } catch (e) {
      return Either.left(
        AuthFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  // Legacy per-role delegates ────────────────────────────────────

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
  }) => signUp(email: email, password: password, role: UserRole.student);

  @override
  Future<Either<Failure, User>> registerAdmin({
    required String email,
    required String password,
  }) => signUp(email: email, password: password, role: UserRole.admin);

  @override
  Future<Either<Failure, User>> registerTutor({
    required String email,
    required String password,
  }) => signUp(email: email, password: password, role: UserRole.tutor);

  // ═══════════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    String? expectedRole,
    bool rememberMe = false,
  }) async {
    try {
      final response = await remoteDataSource.login(
        email: email,
        password: password,
        expectedRole: expectedRole,
      );

      await _secureStorage.write(
        key: _rememberMeKey,
        value: rememberMe ? 'true' : 'false',
      );
      await _secureStorage.write(
        key: _isLoggedInKey,
        value: rememberMe ? 'true' : 'false',
      );

      return Either.right(response.toEntity());
    } catch (e) {
      return Either.left(
        AuthFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.removeCurrentUser();
      await _secureStorage.write(key: _rememberMeKey, value: 'false');
      await _secureStorage.write(key: _isLoggedInKey, value: 'false');
      return Either.right(null);
    } catch (e) {
      return Either.left(CacheFailure('Failed to logout: ${e.toString()}'));
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // CURRENT USER
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      if (token == null) return Either.right(null);

      // Check expiry locally first (fast, no network)
      if (JwtDecoder.isExpired(token)) {
        // Try refresh before giving up
        try {
          await remoteDataSource.refreshToken();
          // re-read updated token
          final newToken = await _secureStorage.read(key: 'access_token');
          if (newToken == null) return Either.right(null);
        } catch (_) {
          // Refresh failed – clear tokens, user must re-login
          await _clearTokens();
          return Either.right(null);
        }
      }

      // Build User from stored data
      final userId = await _secureStorage.read(key: 'user_id');
      final email = await _secureStorage.read(key: 'user_email');
      final name = await _secureStorage.read(key: 'user_name');
      final role = await _secureStorage.read(key: 'user_role');
      final currentToken = await _secureStorage.read(key: 'access_token');

      if (email == null || currentToken == null) {
        return Either.right(null);
      }

      return Either.right(
        User(
          id: userId ?? '',
          email: email,
          fullName: name ?? '',
          role: _parseRole(role ?? 'student'),
          token: currentToken,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      return Either.right(null);
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final rememberMe = await _secureStorage.read(key: _rememberMeKey);
      final isLoggedIn = await _secureStorage.read(key: _isLoggedInKey);

      if (rememberMe != 'true' || isLoggedIn != 'true') {
        return false;
      }

      final token = await _secureStorage.read(key: 'access_token');
      if (token == null) return false;
      // Consider expired tokens as unauthenticated
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // JWT-BASED ROLE EXTRACTION (fast, no network)
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<UserRole?> getUserRoleFromToken() async {
    try {
      final rememberMe = await _secureStorage.read(key: _rememberMeKey);
      final isLoggedIn = await _secureStorage.read(key: _isLoggedInKey);
      if (rememberMe != 'true' || isLoggedIn != 'true') return null;

      final token = await _secureStorage.read(key: 'access_token');
      if (token == null) return null;

      if (JwtDecoder.isExpired(token)) return null;

      final roleStr = JwtDecoder.getRole(token);
      return _parseRole(roleStr);
    } catch (_) {
      // Fallback: try reading from stored user_role
      try {
        final role = await _secureStorage.read(key: 'user_role');
        if (role != null) return _parseRole(role);
      } catch (_) {}
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // PASSWORD RESET
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, ForgotPasswordResponse>> forgotPassword(
    String email,
  ) async {
    try {
      final response = await remoteDataSource.forgotPassword(email);
      return Either.right(response);
    } catch (e) {
      return Either.left(
        AuthFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      return Either.right(null);
    } catch (e) {
      return Either.left(
        AuthFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════

  /// Parse role string to [UserRole] enum.
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

  /// Wipe all locally stored tokens and user metadata.
  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'user_id');
    await _secureStorage.delete(key: 'user_email');
    await _secureStorage.delete(key: 'user_name');
    await _secureStorage.delete(key: 'user_role');
    await _secureStorage.write(key: _rememberMeKey, value: 'false');
    await _secureStorage.write(key: _isLoggedInKey, value: 'false');
  }
}
