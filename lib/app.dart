import 'package:flutter/material.dart';
import 'package:tutor_finder/theme/theme.dart';
import 'screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LearnMentor',
      theme: getAppTheme(), // apply the global theme
      home: const SplashScreen(),
    );
  }
}
