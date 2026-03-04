import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../data/models/forgot_password_response.dart';
import '../entities/user.dart';

/// Repository interface for authentication.
///
/// This defines the contract that the **data layer** must implement.
/// It is **framework-independent** and lives in the domain layer.
abstract class AuthRepository {
  // ─── Sign-Up ──────────────────────────────────────────────────────
  /// Unified sign-up – the [role] determines which backend endpoint
  /// is called (student / tutor / admin).
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required UserRole role,
  });

  // Keep legacy per-role methods for backward-compatibility until all
  // call-sites are migrated.
  @Deprecated('Use signUp() with role parameter instead')
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
  });

  @Deprecated('Use signUp() with role parameter instead')
  Future<Either<Failure, User>> registerAdmin({
    required String email,
    required String password,
  });

  @Deprecated('Use signUp() with role parameter instead')
  Future<Either<Failure, User>> registerTutor({
    required String email,
    required String password,
  });

  // ─── Login / Logout ───────────────────────────────────────────────
  /// Login with email and password.
  /// [expectedRole] if provided, the backend validates role match.
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    String? expectedRole,
    bool rememberMe = false,
  });

  /// Logout the current user (invalidates server tokens + clears local)
  Future<Either<Failure, void>> logout();

  // ─── Current User ─────────────────────────────────────────────────
  /// Get the full User entity of the currently authenticated user.
  Future<Either<Failure, User?>> getCurrentUser();

  /// Quick check – is a valid, non-expired token stored locally?
  Future<bool> isAuthenticated();

  /// Fast role extraction from the locally-stored JWT (no network call).
  /// Returns `null` when there is no token or the token is invalid.
  Future<UserRole?> getUserRoleFromToken();

  // ─── Password Reset ───────────────────────────────────────────────
  /// Request a password-reset email.
  /// Returns [ForgotPasswordResponse] which may contain dev-mode links.
  Future<Either<Failure, ForgotPasswordResponse>> forgotPassword(String email);

  /// Reset password using the token delivered via email.
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });
}
