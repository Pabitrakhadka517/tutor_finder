import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/providers/shared_prefs_provider.dart';
import '../../data/datasources/dashboard_local_datasource.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/dashboard_repository.dart';
import '../notifiers/dashboard_notifier.dart';
import '../state/dashboard_state.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardRemoteDataSourceImpl(dio: apiClient.dio);
});

final dashboardLocalDataSourceProvider = Provider<IDashboardLocalDataSource>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DashboardLocalDataSource(prefs);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final remoteDataSource = ref.watch(dashboardRemoteDataSourceProvider);
  final localDataSource = ref.watch(dashboardLocalDataSourceProvider);
  return DashboardRepositoryImpl(remoteDataSource, localDataSource);
});

final dashboardNotifierProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      final repository = ref.watch(dashboardRepositoryProvider);
      final remoteDataSource = ref.watch(dashboardRemoteDataSourceProvider);
      return DashboardNotifier(
        repository: repository,
        remoteDataSource: remoteDataSource,
      );
    });
