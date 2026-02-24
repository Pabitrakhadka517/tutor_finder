import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/datasources/profile_local_datasource.dart';
import 'data/datasources/profile_remote_datasource.dart';
import 'data/datasources/profile_remote_datasource_impl.dart';
import 'data/models/profile_hive_model.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/usecases/change_password_usecase.dart';
import 'domain/usecases/delete_profile_image_usecase.dart';
import 'domain/usecases/get_profile_usecase.dart';
import 'domain/usecases/update_profile_usecase.dart';
import 'domain/usecases/update_theme_usecase.dart';
import 'presentation/bloc/profile_bloc.dart';

final sl = GetIt.instance;

/// Sets up dependency injection for the Profile module.
/// Call this method in your main DI setup after core dependencies.
Future<void> setupProfileModule() async {
  // ─────────────────────────────────────────────────────────────────────
  // External Dependencies
  // ─────────────────────────────────────────────────────────────────────
  // Note: These should already be registered in your main DI setup
  // - Dio (as NetworkClient)
  // - Hive database

  // ─────────────────────────────────────────────────────────────────────
  // Data Sources
  // ─────────────────────────────────────────────────────────────────────

  // Local Data Source
  if (!sl.isRegistered<Box<ProfileHiveModel>>()) {
    final box = await Hive.openBox<ProfileHiveModel>('profile');
    sl.registerLazySingleton<Box<ProfileHiveModel>>(() => box);
  }

  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(profileBox: sl()),
  );

  // Remote Data Source
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // ─────────────────────────────────────────────────────────────────────
  // Repository
  // ─────────────────────────────────────────────────────────────────────

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remote: sl(), local: sl()),
  );

  // ─────────────────────────────────────────────────────────────────────
  // Use Cases
  // ─────────────────────────────────────────────────────────────────────

  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateThemeUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProfileImageUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));

  // ─────────────────────────────────────────────────────────────────────
  // BLoC
  // ─────────────────────────────────────────────────────────────────────

  sl.registerFactory(
    () => ProfileBloc(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      updateThemeUseCase: sl(),
      deleteProfileImageUseCase: sl(),
      changePasswordUseCase: sl(),
    ),
  );
}

/// Disposes of all profile module dependencies.
/// Call this when the module is no longer needed (rarely used).
Future<void> disposeProfileModule() async {
  // Dispose BLoC
  if (sl.isRegistered<ProfileBloc>()) {
    sl.unregister<ProfileBloc>();
  }

  // Dispose Use Cases
  sl.unregister<GetProfileUseCase>();
  sl.unregister<UpdateProfileUseCase>();
  sl.unregister<UpdateThemeUseCase>();
  sl.unregister<DeleteProfileImageUseCase>();
  sl.unregister<ChangePasswordUseCase>();

  // Dispose Repository
  sl.unregister<ProfileRepository>();

  // Dispose Data Sources
  sl.unregister<ProfileRemoteDataSource>();
  sl.unregister<ProfileLocalDataSource>();

  // Close Hive box
  if (sl.isRegistered<Box<ProfileHiveModel>>()) {
    final box = sl<Box<ProfileHiveModel>>();
    await box.close();
    sl.unregister<Box<ProfileHiveModel>>();
  }
}

/// Helper method to get ProfileBloc.
/// Use this in your widgets instead of directly accessing sl<ProfileBloc>().
ProfileBloc getProfileBloc() => sl<ProfileBloc>();

/// Helper method to check if profile module is initialized.
bool get isProfileModuleInitialized =>
    sl.isRegistered<ProfileRepository>() &&
    sl.isRegistered<GetProfileUseCase>() &&
    sl.isRegistered<ProfileBloc>();

/// Example usage in main.dart or app initialization:
/// 
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   
///   // Initialize Hive
///   await Hive.initFlutter();
///   Hive.registerAdapter(ProfileHiveModelAdapter());
///   Hive.registerAdapter(AppThemeAdapter());
///   
///   // Setup core dependencies
///   setupCoreDependencies();
///   
///   // Setup profile module
///   await setupProfileModule();
///   
///   runApp(MyApp());
/// }
/// ```
/// 
/// Example usage in widgets:
/// 
/// ```dart
/// class ProfilePage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return BlocProvider(
///       create: (_) => getProfileBloc()..add(LoadProfileRequested()),
///       child: ProfileScreen(),
///     );
///   }
/// }
/// ```