import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/get_current_user_role_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/register_admin_usecase.dart';
import '../../domain/usecases/register_tutor_usecase.dart';
import '../notifiers/auth_notifier.dart';
import '../state/auth_state.dart';

// ═══════════════════════════════════════════════════════════════
// DATA SOURCES
// ═══════════════════════════════════════════════════════════════

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return ref.read(authRemoteDatasourceProvider);
});

// ═══════════════════════════════════════════════════════════════
// REPOSITORY
// ═══════════════════════════════════════════════════════════════

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    localDataSource: ref.read(authLocalDataSourceProvider),
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
  );
});

// ═══════════════════════════════════════════════════════════════
// USE CASES
// ═══════════════════════════════════════════════════════════════

/// Unified sign-up use case (replaces the 3 per-role use cases).
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.read(authRepositoryProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.read(authRepositoryProvider));
});

/// Fast role extraction – decodes JWT locally (no network call).
final getCurrentUserRoleUseCaseProvider = Provider<GetCurrentUserRoleUseCase>((
  ref,
) {
  return GetCurrentUserRoleUseCase(ref.read(authRepositoryProvider));
});

final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) {
  return CheckAuthStatusUseCase(ref.read(authRepositoryProvider));
});

// Legacy use-case providers (kept for any backward-compat references)
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

final registerAdminUseCaseProvider = Provider<RegisterAdminUseCase>((ref) {
  return RegisterAdminUseCase(ref.read(authRepositoryProvider));
});

final registerTutorUseCaseProvider = Provider<RegisterTutorUseCase>((ref) {
  return RegisterTutorUseCase(ref.read(authRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════
// AUTH NOTIFIER (state management)
// ═══════════════════════════════════════════════════════════════

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(
    signUpUseCase: ref.read(signUpUseCaseProvider),
    loginUseCase: ref.read(loginUseCaseProvider),
    logoutUseCase: ref.read(logoutUseCaseProvider),
    getCurrentUserUseCase: ref.read(getCurrentUserUseCaseProvider),
    getCurrentUserRoleUseCase: ref.read(getCurrentUserRoleUseCaseProvider),
    checkAuthStatusUseCase: ref.read(checkAuthStatusUseCaseProvider),
    registerUseCase: ref.read(registerUseCaseProvider),
    registerAdminUseCase: ref.read(registerAdminUseCaseProvider),
    registerTutorUseCase: ref.read(registerTutorUseCaseProvider),
    authRepository: ref.read(authRepositoryProvider),
  );
});
