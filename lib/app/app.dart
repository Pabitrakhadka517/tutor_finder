import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_finder/app/theme/theme.dart';
import 'package:tutor_finder/app/routes/app_routes.dart';
import '../core/services/deep_link_service.dart';
import '../features/auth/presentation/widgets/auth_wrapper.dart';

/// Root application widget.
///
/// Uses [AuthWrapper] to handle the auth state check on startup,
/// then routes to the correct dashboard based on the user's role.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final navigatorKey = ref.watch(navigatorKeyProvider);

    // Initialise deep link listener (idempotent – only binds once)
    ref.read(deepLinkServiceProvider).init();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LearnMentor',
      theme: getAppTheme(),
      darkTheme: getDarkTheme(),
      themeMode: themeMode,
      navigatorKey: navigatorKey,
      onGenerateRoute: AppRoutes.generateRoute,
      home: const AuthWrapper(),
    );
  }
}
