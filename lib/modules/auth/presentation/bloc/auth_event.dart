import 'package:equatable/equatable.dart';

/// Every event that the [AuthBloc] can receive.
///
/// Each event is a separate class so that `mapEventToState`-style handling
/// (via `on<Event>`) is type-safe and exhaustive.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// ── Login ───────────────────────────────────────────────────────────────────
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// ── Registration ────────────────────────────────────────────────────────────
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String role; // "student" | "tutor"

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, name, role];
}

/// ── Logout ──────────────────────────────────────────────────────────────────
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// ── Refresh Token ───────────────────────────────────────────────────────────
class RefreshRequested extends AuthEvent {
  const RefreshRequested();
}

/// ── Forgot Password ─────────────────────────────────────────────────────────
class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// ── Reset Password ──────────────────────────────────────────────────────────
class ResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;

  const ResetPasswordRequested({
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [token, newPassword];
}

/// ── Load Current User (startup / manual) ────────────────────────────────────
class LoadCurrentUser extends AuthEvent {
  const LoadCurrentUser();
}

/// ── Restore session from local storage on app restart ───────────────────────
class AppStarted extends AuthEvent {
  const AppStarted();
}
