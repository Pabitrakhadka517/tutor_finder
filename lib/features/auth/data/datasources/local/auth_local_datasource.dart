import 'package:hive/hive.dart';
import '../../models/user_model.dart';

/// Local data source for authentication using Hive
/// Handles all local database operations
abstract class AuthLocalDataSource {
  /// Save user to local storage
  Future<void> saveUser(UserModel user);

  /// Get user by email
  Future<UserModel?> getUserByEmail(String email);

  /// Get currently logged in user
  Future<UserModel?> getCurrentUser();

  /// Remove current user (logout)
  Future<void> removeCurrentUser();

  /// Check if email already exists
  Future<bool> emailExists(String email);

  /// Set current user ID
  Future<void> setCurrentUserId(String userId);

  /// Get current user ID
  Future<String?> getCurrentUserId();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _usersBoxName = 'users';
  static const String _authBoxName = 'auth';
  static const String _currentUserIdKey = 'currentUserId';

  @override
  Future<void> saveUser(UserModel user) async {
    final box = await Hive.openBox<UserModel>(_usersBoxName);
    await box.put(user.hiveEmail, user);
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    final box = await Hive.openBox<UserModel>(_usersBoxName);
    return box.get(email);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;

    final box = await Hive.openBox<UserModel>(_usersBoxName);
    // Find user by ID - return null if not found instead of throwing
    try {
      return box.values.firstWhere((user) => user.hiveId == userId);
    } catch (e) {
      // User not found in box, clear the stale userId and return null
      await removeCurrentUser();
      return null;
    }
  }

  @override
  Future<void> removeCurrentUser() async {
    final authBox = await Hive.openBox(_authBoxName);
    await authBox.delete(_currentUserIdKey);
  }

  @override
  Future<bool> emailExists(String email) async {
    final box = await Hive.openBox<UserModel>(_usersBoxName);
    return box.containsKey(email);
  }

  @override
  Future<void> setCurrentUserId(String userId) async {
    final authBox = await Hive.openBox(_authBoxName);
    await authBox.put(_currentUserIdKey, userId);
  }

  @override
  Future<String?> getCurrentUserId() async {
    final authBox = await Hive.openBox(_authBoxName);
    return authBox.get(_currentUserIdKey);
  }
}
