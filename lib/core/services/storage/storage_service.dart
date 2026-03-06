import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/app_constants.dart';

/// Provider for the StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Secure storage service for tokens and sensitive data
/// Uses flutter_secure_storage for encrypted key-value storage
class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ================= Token Management =================

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: AppConstants.accessTokenKey, value: token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: AppConstants.accessTokenKey);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  /// Save both tokens at once
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  /// Clear both tokens
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: AppConstants.accessTokenKey),
      _secureStorage.delete(key: AppConstants.refreshTokenKey),
    ]);
  }

  // ================= User Data =================

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: AppConstants.userIdKey, value: userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return _secureStorage.read(key: AppConstants.userIdKey);
  }

  /// Save user role
  Future<void> saveUserRole(String role) async {
    await _secureStorage.write(key: AppConstants.userRoleKey, value: role);
  }

  /// Get user role
  Future<String?> getUserRole() async {
    return _secureStorage.read(key: AppConstants.userRoleKey);
  }

  // ================= Generic Operations =================

  /// Write a custom key-value pair
  Future<void> write(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Read a custom key
  Future<String?> read(String key) async {
    return _secureStorage.read(key: key);
  }

  /// Delete a custom key
  Future<void> delete(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    return _secureStorage.containsKey(key: key);
  }

  /// Clear all secure storage
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
