import 'package:dio/dio.dart';

import '../models/auth_response_dto.dart';
import 'auth_remote_datasource.dart';

/// Concrete implementation of [AuthRemoteDataSource] using Dio.
///
/// All methods throw [DioException] on failure; the repository maps these to
/// domain [Failure] types.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  /// API path constants – kept close to the implementation.
  static const _register = '/api/auth/register';
  static const _registerUser = '/api/auth/register/user';
  static const _registerTutor = '/api/auth/register/tutor';
  static const _login = '/api/auth/login';
  static const _refresh = '/api/auth/refresh';
  static const _logout = '/api/auth/logout';
  static const _forgotPassword = '/api/auth/forgot-password';
  static const _resetPassword = '/api/auth/reset-password';
  static const _me = '/api/auth/me';

  AuthRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  // ── Registration ──────────────────────────────────────────────────────────

  @override
  Future<AuthResponseDto> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final response = await _dio.post(
      _register,
      data: {'email': email, 'password': password, 'name': name, 'role': role},
    );
    return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseDto> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _dio.post(
      _registerUser,
      data: {'email': email, 'password': password, 'name': name},
    );
    return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseDto> registerTutor({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _dio.post(
      _registerTutor,
      data: {'email': email, 'password': password, 'name': name},
    );
    return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Authentication ────────────────────────────────────────────────────────

  @override
  Future<AuthResponseDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      _login,
      data: {'email': email, 'password': password},
    );
    return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseDto> refreshToken({required String refreshToken}) async {
    final response = await _dio.post(
      _refresh,
      data: {'refreshToken': refreshToken},
    );
    return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    await _dio.post(_logout, data: {'refreshToken': refreshToken});
  }

  // ── Password ──────────────────────────────────────────────────────────────

  @override
  Future<void> forgotPassword({required String email}) async {
    await _dio.post(_forgotPassword, data: {'email': email});
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _dio.post(
      _resetPassword,
      data: {'token': token, 'newPassword': newPassword},
    );
  }

  // ── Current User ──────────────────────────────────────────────────────────

  @override
  Future<AuthResponseDto> getCurrentUser({required String accessToken}) async {
    final response = await _dio.get(
      _me,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
  }
}
