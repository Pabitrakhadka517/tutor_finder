import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/forgot_password_response.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/get_current_user_role_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
// Legacy use-case imports (kept for backward-compatibility)
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/register_admin_usecase.dart';
import '../../domain/usecases/register_tutor_usecase.dart';
import '../state/auth_state.dart';

/// [AuthNotifier] manages the authentication state for the entire app.
///
/// It orchestrates domain-layer use cases and exposes a reactive
/// [AuthState] to the presentation layer via Riverpod.
class AuthNotifier extends StateNotifier<AuthState> {
  // ── Use Cases ──
  final SignUpUseCase signUpUseCase;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final GetCurrentUserRoleUseCase getCurrentUserRoleUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;

  // Legacy use cases (kept for backward-compat)
  final RegisterUseCase registerUseCase;
  final RegisterAdminUseCase registerAdminUseCase;
  final RegisterTutorUseCase registerTutorUseCase;

  // Direct repository access for password-reset (no use case yet)
  final AuthRepository authRepository;

  AuthNotifier({
    required this.signUpUseCase,
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.getCurrentUserRoleUseCase,
    required this.checkAuthStatusUseCase,
    required this.registerUseCase,
    required this.registerAdminUseCase,
    required this.registerTutorUseCase,
    required this.authRepository,
  }) : super(const AuthState.initial());

  // ═══════════════════════════════════════════════════════════════
  // AUTH STATUS CHECK
  // ═══════════════════════════════════════════════════════════════

  /// Called on app start – checks stored token validity and role,
  /// then transitions to authenticated or unauthenticated.
  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();

    final isAuthenticated = await checkAuthStatusUseCase.call();

    if (isAuthenticated) {
      final result = await getCurrentUserUseCase.call(const NoParams());
      result.fold((_) => state = const AuthState.unauthenticated(), (user) {
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = const AuthState.unauthenticated();
        }
      });
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  /// Fast role extraction (JWT decode, no network).
  /// Returns the [UserRole] or `null`.
  Future<UserRole?> getUserRole() async {
    return getCurrentUserRoleUseCase.call();
  }

  // ═══════════════════════════════════════════════════════════════
  // UNIFIED SIGN-UP
  // ═══════════════════════════════════════════════════════════════

  /// Sign up with a specific [role] – replaces the old per-role methods.
  Future<void> signUp({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    state = const AuthState.loading();

    final result = await signUpUseCase.call(
      SignUpParams(email: email, password: password, role: role),
    );

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) =>
          state = AuthState(status: AuthStatus.registrationSuccess, user: user),
    );
  }

  // ── Legacy per-role convenience methods ────────────────────────

  /// Register a new student (legacy – delegates to [signUp]).
  Future<void> register({required String email, required String password}) =>
      signUp(email: email, password: password, role: UserRole.student);

  /// Register a new admin (legacy – delegates to [signUp]).
  Future<void> registerAdmin({
    required String email,
    required String password,
  }) => signUp(email: email, password: password, role: UserRole.admin);

  /// Register a new tutor (legacy – delegates to [signUp]).
  Future<void> registerTutor({
    required String email,
    required String password,
  }) => signUp(email: email, password: password, role: UserRole.tutor);

  // ═══════════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════════

  Future<void> login({
    required String email,
    required String password,
    String? expectedRole,
    bool rememberMe = false,
  }) async {
    state = const AuthState.loading();

    final result = await loginUseCase.call(
      LoginParams(
        email: email,
        password: password,
        expectedRole: expectedRole,
        rememberMe: rememberMe,
      ),
    );

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════════════

  Future<void> logout() async {
    state = const AuthState.loading();

    final result = await logoutUseCase.call(const NoParams());

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (_) => state = const AuthState.unauthenticated(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PASSWORD RESET
  // ═══════════════════════════════════════════════════════════════

  /// Returns [ForgotPasswordResponse] on success (may contain dev links),
  /// or `null` on failure.
  Future<ForgotPasswordResponse?> forgotPassword(String email) async {
    state = const AuthState.loading();
    final result = await authRepository.forgotPassword(email);
    return result.fold(
      (failure) {
        state = AuthState.error(failure.message);
        return null;
      },
      (response) {
        state = const AuthState.unauthenticated();
        return response;
      },
    );
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = const AuthState.loading();
    final result = await authRepository.resetPassword(
      token: token,
      newPassword: newPassword,
    );
    return result.fold(
      (failure) {
        state = AuthState.error(failure.message);
        return false;
      },
      (_) {
        state = const AuthState.unauthenticated();
        return true;
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  /// Clear error state.
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = const AuthState.unauthenticated();
    }
  }
}
