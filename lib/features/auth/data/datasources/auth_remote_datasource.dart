import '../../domain/entities/user.dart';

/// Remote data source for authentication
/// This is a stub for future API integration
/// Currently, it doesn't perform any actual operations
abstract class AuthRemoteDataSource {
  /// Register user via API (Future Implementation)
  Future<User> register({
    required String email,
    required String password,
    required String name,
  });

  /// Login user via API (Future Implementation)
  Future<User> login({required String email, required String password});

  /// Logout user via API (Future Implementation)
  Future<void> logout();

  /// Get current user from API (Future Implementation)
  Future<User?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // This is a stub implementation
  // In the future, inject HTTP client (Dio/http) here

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    // TODO: Implement API call
    throw UnimplementedError('API integration not yet implemented');
  }

  @override
  Future<User> login({required String email, required String password}) async {
    // TODO: Implement API call
    throw UnimplementedError('API integration not yet implemented');
  }

  @override
  Future<void> logout() async {
    // TODO: Implement API call
    throw UnimplementedError('API integration not yet implemented');
  }

  @override
  Future<User?> getCurrentUser() async {
    // TODO: Implement API call
    throw UnimplementedError('API integration not yet implemented');
  }
}
