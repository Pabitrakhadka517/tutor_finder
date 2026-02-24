import 'package:hive/hive.dart';

import '../models/user_hive_model.dart';

/// Contract for the local (Hive) data source responsible for:
/// - Caching the current user
/// - Persisting access & refresh tokens
abstract class AuthLocalDataSource {
  /// Persist user profile to Hive.
  Future<void> cacheUser(UserHiveModel user);

  /// Retrieve the cached user, or `null` if none.
  Future<UserHiveModel?> getCachedUser();

  /// Remove cached user data.
  Future<void> clearUser();

  /// Save the access token.
  Future<void> saveAccessToken(String token);

  /// Read the access token.
  Future<String?> getAccessToken();

  /// Save the refresh token.
  Future<void> saveRefreshToken(String token);

  /// Read the refresh token.
  Future<String?> getRefreshToken();

  /// Wipe all auth data (tokens + cached user). Called on logout.
  Future<void> clearAll();
}

/// Hive-backed implementation of [AuthLocalDataSource].
///
/// Uses two boxes:
///   • `auth_tokens` – stores access & refresh tokens (String values)
///   • `auth_user`   – stores the cached [UserHiveModel]
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  /// Box for tokens – opened during DI initialisation.
  final Box<String> tokenBox;

  /// Box for the cached user – opened during DI initialisation.
  final Box<UserHiveModel> userBox;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _currentUserKey = 'current_user';

  AuthLocalDataSourceImpl({required this.tokenBox, required this.userBox});

  // ── Tokens ────────────────────────────────────────────────────────────────

  @override
  Future<void> saveAccessToken(String token) async {
    await tokenBox.put(_accessTokenKey, token);
  }

  @override
  Future<String?> getAccessToken() async {
    return tokenBox.get(_accessTokenKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await tokenBox.put(_refreshTokenKey, token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return tokenBox.get(_refreshTokenKey);
  }

  // ── Cached User ───────────────────────────────────────────────────────────

  @override
  Future<void> cacheUser(UserHiveModel user) async {
    await userBox.put(_currentUserKey, user);
  }

  @override
  Future<UserHiveModel?> getCachedUser() async {
    return userBox.get(_currentUserKey);
  }

  @override
  Future<void> clearUser() async {
    await userBox.delete(_currentUserKey);
  }

  // ── Full wipe ─────────────────────────────────────────────────────────────

  @override
  Future<void> clearAll() async {
    await tokenBox.clear();
    await userBox.clear();
  }
}
