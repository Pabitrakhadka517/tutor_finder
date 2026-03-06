import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../data/datasources/student_remote_datasource.dart';
import '../../data/repositories/student_repository_impl.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/usecases/fetch_recommended_tutors_usecase.dart';
import '../../domain/usecases/search_tutors_usecase.dart';
import '../notifiers/student_notifier.dart';
import '../state/student_state.dart';

// ---------------------------------------------------------------------------
// Data-source & repository
// ---------------------------------------------------------------------------

final studentRemoteDataSourceProvider = Provider<StudentRemoteDataSource>((
  ref,
) {
  return StudentRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider));
});

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepositoryImpl(
    remoteDataSource: ref.read(studentRemoteDataSourceProvider),
  );
});

// ---------------------------------------------------------------------------
// Use-cases
// ---------------------------------------------------------------------------

final fetchRecommendedTutorsUseCaseProvider =
    Provider<FetchRecommendedTutorsUseCase>((ref) {
      return FetchRecommendedTutorsUseCase(ref.read(studentRepositoryProvider));
    });

final searchTutorsUseCaseProvider = Provider<SearchTutorsUseCase>((ref) {
  return SearchTutorsUseCase(ref.read(studentRepositoryProvider));
});

// ---------------------------------------------------------------------------
// Notifiers (state holders)
// ---------------------------------------------------------------------------

final studentNotifierProvider =
    StateNotifierProvider<StudentNotifier, StudentState>((ref) {
      return StudentNotifier(
        fetchRecommendedTutorsUseCase: ref.read(
          fetchRecommendedTutorsUseCaseProvider,
        ),
      );
    });

final studentSearchNotifierProvider =
    StateNotifierProvider<StudentSearchNotifier, StudentSearchState>((ref) {
      return StudentSearchNotifier(
        searchTutorsUseCase: ref.read(searchTutorsUseCaseProvider),
      );
    });
