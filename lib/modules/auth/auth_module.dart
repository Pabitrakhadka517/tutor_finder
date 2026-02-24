import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/auth_remote_datasource_impl.dart';
import 'data/interceptors/auth_interceptor.dart';
import 'data/models/user_hive_model.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/forgot_password_usecase.dart';
import 'domain/usecases/get_current_user_usecase.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/refresh_token_usecase.dart';
import 'domain/usecases/register_usecase.dart';
import 'domain/usecases/reset_password_usecase.dart';
import 'presentation/bloc/auth_bloc.dart';

/// Global service locator instance for the entire app.
final sl = GetIt.instance;

/// Initializes the Auth Module's dependency injection graph.
///
/// Must be called during app startup, **after** `Hive.initFlutter()` and
/// **before** registering the Hive adapters.
///
/// Example usage in `main()`:
/// ```dart
/// await Hive.initFlutter();
/// await initAuthModule();
/// Hive.registerAdapter(UserHiveModelAdapter());
/// runApp(MyApp());
/// ```
Future<void> initAuthModule() async {
  // ╭─────────────────────────────────────────────────────────────────────────╮
  // │ 1. Open Hive boxes                                                      │
  // ╰─────────────────────────────────────────────────────────────────────────╯

  // Don't register the adapter here — let the caller do it to avoid conflicts.
  // Hive.registerAdapter(UserHiveModelAdapter());

  final tokenBox = await Hive.openBox<String>('auth_tokens');
  final userBox = await Hive.openBox<UserHiveModel>('auth_user');

  sl
    ..registerLazySingleton<Box<String>>(
      () => tokenBox,
      instanceName: 'tokenBox',
    )
    ..registerLazySingleton<Box<UserHiveModel>>(
      () => userBox,
      instanceName: 'userBox',
    );

  // ╭─────────────────────────────────────────────────────────────────────────╮
  // │ 2. Dio setup with base configuration                                   │
  // ╰─────────────────────────────────────────────────────────────────────────╯

  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // The interceptor is registered later during BLoC creation to access the callback.
    return dio;
  });

  // ╭─────────────────────────────────────────────────────────────────────────╮
  // │ 3. Data Sources                                                         │
  // ╰─────────────────────────────────────────────────────────────────────────╯

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      tokenBox: sl.get<Box<String>>(instanceName: 'tokenBox'),
      userBox: sl.get<Box<UserHiveModel>>(instanceName: 'userBox'),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  // ╭─────────────────────────────────────────────────────────────────────────╮
  // │ 4. Repository                                                           │
  // ╰─────────────────────────────────────────────────────────────────────────╯

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl(), local: sl()),
  );

  // ╭─────────────────────────────────────────────────────────────────────────╮
  // │ 5. Use Cases                                                            │
  // ╰─────────────────────────────────────────────────────────────────────────╯

  sl
    ..registerLazySingleton(() => RegisterUseCase(sl()))
    ..registerLazySingleton(() => LoginUseCase(sl()))
    ..registerLazySingleton(() => RefreshTokenUseCase(sl()))
    ..registerLazySingleton(() => LogoutUseCase(sl()))
    ..registerLazySingleton(() => ForgotPasswordUseCase(sl()))
    ..registerLazySingleton(() => ResetPasswordUseCase(sl()))
    ..registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // ╭─────────────────────────────────────────────────────────────────────────╮
  // │ 6. BLoC Factory (with interceptor setup)                               │
  // ╰─────────────────────────────────────────────────────────────────────────╯

  sl.registerFactory<AuthBloc>(() {
    // Set up the AuthInterceptor when creating the BLoC.
    final dio = sl<Dio>();
    final localDataSource = sl<AuthLocalDataSource>();

    final authInterceptor = AuthInterceptor(
      dio: dio,
      localDataSource: localDataSource,
      onForceLogout: () {
        // This callback can trigger a global logout event, like emitting
        // LogoutRequested to the BLoC from outside. For now, just a print.
        // TODO: Wire this up to your app's global state / navigation logic.
        print('[AuthInterceptor] Force logout triggered');
      },
    );

    // Add the interceptor to Dio if not already present.
    if (!dio.interceptors.any((i) => i is AuthInterceptor)) {
      dio.interceptors.add(authInterceptor);
    }

    return AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      refreshTokenUseCase: sl(),
      forgotPasswordUseCase: sl(),
      resetPasswordUseCase: sl(),
      getCurrentUserUseCase: sl(),
      authRepository: sl(),
    );
  });
}

/// Determine the API base URL based on platform and build mode.
///
/// This mirrors the existing logic in `ApiEndpoints.baseUrl`.
String _getBaseUrl() {
  // You can import and use the existing ApiEndpoints.baseUrl if available,
  // or inline the logic like this for the auth module specifically:
  return 'http://10.0.2.2:4000'; // Adjust as needed
}

/// Clean up resources when the app terminates.
Future<void> disposeAuthModule() async {
  await sl.reset();
}
