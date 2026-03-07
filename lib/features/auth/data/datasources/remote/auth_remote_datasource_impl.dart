import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/api/api_endpoints.dart';
import '../../models/auth_request_model.dart';
import '../../models/auth_response_model.dart';
import '../../models/forgot_password_response.dart';
import '../auth_remote_datasource.dart';

final authRemoteDatasourceProvider = Provider<AuthRemoteDataSourceImpl>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient: apiClient);
});

/// Implementation of AuthRemoteDataSource using Dio HTTP client
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  // ─── Unified Sign-Up ──────────────────────────────────────────

  /// Routes to the correct backend endpoint based on [role].
  @override
  Future<AuthResponseModel> signUp({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final requestModel = AuthRequestModel(email: email, password: password);

      // Pick the right endpoint based on role
      final String endpoint;
      switch (role.toLowerCase()) {
        case 'tutor':
          endpoint = ApiEndpoints.registerTutor;
          break;
        case 'student':
        default:
          endpoint = ApiEndpoints.register;
          break;
      }

      final response = await _apiClient.post(
        endpoint,
        data: requestModel.toJson(),
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      if (authResponse.token != null) {
        await _saveTokens(authResponse.token!, authResponse.refreshToken);
        await _saveUserData(authResponse);
      }

      return authResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── Legacy per-role methods (delegates to signUp) ────────────

  /// ========== REGISTER STUDENT ==========
  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
  }) => signUp(email: email, password: password, role: 'student');

  /// ========== REGISTER TUTOR ==========
  @override
  Future<AuthResponseModel> registerTutor({
    required String email,
    required String password,
  }) => signUp(email: email, password: password, role: 'tutor');

  /// ========== LOGIN ==========
  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    String? expectedRole,
  }) async {
    try {
      final requestModel = AuthRequestModel(
        email: email,
        password: password,
        expectedRole: expectedRole,
      );

      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: requestModel.toJson(),
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Save tokens
      if (authResponse.token != null) {
        await _saveTokens(authResponse.token!, authResponse.refreshToken);
      }

      // Save user data
      await _saveUserData(authResponse);

      return authResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// ========== LOGOUT ==========
  @override
  Future<bool> logout() async {
    try {
      // Call server to invalidate refresh token
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken != null) {
        try {
          await _apiClient.post(
            ApiEndpoints.logout,
            data: {'refreshToken': refreshToken},
          );
        } catch (_) {
          // Server logout failed, still clear local data
        }
      }

      // Clear all stored data
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');
      await _secureStorage.delete(key: 'user_id');
      await _secureStorage.delete(key: 'user_email');
      await _secureStorage.delete(key: 'user_name');
      await _secureStorage.delete(key: 'user_role');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// ========== FORGOT PASSWORD ==========
  @override
  Future<ForgotPasswordResponse> forgotPassword(String email) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
      return ForgotPasswordResponse.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// ========== RESET PASSWORD ==========
  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {'token': token, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// ========== REFRESH TOKEN ==========
  @override
  Future<AuthResponseModel> refreshToken() async {
    try {
      final currentRefreshToken = await _secureStorage.read(
        key: 'refresh_token',
      );
      if (currentRefreshToken == null) {
        throw Exception('No refresh token found');
      }

      final response = await _apiClient.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': currentRefreshToken},
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      if (authResponse.token != null) {
        await _saveTokens(authResponse.token!, authResponse.refreshToken);
      }

      return authResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// ========== GET CURRENT USER ==========
  @override
  Future<AuthResponseModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.me);
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// ========== HELPER METHODS ==========

  /// Save tokens to secure storage
  Future<void> _saveTokens(String accessToken, String? refreshToken) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
    if (refreshToken != null) {
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);
    }
  }

  /// Save user data to secure storage
  Future<void> _saveUserData(AuthResponseModel response) async {
    if (response.userId != null) {
      await _secureStorage.write(key: 'user_id', value: response.userId);
    }
    await _secureStorage.write(key: 'user_email', value: response.email);
    if (response.name != null) {
      await _secureStorage.write(key: 'user_name', value: response.name);
    }
    await _secureStorage.write(key: 'user_role', value: response.role);
  }

  /// Handle Dio errors and return meaningful exception
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please try again.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        final message = data is Map
            ? data['message'] ?? 'Unknown error'
            : 'Unknown error';

        switch (statusCode) {
          case 400:
            return Exception('Bad request: $message');
          case 401:
            return Exception('Invalid credentials');
          case 403:
            return Exception('Access denied');
          case 404:
            return Exception('Endpoint not found');
          case 409:
            return Exception('User already exists');
          case 422:
            return Exception('Validation error: $message');
          case 500:
            return Exception('Server error. Please try later.');
          default:
            return Exception('Error: $message');
        }

      case DioExceptionType.connectionError:
        if (kIsWeb) {
          return Exception(
            'Cannot reach the server. This may be a CORS issue. '
            'Ensure the backend allows cross-origin requests, '
            'or run with: flutter run -d chrome --web-browser-flag="--disable-web-security"',
          );
        }
        return Exception('No internet connection');

      case DioExceptionType.cancel:
        return Exception('Request cancelled');

      default:
        return Exception('Something went wrong');
    }
  }
}
