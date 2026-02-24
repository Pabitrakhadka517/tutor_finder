import '../models/auth_response_dto.dart';

/// Contract for the remote (REST API) data source.
///
/// Throws exceptions on error – the repository converts them to [Failure]s.
abstract class AuthRemoteDataSource {
  /// POST /api/auth/register
  Future<AuthResponseDto> register({
    required String email,
    required String password,
    required String name,
    required String role,
  });

  /// POST /api/auth/register/user
  Future<AuthResponseDto> registerUser({
    required String email,
    required String password,
    required String name,
  });

  /// POST /api/auth/register/tutor
  Future<AuthResponseDto> registerTutor({
    required String email,
    required String password,
    required String name,
  });

  /// POST /api/auth/login
  Future<AuthResponseDto> login({
    required String email,
    required String password,
  });

  /// POST /api/auth/refresh
  Future<AuthResponseDto> refreshToken({required String refreshToken});

  /// POST /api/auth/logout
  Future<void> logout({required String refreshToken});

  /// POST /api/auth/forgot-password
  Future<void> forgotPassword({required String email});

  /// POST /api/auth/reset-password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  /// GET /api/auth/me
  Future<AuthResponseDto> getCurrentUser({required String accessToken});
}
