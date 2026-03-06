import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Domain
import 'domain/repositories/dashboard_repository.dart';
import 'domain/usecases/get_student_dashboard_usecase.dart';
import 'domain/usecases/get_tutor_dashboard_usecase.dart';
import 'domain/usecases/refresh_dashboard_usecase.dart';
import 'domain/usecases/dashboard_analytics_usecase.dart';

// Data
import 'data/datasources/dashboard_local_datasource.dart';
import 'data/datasources/dashboard_remote_datasource.dart';
import 'data/repositories/dashboard_repository_impl.dart';

// Presentation
import 'presentation/controllers/dashboard_controller.dart';

/// Dashboard module dependency injection setup
class DashboardModule {
  static void configure(GetIt getIt) {
    // External dependencies (should already be registered)
    // getIt.registerLazySingleton<Dio>(() => Dio());
    // getIt.registerSingletonAsync<SharedPreferences>(
    //   () => SharedPreferences.getInstance(),
    // );

    // Data sources
    getIt.registerLazySingleton<DashboardRemoteDataSource>(
      () => DashboardRemoteDataSourceImpl(dio: getIt<Dio>()),
    );

    getIt.registerLazySingleton<IDashboardLocalDataSource>(
      () => DashboardLocalDataSource(getIt<SharedPreferences>()),
    );

    // Repository
    getIt.registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(
        getIt<DashboardRemoteDataSource>(),
        getIt<IDashboardLocalDataSource>(),
      ),
    );

    // Use cases
    getIt.registerLazySingleton<GetStudentDashboardUseCase>(
      () => GetStudentDashboardUseCase(getIt<DashboardRepository>()),
    );

    getIt.registerLazySingleton<GetTutorDashboardUseCase>(
      () => GetTutorDashboardUseCase(getIt<DashboardRepository>()),
    );

    getIt.registerLazySingleton<RefreshDashboardUseCase>(
      () => RefreshDashboardUseCase(getIt<DashboardRepository>()),
    );

    getIt.registerLazySingleton<DashboardAnalyticsUseCase>(
      () => DashboardAnalyticsUseCase(getIt<DashboardRepository>()),
    );

    // Controllers
    getIt.registerFactory<DashboardController>(
      () => DashboardController(
        getIt<GetStudentDashboardUseCase>(),
        getIt<GetTutorDashboardUseCase>(),
        getIt<RefreshDashboardUseCase>(),
        getIt<DashboardAnalyticsUseCase>(),
      ),
    );
  }

  /// Clean up resources when module is disposed
  static void dispose(GetIt getIt) {
    if (getIt.isRegistered<DashboardController>()) {
      getIt.unregister<DashboardController>();
    }
    if (getIt.isRegistered<DashboardAnalyticsUseCase>()) {
      getIt.unregister<DashboardAnalyticsUseCase>();
    }
    if (getIt.isRegistered<RefreshDashboardUseCase>()) {
      getIt.unregister<RefreshDashboardUseCase>();
    }
    if (getIt.isRegistered<GetTutorDashboardUseCase>()) {
      getIt.unregister<GetTutorDashboardUseCase>();
    }
    if (getIt.isRegistered<GetStudentDashboardUseCase>()) {
      getIt.unregister<GetStudentDashboardUseCase>();
    }
    if (getIt.isRegistered<DashboardRepository>()) {
      getIt.unregister<DashboardRepository>();
    }
    if (getIt.isRegistered<IDashboardLocalDataSource>()) {
      getIt.unregister<IDashboardLocalDataSource>();
    }
    if (getIt.isRegistered<DashboardRemoteDataSource>()) {
      getIt.unregister<DashboardRemoteDataSource>();
    }
  }
}
