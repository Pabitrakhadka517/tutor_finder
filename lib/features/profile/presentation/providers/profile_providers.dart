import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/api/api_client.dart';
import '../../data/datasources/local/profile_local_data_source_impl.dart';
import '../../data/datasources/profile_local_data_source.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/datasources/remote/profile_remote_data_source_impl.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_cached_profile_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../notifiers/profile_notifier.dart';
import '../state/profile_state.dart';

// Data Sources
final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  final box = Hive.box<ProfileModel>('profile_box');
  return ProfileLocalDataSourceImpl(profileBox: box);
});

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ProfileRemoteDataSourceImpl(apiClient: apiClient);
});

// Repository
final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.read(profileRemoteDataSourceProvider),
    localDataSource: ref.read(profileLocalDataSourceProvider),
  );
});

// Use Cases
final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.read(profileRepositoryProvider));
});

final getCachedProfileUseCaseProvider = Provider<GetCachedProfileUseCase>((ref) {
  return GetCachedProfileUseCase(ref.read(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.read(profileRepositoryProvider));
});

// Notifier
final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    getProfileUseCase: ref.read(getProfileUseCaseProvider),
    getCachedProfileUseCase: ref.read(getCachedProfileUseCaseProvider),
    updateProfileUseCase: ref.read(updateProfileUseCaseProvider),
  );
});
