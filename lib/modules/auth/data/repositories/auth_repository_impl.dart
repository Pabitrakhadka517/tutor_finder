import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/failures/auth_failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/auth_mapper.dart';
import '../models/auth_response_dto.dart';

/// Concrete repository that coordinates between remote and local data sources.
///
/// Every public method:
///  1. Returns `Either<Failure, T>` — never throws.
///  2. Catches `DioException` and maps to domain failures.
///  3. Saves tokens after successful auth operations.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  // ── Registration ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    return _guard(() async {
      final dto = await _remote.register(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      await _persistAuth(dto);
      return AuthMapper.fromDto(dto);
    });
  }

  @override
  Future<Either<Failure, UserEntity>> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    return _guard(() async {
      final dto = await _remote.registerUser(
        email: email,
        password: password,
        name: name,
      );
      await _persistAuth(dto);
      return AuthMapper.fromDto(dto);
    });
  }

  @override
  Future<Either<Failure, UserEntity>> registerTutor({
    required String email,
    required String password,
    required String name,
  }) async {
    return _guard(() async {
      final dto = await _remote.registerTutor(
        email: email,
        password: password,
        name: name,
      );
      await _persistAuth(dto);
      return AuthMapper.fromDto(dto);
    });
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    return _guard(() async {
      final dto = await _remote.login(email: email, password: password);
      await _persistAuth(dto);
      return AuthMapper.fromDto(dto);
    });
  }

  // ── Refresh Token ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserEntity>> refreshToken() async {
    return _guard(() async {
      final storedRefresh = await _local.getRefreshToken();
      if (storedRefresh == null || storedRefresh.isEmpty) {
        throw const AuthFailure('No refresh token available.');
      }
      final dto = await _remote.refreshToken(refreshToken: storedRefresh);
      await _persistAuth(dto);
      return AuthMapper.fromDto(dto);
    });
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> logout() async {
    return _guard(() async {
      final storedRefresh = await _local.getRefreshToken();
      if (storedRefresh != null && storedRefresh.isNotEmpty) {
        try {
          await _remote.logout(refreshToken: storedRefresh);
        } catch (_) {
          // Best-effort server-side invalidation; always clear local data.
        }
      }
      await _local.clearAll();
    });
  }

  // ── Forgot / Reset Password ───────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    return _guard(() async {
      await _remote.forgotPassword(email: email);
    });
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return _guard(() async {
      await _remote.resetPassword(token: token, newPassword: newPassword);
    });
  }

  // ── Current User ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    return _guard(() async {
      final accessToken = await _local.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw const UnauthorizedFailure('No access token.');
      }
      final dto = await _remote.getCurrentUser(accessToken: accessToken);
      // Cache user locally for offline / quick restore.
      await _local.cacheUser(AuthMapper.dtoToHive(dto));
      return AuthMapper.fromDto(dto);
    });
  }

  // ── Session Restore ───────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserEntity>> restoreSession() async {
    return _guard(() async {
      final accessToken = await _local.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw const UnauthorizedFailure('No stored session.');
      }

      // Try fetching fresh user from API first.
      try {
        final dto = await _remote.getCurrentUser(accessToken: accessToken);
        await _local.cacheUser(AuthMapper.dtoToHive(dto));
        return AuthMapper.fromDto(dto);
      } on DioException catch (e) {
        // If the access token expired, try refreshing.
        if (e.response?.statusCode == 401) {
          final storedRefresh = await _local.getRefreshToken();
          if (storedRefresh != null && storedRefresh.isNotEmpty) {
            final refreshDto = await _remote.refreshToken(
              refreshToken: storedRefresh,
            );
            await _persistAuth(refreshDto);
            // Retry /me with the new token.
            final newAccessToken = await _local.getAccessToken();
            if (newAccessToken != null) {
              final dto = await _remote.getCurrentUser(
                accessToken: newAccessToken,
              );
              await _local.cacheUser(AuthMapper.dtoToHive(dto));
              return AuthMapper.fromDto(dto);
            }
          }
        }
        // Fall back to cached user.
        final cached = await _local.getCachedUser();
        if (cached != null) return AuthMapper.fromHive(cached);
        rethrow;
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Private helpers
  // ═══════════════════════════════════════════════════════════════════════════

  /// Persist tokens (and optionally user) after a successful auth operation.
  Future<void> _persistAuth(AuthResponseDto dto) async {
    final accessToken = dto.resolvedToken;
    final refreshToken = dto.resolvedRefreshToken;

    if (accessToken != null && accessToken.isNotEmpty) {
      await _local.saveAccessToken(accessToken);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _local.saveRefreshToken(refreshToken);
    }

    // Cache user profile.
    if (dto.resolvedUserId.isNotEmpty) {
      await _local.cacheUser(AuthMapper.dtoToHive(dto));
    }
  }

  /// Wraps an async operation and converts exceptions into [Left(Failure)].
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      final result = await body();
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Maps [DioException] to the appropriate domain [Failure].
  Failure _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();
      case DioExceptionType.cancel:
        return const CancelledFailure();
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        return _mapStatusCode(e);
      default:
        return ServerFailure(e.message ?? 'Unknown error');
    }
  }

  Failure _mapStatusCode(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final message = data is Map
        ? (data['message'] ?? 'Unknown error').toString()
        : 'Unknown error';

    switch (statusCode) {
      case 400:
        return ValidationFailure(message);
      case 401:
        return UnauthorizedFailure(message);
      case 403:
        return ForbiddenFailure(message);
      case 409:
        return ConflictFailure(message);
      case 500:
        return ServerFailure(message);
      default:
        return ServerFailure('HTTP $statusCode: $message');
    }
  }
}
