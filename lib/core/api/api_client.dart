import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_endpoints.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add Auth Interceptor for adding token to requests
    _dio.interceptors.add(_AuthInterceptor());

    // Logger for debugging (only in debug mode)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

// Auth Interceptor - Adds token to requests
class _AuthInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();

  /// Endpoints that do NOT need a Bearer token.
  /// Note: /auth/logout and /auth/me DO require authentication.
  static const _publicAuthPaths = [
    '/auth/register',
    '/auth/login',
    '/auth/refresh',
    '/auth/forgot-password',
    '/auth/reset-password',
  ];

  bool _isPublicAuthPath(String path) {
    return _publicAuthPaths.any((p) => path.contains(p));
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Only skip token for truly public auth endpoints
    if (_isPublicAuthPath(options.path)) {
      return handler.next(options);
    }

    // Get token from secure storage
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - Token expired
    if (err.response?.statusCode == 401 &&
        !_isPublicAuthPath(err.requestOptions.path)) {
      try {
        final refreshToken = await _storage.read(key: 'refresh_token');
        if (refreshToken == null) {
          return handler.next(err);
        }

        // Attempt to refresh the token
        final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
        final response = await dio.post(
          ApiEndpoints.refreshToken,
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200 && response.data != null) {
          // Backend returns accessToken / refreshToken (camelCase)
          final newAccessToken =
              response.data['accessToken'] ?? response.data['access_token'];
          final newRefreshToken =
              response.data['refreshToken'] ?? response.data['refresh_token'];

          if (newAccessToken != null) {
            await _storage.write(key: 'access_token', value: newAccessToken);
          }
          if (newRefreshToken != null) {
            await _storage.write(key: 'refresh_token', value: newRefreshToken);
          }

          // Retry the original request with new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await dio.fetch(opts);
          return handler.resolve(retryResponse);
        }
      } catch (_) {
        // Refresh failed - clear tokens
        await _storage.delete(key: 'access_token');
        await _storage.delete(key: 'refresh_token');
      }
    }
    return handler.next(err);
  }
}


// api_client.dart ends here