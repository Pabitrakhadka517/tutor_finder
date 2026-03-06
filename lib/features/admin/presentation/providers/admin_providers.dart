import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/admin_repository.dart';
import '../notifiers/admin_notifier.dart';
import '../state/admin_state.dart';

// ================= Data Sources =================
final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>(
  (ref) => AdminRemoteDataSourceImpl(
    apiClient: ref.read(apiClientProvider),
  ),
);

// ================= Repository =================
final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepositoryImpl(
    remoteDataSource: ref.read(adminRemoteDataSourceProvider),
  ),
);

// ================= Notifier =================
final adminNotifierProvider =
    StateNotifierProvider<AdminNotifier, AdminState>(
  (ref) => AdminNotifier(
    repository: ref.read(adminRepositoryProvider),
  ),
);
