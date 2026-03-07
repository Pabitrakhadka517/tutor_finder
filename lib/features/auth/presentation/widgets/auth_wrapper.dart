import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/socket/socket_service.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_providers.dart';
import '../state/auth_state.dart';
import '../../../dashboard/presentation/pages/role_based_dashboard_shell.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';
import '../../../splash/presentation/pages/splash_page.dart';

/// Central auth wrapper that decides what to show based on
/// the current authentication state and user role.
///
/// Flow:
///  1. Show splash while checking stored token.
///  2. If authenticated → decode role from JWT → navigate to the
///     correct dashboard (Student / Tutor / Admin).
///  3. If unauthenticated → show onboarding / login.
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Dispatch auth check on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Reactive navigation/display based on auth status
    switch (authState.status) {
      case AuthStatus.initial:
      case AuthStatus.splash:
        return const SplashPage();
      case AuthStatus.authenticated:
        if (authState.user != null) {
          // Trigger side effects
          // Use a microtask/post-frame to avoid calling state changes during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(socketServiceProvider).connect();
          });
          return _screenForRole(authState.user!.role);
        }
        return const OnboardingPage();
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
      default:
        return const OnboardingPage();
    }
  }

  /// Map [UserRole] → correct dashboard widget.
  Widget _screenForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
      case UserRole.tutor:
      case UserRole.admin:
        return const RoleBasedDashboardShell();
    }
  }
}
