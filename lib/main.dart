import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/profile/data/models/profile_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ProfileModelAdapter());

  // Open Boxes
  await Hive.openBox<ProfileModel>('profile_box');

  // Run the app with Riverpod
  runApp(const ProviderScope(child: MyApp()));
}
