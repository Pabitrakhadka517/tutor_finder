import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/register_admin_usecase.dart';
import '../../domain/usecases/register_tutor_usecase.dart';
import '../state/auth_state.dart';

/// AuthNotifier manages authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final RegisterUseCase registerUseCase;
  final RegisterAdminUseCase registerAdminUseCase;
  final RegisterTutorUseCase registerTutorUseCase;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;

  AuthNotifier({
    required this.registerUseCase,
    required this.registerAdminUseCase,
    required this.registerTutorUseCase,
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.checkAuthStatusUseCase,
  }) : super(const AuthState.initial());

  /// Check authentication status on app start
  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();

    final isAuthenticated = await checkAuthStatusUseCase.call();

    if (isAuthenticated) {
      final result = await getCurrentUserUseCase.call(const NoParams());
      result.fold((failure) => state = const AuthState.unauthenticated(), (
        user,
      ) {
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

  /// Register a new student
  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    final result = await registerUseCase.call(
      RegisterParams(email: email, password: password),
    );

    result.fold((failure) => state = AuthState.error(failure.message), (user) {
      // Emit registrationSuccess instead of authenticated
      // so RegisterPage can show success message and redirect to login
      state = AuthState(status: AuthStatus.registrationSuccess, user: user);
    });
  }

  /// Register a new admin
  Future<void> registerAdmin({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    final result = await registerAdminUseCase.call(
      RegisterAdminParams(email: email, password: password),
    );

    result.fold((failure) => state = AuthState.error(failure.message), (user) {
      state = AuthState(status: AuthStatus.registrationSuccess, user: user);
    });
  }

  /// Register a new tutor
  Future<void> registerTutor({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    final result = await registerTutorUseCase.call(
      RegisterTutorParams(email: email, password: password),
    );

    result.fold((failure) => state = AuthState.error(failure.message), (user) {
      state = AuthState(status: AuthStatus.registrationSuccess, user: user);
    });
  }

  /// Login with email and password
  Future<void> login({required String email, required String password}) async {
    state = const AuthState.loading();

    final result = await loginUseCase.call(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  /// Logout the current user
  Future<void> logout() async {
    state = const AuthState.loading();

    final result = await logoutUseCase.call(const NoParams());

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (_) => state = const AuthState.unauthenticated(),
    );
  }

  /// Clear error state
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = const AuthState.unauthenticated();
    }
  }
}
