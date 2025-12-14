import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tutor Finder', // app title
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // optional: set a global font
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}
