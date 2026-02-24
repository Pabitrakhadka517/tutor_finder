import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_finder/app/theme/theme.dart';
import 'package:tutor_finder/app/routes/app_routes.dart';
import 'package:tutor_finder/core/services/socket/socket_service.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/auth/presentation/state/auth_state.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LearnMentor',
      theme: getAppTheme(),
      darkTheme: getDarkTheme(),
      themeMode: themeMode,
      onGenerateRoute: AppRoutes.generateRoute,
      home: const AppWrapper(),
    );
  }
}

/// Wrapper that handles initial auth check only - after that, use Navigator
class AppWrapper extends ConsumerStatefulWidget {
  const AppWrapper({super.key});

  @override
  ConsumerState<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends ConsumerState<AppWrapper> {
  bool _isInitializing = true;
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash for minimum 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Check auth status
    await ref.read(authNotifierProvider.notifier).checkAuthStatus();

    if (mounted) {
      final authState = ref.read(authNotifierProvider);

      setState(() {
        _isInitializing = false;
        if (authState.status == AuthStatus.authenticated) {
          // Connect socket for real-time features
          ref.read(socketServiceProvider).connect();
          _initialScreen = const DashboardPage();
        } else {
          _initialScreen = const OnboardingPage();
        }
      });
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
