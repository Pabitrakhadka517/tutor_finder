import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/entities/tutor_search_params.dart';
import '../../domain/failures/tutor_failures.dart';
import '../../domain/usecases/get_my_availability_usecase.dart';
import '../../domain/usecases/get_tutor_detail_usecase.dart';
import '../../domain/usecases/get_tutors_usecase.dart';
import '../../domain/usecases/set_availability_usecase.dart';
import '../../domain/usecases/submit_verification_usecase.dart';
import 'tutor_event.dart';
import 'tutor_state.dart';

/// BLoC for managing tutor-related state and business logic.
/// Handles search, filtering, pagination, and tutor management operations.
class TutorBloc extends Bloc<TutorEvent, TutorState> {
  TutorBloc({
    required this.getTutorsUsecase,
    required this.getTutorDetailUsecase,
    required this.getMyAvailabilityUsecase,
    required this.setAvailabilityUsecase,
    required this.submitVerificationUsecase,
  }) : super(const TutorInitial()) {
    // Register event handlers
    on<LoadTutorsRequested>(_onLoadTutorsRequested);
    on<LoadMoreTutorsRequested>(_onLoadMoreTutorsRequested);
    on<ApplyFiltersRequested>(_onApplyFiltersRequested);
    on<ResetFiltersRequested>(_onResetFiltersRequested);
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: _debounce(const Duration(milliseconds: 300)),
    );
    on<RefreshTutorsRequested>(_onRefreshTutorsRequested);

    on<LoadTutorDetailRequested>(_onLoadTutorDetailRequested);
    on<ClearTutorDetailRequested>(_onClearTutorDetailRequested);

    on<LoadMyAvailabilityRequested>(_onLoadMyAvailabilityRequested);
    on<LoadTutorAvailabilityRequested>(_onLoadTutorAvailabilityRequested);
    on<UpdateAvailabilityRequested>(_onUpdateAvailabilityRequested);

    on<SubmitVerificationRequested>(_onSubmitVerificationRequested);

    on<ClearTutorCacheRequested>(_onClearTutorCacheRequested);
    on<ClearSearchCacheRequested>(_onClearSearchCacheRequested);
  }

  final GetTutorsUsecase getTutorsUsecase;
  final GetTutorDetailUsecase getTutorDetailUsecase;
  final GetMyAvailabilityUsecase getMyAvailabilityUsecase;
  final SetAvailabilityUsecase setAvailabilityUsecase;
  final SubmitVerificationUsecase submitVerificationUsecase;

  // Current search parameters to maintain state between pagination calls
  TutorSearchParams? _currentSearchParams;
  Timer? _searchDebounceTimer;

  // ──────────────── Search & Filtering Handlers ────────────────

  Future<void> _onLoadTutorsRequested(
    LoadTutorsRequested event,
    Emitter<TutorState> emit,
  ) async {
    // Cache current search params
    _currentSearchParams = event.searchParams;

    // Only show loading if not force refresh (to avoid jarring UX)
    if (!event.forceRefresh || state is! TutorLoaded) {
      emit(const TutorLoading());
    } else if (event.forceRefresh && state is TutorLoaded) {
      emit((state as TutorLoaded).copyWith(isRefreshing: true));
    }

    final result = await getTutorsUsecase(
      GetTutorsParams(searchParams: event.searchParams),
    );

    result.fold(
      (failure) => emit(
        TutorError(
          message: failure.message,
          errorType: _mapFailureToErrorType(failure),
          previousState: state is TutorLoaded ? state : null,
        ),
      ),
      (tutorListResult) => emit(
        TutorLoaded(
          tutorListResult: tutorListResult,
          currentSearchParams: event.searchParams,
          isRefreshing: false,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreTutorsRequested(
    LoadMoreTutorsRequested event,
    Emitter<TutorState> emit,
  ) async {
    // Can only load more if currently in loaded state with next page available
    if (state is! TutorLoaded) return;

    final currentState = state as TutorLoaded;

    if (!currentState.hasNextPage || _currentSearchParams == null) return;

    // Emit loading more state
    emit(
      TutorLoadingMore(
        currentTutorListResult: currentState.tutorListResult,
        currentSearchParams: currentState.currentSearchParams,
      ),
    );

    // Get next page parameters
    final nextPageParams = _currentSearchParams!.nextPage;

    final result = await getTutorsUsecase(
      GetTutorsParams(searchParams: nextPageParams),
    );

    result.fold(
      (failure) => emit(
        TutorError(
          message: failure.message,
          errorType: _mapFailureToErrorType(failure),
          previousState: currentState, // Restore previous state
        ),
      ),
      (newPageResult) {
        // Merge current tutors with new page
        final mergedResult = currentState.tutorListResult.mergeWithNewPage(
          newPageResult,
        );

        emit(
          TutorLoaded(
            tutorListResult: mergedResult,
            currentSearchParams: nextPageParams,
          ),
        );
      },
    );
  }

  Future<void> _onApplyFiltersRequested(
    ApplyFiltersRequested event,
    Emitter<TutorState> emit,
  ) async {
    // Apply filters is essentially a new search, so delegate to load tutors
    add(LoadTutorsRequested(searchParams: event.searchParams));
  }

  Future<void> _onResetFiltersRequested(
    ResetFiltersRequested event,
    Emitter<TutorState> emit,
  ) async {
    // Reset to default search parameters
    const defaultParams = TutorSearchParams();
    add(const LoadTutorsRequested(searchParams: defaultParams));
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<TutorState> emit,
  ) async {
    // Update search params with new query
    final currentParams = _currentSearchParams ?? const TutorSearchParams();
    final newParams = currentParams.copyWith(search: event.query).firstPage;

    add(LoadTutorsRequested(searchParams: newParams));
  }

  Future<void> _onRefreshTutorsRequested(
    RefreshTutorsRequested event,
    Emitter<TutorState> emit,
  ) async {
    // Refresh using current search params
    final params = _currentSearchParams ?? const TutorSearchParams();
    add(LoadTutorsRequested(searchParams: params, forceRefresh: true));
  }

  // ──────────────── Tutor Detail Handlers ────────────────

  Future<void> _onLoadTutorDetailRequested(
    LoadTutorDetailRequested event,
    Emitter<TutorState> emit,
  ) async {
    // Only show loading if not force refresh or no current detail
    if (!event.forceRefresh || state is! TutorDetailLoaded) {
      emit(TutorDetailLoading(tutorId: event.tutorId));
    }

    final result = await getTutorDetailUsecase(
      GetTutorDetailParams(tutorId: event.tutorId),
    );

    result.fold(
      (failure) => emit(
        TutorError(
          message: failure.message,
          errorType: _mapFailureToErrorType(failure),
          previousState: state is TutorDetailLoaded ? state : null,
        ),
      ),
      (tutor) => emit(TutorDetailLoaded(tutor: tutor)),
    );
  }

  Future<void> _onClearTutorDetailRequested(
    ClearTutorDetailRequested event,
    Emitter<TutorState> emit,
  ) async {
    emit(const TutorInitial());
  }

  // ──────────────── Availability Handlers ────────────────

  Future<void> _onLoadMyAvailabilityRequested(
    LoadMyAvailabilityRequested event,
    Emitter<TutorState> emit,
  ) async {
    if (!event.forceRefresh || state is! TutorAvailabilityLoaded) {
      emit(const TutorAvailabilityLoading());
    }

    final result = await getMyAvailabilityUsecase();

    result.fold(
      (failure) => emit(
        TutorError(
          message: failure.message,
          errorType: _mapFailureToErrorType(failure),
          previousState: state is TutorAvailabilityLoaded ? state : null,
        ),
      ),
      (slots) => emit(TutorAvailabilityLoaded(availabilitySlots: slots)),
    );
  }

  Future<void> _onLoadTutorAvailabilityRequested(
    LoadTutorAvailabilityRequested event,
    Emitter<TutorState> emit,
  ) async {
    if (!event.forceRefresh || state is! TutorAvailabilityLoaded) {
      emit(const TutorAvailabilityLoading());
    }

    // Load tutor availability using detail use case or availability use case
    final result = await getMyAvailabilityUsecase();

    result.fold(
      (failure) => emit(
        TutorError(
          message: failure.message,
          errorType: _mapFailureToErrorType(failure),
          previousState: state is TutorAvailabilityLoaded ? state : null,
        ),
      ),
      (slots) => emit(TutorAvailabilityLoaded(availabilitySlots: slots)),
    );
  }

  Future<void> _onUpdateAvailabilityRequested(
    UpdateAvailabilityRequested event,
    Emitter<TutorState> emit,
  ) async {
    emit(
      TutorUpdating(operation: 'updating_availability', currentState: state),
    );

    final result = await setAvailabilityUsecase(
      SetAvailabilityParams(slots: event.slots),
    );

    result.fold(
      (failure) => emit(
        TutorError(
          message: failure.message,
          errorType: _mapFailureToErrorType(failure),
          previousState: state,
        ),
      ),
      (_) {
        // Successfully updated, reload availability
        add(const LoadMyAvailabilityRequested(forceRefresh: true));
      },
    );
  }

  // ──────────────── Verification Handlers ────────────────

  Future<void> _onSubmitVerificationRequested(
    SubmitVerificationRequested event,
    Emitter<TutorState> emit,
  ) async {
    emit(
      TutorUpdating(operation: 'submitting_verification', currentState: state),
    );

    final result = await submitVerificationUsecase();

    result.fold(
      (failure) => emit(
        TutorError(
          message: failure.message,
          errorType: _mapFailureToErrorType(failure),
          previousState: state,
        ),
      ),
      (_) => emit(
        const TutorVerificationSubmitted(
          message:
              'Verification submitted successfully. We will review your profile and notify you of the decision.',
        ),
      ),
    );
  }

  // ──────────────── Cache Management Handlers ────────────────

  Future<void> _onClearTutorCacheRequested(
    ClearTutorCacheRequested event,
    Emitter<TutorState> emit,
  ) async {
    // This would typically be handled by repository
    // For now, just refresh current data
    if (_currentSearchParams != null) {
      add(
        LoadTutorsRequested(
          searchParams: _currentSearchParams!,
          forceRefresh: true,
        ),
      );
    }
  }

  Future<void> _onClearSearchCacheRequested(
    ClearSearchCacheRequested event,
    Emitter<TutorState> emit,
  ) async {
    // Similar to cache clear, refresh current search
    if (_currentSearchParams != null) {
      add(
        LoadTutorsRequested(
          searchParams: _currentSearchParams!,
          forceRefresh: true,
        ),
      );
    }
  }

  // ──────────────── Helper Methods ────────────────

  TutorErrorType _mapFailureToErrorType(TutorFailure failure) {
    if (failure is TutorNetworkFailure) return TutorErrorType.network;
    if (failure is TutorServerFailure) return TutorErrorType.server;
    if (failure is TutorValidationFailure) return TutorErrorType.validation;
    if (failure is TutorNotFoundFailure) return TutorErrorType.notFound;
    if (failure is TutorAuthFailure) return TutorErrorType.unauthorized;
    if (failure is TutorBusinessFailure) return TutorErrorType.forbidden;
    if (failure is TutorCacheFailure) return TutorErrorType.cache;
    return TutorErrorType.unknown;
  }

  /// Debounce transformer for search input
  EventTransformer<SearchQueryChanged> _debounce<SearchQueryChanged>(
    Duration duration,
  ) {
    return (events, mapper) {
      return events.debounceTime(duration).switchMap(mapper);
    };
  }

  @override
  Future<void> close() {
    _searchDebounceTimer?.cancel();
    return super.close();
  }
}

/// Extension to add copyWith method to TutorLoaded state
extension TutorLoadedX on TutorLoaded {
  TutorLoaded copyWith({bool? isRefreshing}) {
    return TutorLoaded(
      tutorListResult: tutorListResult,
      currentSearchParams: currentSearchParams,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
