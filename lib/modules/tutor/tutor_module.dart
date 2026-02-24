import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import 'data/datasources/tutor_local_datasource.dart';
import 'data/datasources/tutor_local_datasource_impl.dart';
import 'data/datasources/tutor_remote_datasource.dart';
import 'data/datasources/tutor_remote_datasource_impl.dart';
import 'data/models/tutor_hive_model.dart';
import 'data/repositories/tutor_repository_impl.dart';
import 'domain/repositories/tutor_repository.dart';
import 'domain/usecases/get_tutor_detail_usecase.dart';
import 'domain/usecases/get_tutors_usecase.dart';
import 'domain/usecases/set_availability_usecase.dart';
import 'domain/usecases/get_my_availability_usecase.dart';
import 'domain/usecases/submit_verification_usecase.dart';
import 'presentation/bloc/tutor_bloc.dart';

/// Module for registering tutor-related dependencies with get_it.
/// This ensures proper dependency injection and separation of concerns.
class TutorModule {
  static Future<void> init(GetIt getIt) async {
    // ── External Dependencies ─────────────────────────────────────────────

    // HTTP Client (Dio) - if not already registered
    if (!getIt.isRegistered<Dio>()) {
      getIt.registerLazySingleton<Dio>(() {
        final dio = Dio();

        // Configure base options
        dio.options = BaseOptions(
          baseUrl: const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'https://api.tutorfinder.com/v1',
          ),
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        // Add interceptors
        dio.interceptors.addAll([
          // Logging interceptor (only in debug mode)
          if (const bool.fromEnvironment('dart.vm.product') == false)
            LogInterceptor(
              request: true,
              requestBody: true,
              responseBody: true,
              error: true,
              logPrint: (obj) => print(obj), // Use your preferred logger
            ),

          // Auth interceptor (add auth token to requests)
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              // TODO: Add authentication token from secure storage
              // final token = await SecureStorage.getAuthToken();
              // if (token != null) {
              //   options.headers['Authorization'] = 'Bearer $token';
              // }
              handler.next(options);
            },
            onError: (error, handler) {
              // TODO: Handle token refresh on 401 errors
              handler.next(error);
            },
          ),
        ]);

        return dio;
      });
    }

    // Hive Database - if not already initialized
    if (!getIt.isRegistered<Box<TutorHiveModel>>()) {
      // Register Hive adapters
      if (!Hive.isAdapterRegistered(TutorHiveModelAdapter().typeId)) {
        Hive.registerAdapter(TutorHiveModelAdapter());
      }
      if (!Hive.isAdapterRegistered(
        TutorSearchCacheHiveModelAdapter().typeId,
      )) {
        Hive.registerAdapter(TutorSearchCacheHiveModelAdapter());
      }
      if (!Hive.isAdapterRegistered(
        AvailabilitySlotHiveModelAdapter().typeId,
      )) {
        Hive.registerAdapter(AvailabilitySlotHiveModelAdapter());
      }

      // Open tutor cache box
      final tutorBox = await Hive.openBox<TutorHiveModel>('tutors');
      getIt.registerSingleton<Box<TutorHiveModel>>(tutorBox);

      // Open search results cache box
      final searchCacheBox = await Hive.openBox<TutorSearchCacheHiveModel>(
        'search_cache',
      );
      getIt.registerSingleton<Box<TutorSearchCacheHiveModel>>(searchCacheBox);

      // Open availability box
      final availabilityBox =
          await Hive.openBox<List<AvailabilitySlotHiveModel>>('availability');
      getIt.registerSingleton<Box<List<AvailabilitySlotHiveModel>>>(
        availabilityBox,
      );
    }

    // ── Data Layer Dependencies ───────────────────────────────────────────

    // Remote data source
    getIt.registerLazySingleton<TutorRemoteDatasource>(
      () => TutorRemoteDatasourceImpl(dio: getIt<Dio>()),
    );

    // Local data source
    getIt.registerLazySingleton<TutorLocalDatasource>(
      () => TutorLocalDatasourceImpl(
        tutorBox: getIt<Box<TutorHiveModel>>(),
        searchCacheBox: getIt<Box<TutorSearchCacheHiveModel>>(),
        availabilityBox: getIt<Box<List<AvailabilitySlotHiveModel>>>(),
      ),
    );

    // Repository implementation
    getIt.registerLazySingleton<TutorRepository>(
      () => TutorRepositoryImpl(
        remoteDatasource: getIt<TutorRemoteDatasource>(),
        localDatasource: getIt<TutorLocalDatasource>(),
      ),
    );

    // ── Domain Layer Dependencies ─────────────────────────────────────────

    // Use cases
    getIt.registerLazySingleton<GetTutorsUsecase>(
      () => GetTutorsUsecase(getIt<TutorRepository>()),
    );

    getIt.registerLazySingleton<GetTutorDetailUsecase>(
      () => GetTutorDetailUsecase(getIt<TutorRepository>()),
    );

    getIt.registerLazySingleton<GetMyAvailabilityUsecase>(
      () => GetMyAvailabilityUsecase(getIt<TutorRepository>()),
    );

    getIt.registerLazySingleton<SetAvailabilityUsecase>(
      () => SetAvailabilityUsecase(getIt<TutorRepository>()),
    );

    getIt.registerLazySingleton<SubmitVerificationUsecase>(
      () => SubmitVerificationUsecase(getIt<TutorRepository>()),
    );

    // ── Presentation Layer Dependencies ───────────────────────────────────

    // BLoC - Register as factory to create new instances when needed
    getIt.registerFactory<TutorBloc>(
      () => TutorBloc(
        getTutorsUsecase: getIt<GetTutorsUsecase>(),
        getTutorDetailUsecase: getIt<GetTutorDetailUsecase>(),
        getMyAvailabilityUsecase: getIt<GetMyAvailabilityUsecase>(),
        setAvailabilityUsecase: getIt<SetAvailabilityUsecase>(),
        submitVerificationUsecase: getIt<SubmitVerificationUsecase>(),
      ),
    );
  }

  /// Clean up resources when the app is disposed
  static Future<void> dispose() async {
    final getIt = GetIt.instance;

    // Close Hive boxes
    if (getIt.isRegistered<Box<TutorHiveModel>>()) {
      await getIt<Box<TutorHiveModel>>().close();
    }

    if (getIt.isRegistered<Box>(instanceName: 'searchCache')) {
      await getIt<Box>(instanceName: 'searchCache').close();
    }

    // Reset registrations (optional, useful for testing)
    await getIt.reset();
  }

  /// Reset the module (useful for testing)
  static Future<void> reset() async {
    await dispose();
    await init(GetIt.instance);
  }
}

/// Extension to provide easy access to tutor dependencies
extension TutorModuleGetIt on GetIt {
  // Quick access getters for common dependencies
  TutorRepository get tutorRepository => get<TutorRepository>();
  TutorBloc get tutorBloc => get<TutorBloc>();

  // Use case getters
  GetTutorsUsecase get getTutorsUsecase => get<GetTutorsUsecase>();
  GetTutorDetailUsecase get getTutorDetailUsecase =>
      get<GetTutorDetailUsecase>();
  GetMyAvailabilityUsecase get getMyAvailabilityUsecase =>
      get<GetMyAvailabilityUsecase>();
  SetAvailabilityUsecase get setAvailabilityUsecase =>
      get<SetAvailabilityUsecase>();
  SubmitVerificationUsecase get submitVerificationUsecase =>
      get<SubmitVerificationUsecase>();
}

/// Helper to provide TutorBloc to widget tree
/// Usage: BlocProvider(create: (context) => TutorBlocProvider.create(), ...)
class TutorBlocProvider {
  static TutorBloc create() => GetIt.instance<TutorBloc>();
}
