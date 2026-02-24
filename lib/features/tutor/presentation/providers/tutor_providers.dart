import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../data/datasources/remote/tutor_remote_datasource_impl.dart';
import '../../data/datasources/tutor_remote_datasource.dart';
import '../../data/repositories/tutor_repository_impl.dart';
import '../../domain/repositories/tutor_repository.dart';
import '../../domain/usecases/get_tutors_usecase.dart';
import '../../domain/usecases/get_tutor_by_id_usecase.dart';
import '../notifiers/tutor_notifier.dart';
import '../state/tutor_state.dart';

// Data Source
final tutorRemoteDataSourceProvider = Provider<TutorRemoteDataSource>((ref) {
  return TutorRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider));
});

// Repository
final tutorRepositoryProvider = Provider<TutorRepository>((ref) {
  return TutorRepositoryImpl(
    remoteDataSource: ref.read(tutorRemoteDataSourceProvider),
  );
});

// Use Cases
final getTutorsUseCaseProvider = Provider<GetTutorsUseCase>((ref) {
  return GetTutorsUseCase(ref.read(tutorRepositoryProvider));
});

final getTutorByIdUseCaseProvider = Provider<GetTutorByIdUseCase>((ref) {
  return GetTutorByIdUseCase(ref.read(tutorRepositoryProvider));
});

// Notifiers
final tutorListNotifierProvider =
    StateNotifierProvider<TutorListNotifier, TutorListState>((ref) {
      return TutorListNotifier(
        getTutorsUseCase: ref.read(getTutorsUseCaseProvider),
      );
    });

final tutorDetailNotifierProvider =
    StateNotifierProvider<TutorDetailNotifier, TutorDetailState>((ref) {
      return TutorDetailNotifier(
        getTutorByIdUseCase: ref.read(getTutorByIdUseCaseProvider),
      );
    });
