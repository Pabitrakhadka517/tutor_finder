import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'core/providers/shared_prefs_provider.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/profile/data/models/profile_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ProfileModelAdapter());

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
}
