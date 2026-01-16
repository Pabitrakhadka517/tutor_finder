import '../models/auth_response_model.dart';

/// Remote data source interface for authentication
/// API only requires email and password
abstract class AuthRemoteDataSource {
  /// Register student via API
  Future<AuthResponseModel> register({
    required String email,
    required String password,
  });

  /// Register admin via API
  Future<AuthResponseModel> registerAdmin({
    required String email,
    required String password,
  });

  /// Register tutor via API
  Future<AuthResponseModel> registerTutor({
    required String email,
    required String password,
  });

  /// Login user via API
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  /// Logout user via API
  Future<bool> logout();
}
