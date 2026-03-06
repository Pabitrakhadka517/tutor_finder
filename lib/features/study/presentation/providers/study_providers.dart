import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../data/datasources/study_remote_datasource.dart';
import '../../data/repositories/study_repository_impl.dart';
import '../../domain/study_repository.dart';
import '../notifiers/study_notifier.dart';
import '../state/study_state.dart';

// ================= Data Sources =================
final studyRemoteDataSourceProvider = Provider<StudyRemoteDataSource>(
  (ref) => StudyRemoteDataSourceImpl(
    apiClient: ref.read(apiClientProvider),
  ),
);

// ================= Repository =================
final studyRepositoryProvider = Provider<StudyRepository>(
  (ref) => StudyRepositoryImpl(
    remoteDataSource: ref.read(studyRemoteDataSourceProvider),
  ),
);

// ================= Notifier =================
final studyNotifierProvider =
    StateNotifierProvider<StudyNotifier, StudyState>(
  (ref) => StudyNotifier(
    repository: ref.read(studyRepositoryProvider),
  ),
);
