import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_tutors_usecase.dart';
import '../../domain/usecases/get_tutor_by_id_usecase.dart';
import '../state/tutor_state.dart';

/// Notifier for tutor list screen
class TutorListNotifier extends StateNotifier<TutorListState> {
  final GetTutorsUseCase getTutorsUseCase;

  TutorListNotifier({required this.getTutorsUseCase})
    : super(const TutorListState());

  /// Fetch first page of tutors
  Future<void> fetchTutors({
    String? search,
    String? speciality,
    String? sortBy,
    String? order,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      searchQuery: search,
      selectedSpeciality: speciality,
    );

    final result = await getTutorsUseCase(
      GetTutorsParams(
        page: 1,
        limit: 10,
        search: search,
        speciality: speciality,
        sortBy: sortBy,
        order: order,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (tutors) => state = state.copyWith(
        isLoading: false,
        tutors: tutors,
        currentPage: 1,
        hasMore: tutors.length >= 10,
      ),
    );
  }

  /// Load more tutors (pagination)
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    final nextPage = state.currentPage + 1;

    final result = await getTutorsUseCase(
      GetTutorsParams(
        page: nextPage,
        limit: 10,
        search: state.searchQuery,
        speciality: state.selectedSpeciality,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (tutors) => state = state.copyWith(
        isLoading: false,
        tutors: [...state.tutors, ...tutors],
        currentPage: nextPage,
        hasMore: tutors.length >= 10,
      ),
    );
  }

  /// Search tutors
  Future<void> searchTutors(String query) async {
    await fetchTutors(
      search: query.isEmpty ? null : query,
      speciality: state.selectedSpeciality,
    );
  }

  /// Filter by speciality
  Future<void> filterBySpeciality(String? speciality) async {
    await fetchTutors(search: state.searchQuery, speciality: speciality);
  }
}

/// Notifier for tutor detail screen
class TutorDetailNotifier extends StateNotifier<TutorDetailState> {
  final GetTutorByIdUseCase getTutorByIdUseCase;

  TutorDetailNotifier({required this.getTutorByIdUseCase})
    : super(const TutorDetailState());

  Future<void> fetchTutor(String tutorId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await getTutorByIdUseCase(tutorId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (tutor) => state = state.copyWith(isLoading: false, tutor: tutor),
    );
  }
}
