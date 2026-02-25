import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'core/providers/shared_prefs_provider.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/profile/data/models/profile_model.dart';

void main() async {
  // Global error handling – prevents unhandled exceptions from crashing the app
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      // Initialize Hive
      await Hive.initFlutter();

      // Register Hive Adapters (guard against duplicate registration on hot restart)
      if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
        Hive.registerAdapter(UserModelAdapter());
      }
      if (!Hive.isAdapterRegistered(ProfileModelAdapter().typeId)) {
        Hive.registerAdapter(ProfileModelAdapter());
      }

      // Open Boxes (with recovery for corrupted data)
      try {
        await Hive.openBox<ProfileModel>('profile_box');
      } catch (e) {
        debugPrint('Hive box corrupted, deleting and recreating: $e');
        await Hive.deleteBoxFromDisk('profile_box');
        await Hive.openBox<ProfileModel>('profile_box');
      }

      // Initialize SharedPreferences
      final sharedPrefs = await SharedPreferences.getInstance();

      // Run the app with Riverpod
      runApp(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
          child: const MyApp(),
        ),
      );
    },
    (error, stackTrace) {
      debugPrint('Uncaught error: $error');
      debugPrint('Stack trace: $stackTrace');
    },
  );
}
