import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

/// Possible high-level statuses for the auth flow.
enum AuthStatus {
  /// No auth action has been performed yet.
  initial,

  /// An async operation is in progress.
  loading,

  /// The user is authenticated and [user] is available.
  authenticated,

  /// The user is NOT authenticated (logged out, session expired, etc.).
  unauthenticated,

  /// A non-fatal error occurred (e.g. wrong password).
  /// The [errorMessage] field is populated.
  error,

  /// A password-reset email was sent successfully.
  passwordResetSent,

  /// Password was reset successfully.
  passwordResetSuccess,
}

/// Immutable state emitted by [AuthBloc].
class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState._({required this.status, this.user, this.errorMessage});

  // ── Named constructors ──────────────────────────────────────────────────

  const AuthState.initial() : this._(status: AuthStatus.initial);

  const AuthState.loading() : this._(status: AuthStatus.loading);

  const AuthState.authenticated(UserEntity user)
    : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated()
    : this._(status: AuthStatus.unauthenticated);

  const AuthState.error(String message)
    : this._(status: AuthStatus.error, errorMessage: message);

  const AuthState.passwordResetSent()
    : this._(status: AuthStatus.passwordResetSent);

  const AuthState.passwordResetSuccess()
    : this._(status: AuthStatus.passwordResetSuccess);

  /// Convenience copy helper.
  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState._(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
