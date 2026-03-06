import '../models/auth_response_model.dart';
import '../models/forgot_password_response.dart';

/// Remote data source interface for authentication.
///
/// Every method here corresponds to an HTTP call to the Node.js backend.
abstract class AuthRemoteDataSource {
  // ─── Sign-Up (unified) ─────────────────────────────────────────
  /// Register a user with an explicit [role] (student | tutor | admin).
  /// Routes to the correct backend endpoint based on [role].
  Future<AuthResponseModel> signUp({
    required String email,
    required String password,
    required String role,
  });

  // Legacy per-role methods (kept for backward-compatibility).
  @Deprecated('Use signUp() with role parameter instead')
  Future<AuthResponseModel> register({
    required String email,
    required String password,
  });

  @Deprecated('Use signUp() with role parameter instead')
  Future<AuthResponseModel> registerAdmin({
    required String email,
    required String password,
  });

  @Deprecated('Use signUp() with role parameter instead')
  Future<AuthResponseModel> registerTutor({
    required String email,
    required String password,
  });

  // ─── Login / Logout ────────────────────────────────────────────
  /// Login user via API – returns tokens + user data.
  /// [expectedRole] if provided, the backend will validate that the user's
  /// registered role matches, returning an error on mismatch.
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    String? expectedRole,
  });

  /// Logout user (invalidates server tokens + clears local storage).
  Future<bool> logout();

  // ─── Password Reset ────────────────────────────────────────────
  /// Request a password-reset email.
  /// Returns [ForgotPasswordResponse] which may contain dev-mode links.
  Future<ForgotPasswordResponse> forgotPassword(String email);

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  // ─── Token / User ──────────────────────────────────────────────
  /// Refresh access token using the stored refresh token.
  Future<AuthResponseModel> refreshToken();

  /// Get the currently authenticated user from the server.
  Future<AuthResponseModel> getCurrentUser();
}
