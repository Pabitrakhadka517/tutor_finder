import 'dart:async';

import 'package:dio/dio.dart';

import '../datasources/auth_local_datasource.dart';

/// Dio Interceptor that:
///  1. Attaches the stored access token to every outgoing request.
///  2. On a 401 response, attempts a transparent token refresh.
///  3. Retries the original request with the new access token.
///  4. If the refresh itself fails, clears local storage (triggers logout).
///
/// The interceptor **skips** auth endpoints (`/auth/login`, `/auth/register*`,
/// `/auth/refresh`, `/auth/forgot-password`, `/auth/reset-password`) to avoid
/// infinite loops.
class AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final AuthLocalDataSource _localDataSource;

  /// Callback the DI layer wires up so the BLoC / app can react to a forced
  /// logout (e.g. navigate to login screen).
  final void Function()? onForceLogout;

  /// Refresh endpoint path.
  static const _refreshPath = '/api/auth/refresh';

  /// Paths where the interceptor should **not** attach a token or retry.
  static final _skipPaths = RegExp(
    r'/api/auth/(login|register|refresh|forgot-password|reset-password)',
  );

  AuthInterceptor({
    required Dio dio,
    required AuthLocalDataSource localDataSource,
    this.onForceLogout,
  }) : _dio = dio,
       _localDataSource = localDataSource;

  // ── Attach access token ─────────────────────────────────────────────────

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_shouldSkip(options.path)) {
      return handler.next(options);
    }

    final token = await _localDataSource.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  // ── Handle 401 → refresh → retry ─────────────────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 ||
        _shouldSkip(err.requestOptions.path)) {
      return handler.next(err);
    }

    // Attempt to refresh
    try {
      final refreshToken = await _localDataSource.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _forceLogout();
        return handler.next(err);
      }

      // Use a **fresh** Dio instance to avoid interceptor recursion.
      final freshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
      final refreshResponse = await freshDio.post(
        _refreshPath,
        data: {'refreshToken': refreshToken},
      );

      if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
        final data = refreshResponse.data as Map<String, dynamic>;

        final newAccessToken =
            data['token'] ?? data['accessToken'] ?? data['access_token'];
        final newRefreshToken = data['refreshToken'] ?? data['refresh_token'];

        if (newAccessToken != null) {
          await _localDataSource.saveAccessToken(newAccessToken as String);
        }
        if (newRefreshToken != null) {
          await _localDataSource.saveRefreshToken(newRefreshToken as String);
        }

        // Retry the original request.
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await freshDio.fetch(retryOptions);
        return handler.resolve(retryResponse);
      }
    } catch (_) {
      // Refresh failed → force logout.
    }

    await _forceLogout();
    return handler.next(err);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _shouldSkip(String path) => _skipPaths.hasMatch(path);

  Future<void> _forceLogout() async {
    await _localDataSource.clearAll();
    onForceLogout?.call();
  }
}
