import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/fetch_recommended_tutors_usecase.dart';
import '../../domain/usecases/search_tutors_usecase.dart';
import '../state/student_state.dart';

/// Notifier for the student dashboard / home.
class StudentNotifier extends StateNotifier<StudentState> {
  final FetchRecommendedTutorsUseCase fetchRecommendedTutorsUseCase;

  StudentNotifier({required this.fetchRecommendedTutorsUseCase})
    : super(const StudentState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await fetchRecommendedTutorsUseCase(
      const FetchRecommendedTutorsParams(),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (tutors) =>
          state = state.copyWith(isLoading: false, recommendedTutors: tutors),
    );
  }
}

/// Notifier for the search tutors screen.
class StudentSearchNotifier extends StateNotifier<StudentSearchState> {
  final SearchTutorsUseCase searchTutorsUseCase;

  StudentSearchNotifier({required this.searchTutorsUseCase})
    : super(const StudentSearchState());

  Future<void> search(String query, {String? subject}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      query: query,
      subject: subject,
      currentPage: 1,
    );

    final result = await searchTutorsUseCase(
      SearchTutorsParams(query: query, subject: subject, page: 1),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (tutors) => state = state.copyWith(
        isLoading: false,
        results: tutors,
        hasMore: tutors.length >= 20,
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final nextPage = state.currentPage + 1;
    state = state.copyWith(isLoading: true);

    final result = await searchTutorsUseCase(
      SearchTutorsParams(
        query: state.query,
        subject: state.subject,
        page: nextPage,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (tutors) => state = state.copyWith(
        isLoading: false,
        results: [...state.results, ...tutors],
        currentPage: nextPage,
        hasMore: tutors.length >= 20,
      ),
    );
  }
}
