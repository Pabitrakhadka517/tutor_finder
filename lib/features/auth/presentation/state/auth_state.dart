import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Authentication state for the app
class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({required this.status, this.user, this.errorMessage});

  /// Initial state
  const AuthState.initial()
    : status = AuthStatus.initial,
      user = null,
      errorMessage = null;

  /// Loading state
  const AuthState.loading()
    : status = AuthStatus.loading,
      user = null,
      errorMessage = null;

  /// Authenticated state
  const AuthState.authenticated(this.user)
    : status = AuthStatus.authenticated,
      errorMessage = null;

  /// Unauthenticated state
  const AuthState.unauthenticated()
    : status = AuthStatus.unauthenticated,
      user = null,
      errorMessage = null;

  /// Error state
  const AuthState.error(String message)
    : status = AuthStatus.error,
      user = null,
      errorMessage = message;

  @override
  List<Object?> get props => [status, user, errorMessage];

  AuthState copyWith({AuthStatus? status, User? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Enum for authentication status
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registrationSuccess,
  error,
}
