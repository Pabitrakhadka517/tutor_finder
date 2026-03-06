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
  bool _isInitializing = true;
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash for minimum 2 seconds for brand visibility
    await Future.delayed(const Duration(seconds: 2));

    // Check token + load user
    await ref.read(authNotifierProvider.notifier).checkAuthStatus();

    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);

    if (authState.status == AuthStatus.authenticated &&
        authState.user != null) {
      // Connect socket for real-time features
      ref.read(socketServiceProvider).connect();

      // Navigate based on role (already decoded from JWT – no extra API call)
      _initialScreen = _screenForRole(authState.user!.role);
    } else {
      _initialScreen = const OnboardingPage();
    }

    setState(() => _isInitializing = false);
  }

  /// Map [UserRole] → correct dashboard widget.
  /// Routes each role to the unified [RoleBasedDashboardShell]
  /// which internally renders the role-specific dashboard page,
  /// bottom navigation, and drawer.
  Widget _screenForRole(UserRole role) {
    // All roles now go through the role-based shell which
    // renders StudentDashboardPage / TutorDashboardPage /
    // AdminDashboardPage based on the authenticated user's role.
    switch (role) {
      case UserRole.student:
      case UserRole.tutor:
      case UserRole.admin:
        return const RoleBasedDashboardShell();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const SplashPage();
    }
    return _initialScreen!;
  }
}
