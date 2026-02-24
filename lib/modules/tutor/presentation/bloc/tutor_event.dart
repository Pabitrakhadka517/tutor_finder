import 'package:equatable/equatable.dart';

import '../../domain/entities/availability_slot_entity.dart';
import '../../domain/entities/tutor_search_params.dart';

/// Base class for all tutor-related events.
/// Events represent user actions that trigger state changes.
abstract class TutorEvent extends Equatable {
  const TutorEvent();

  @override
  List<Object?> get props => [];
}

// ──────────────── Tutor Search Events ────────────────

/// Event to load initial tutors with given search parameters
class LoadTutorsRequested extends TutorEvent {
  const LoadTutorsRequested({
    required this.searchParams,
    this.forceRefresh = false,
  });

  final TutorSearchParams searchParams;
  final bool forceRefresh;

  @override
  List<Object?> get props => [searchParams, forceRefresh];

  @override
  String toString() =>
      'LoadTutorsRequested(searchParams: $searchParams, forceRefresh: $forceRefresh)';
}

/// Event to load more tutors (pagination)
class LoadMoreTutorsRequested extends TutorEvent {
  const LoadMoreTutorsRequested();

  @override
  String toString() => 'LoadMoreTutorsRequested()';
}

/// Event to apply new filters to tutor search
class ApplyFiltersRequested extends TutorEvent {
  const ApplyFiltersRequested({required this.searchParams});

  final TutorSearchParams searchParams;

  @override
  List<Object?> get props => [searchParams];

  @override
  String toString() => 'ApplyFiltersRequested(searchParams: $searchParams)';
}

/// Event to reset all filters
class ResetFiltersRequested extends TutorEvent {
  const ResetFiltersRequested();

  @override
  String toString() => 'ResetFiltersRequested()';
}

/// Event when search query is changed (with debouncing)
class SearchQueryChanged extends TutorEvent {
  const SearchQueryChanged({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];

  @override
  String toString() => 'SearchQueryChanged(query: $query)';
}

/// Event to refresh tutor list (pull to refresh)
class RefreshTutorsRequested extends TutorEvent {
  const RefreshTutorsRequested();

  @override
  String toString() => 'RefreshTutorsRequested()';
}

// ──────────────── Tutor Detail Events ────────────────

/// Event to load detailed information about a specific tutor
class LoadTutorDetailRequested extends TutorEvent {
  const LoadTutorDetailRequested({
    required this.tutorId,
    this.forceRefresh = false,
  });

  final String tutorId;
  final bool forceRefresh;

  @override
  List<Object?> get props => [tutorId, forceRefresh];

  @override
  String toString() =>
      'LoadTutorDetailRequested(tutorId: $tutorId, forceRefresh: $forceRefresh)';
}

/// Event to clear currently loaded tutor detail
class ClearTutorDetailRequested extends TutorEvent {
  const ClearTutorDetailRequested();

  @override
  String toString() => 'ClearTutorDetailRequested()';
}

// ──────────────── Availability Management Events ────────────────

/// Event to load current user's availability (tutor-only)
class LoadMyAvailabilityRequested extends TutorEvent {
  const LoadMyAvailabilityRequested({this.forceRefresh = false});

  final bool forceRefresh;

  @override
  List<Object?> get props => [forceRefresh];

  @override
  String toString() =>
      'LoadMyAvailabilityRequested(forceRefresh: $forceRefresh)';
}

/// Event to load availability for a specific tutor
class LoadTutorAvailabilityRequested extends TutorEvent {
  const LoadTutorAvailabilityRequested({
    required this.tutorId,
    this.date,
    this.forceRefresh = false,
  });

  final String tutorId;
  final DateTime? date;
  final bool forceRefresh;

  @override
  List<Object?> get props => [tutorId, date, forceRefresh];

  @override
  String toString() =>
      'LoadTutorAvailabilityRequested(tutorId: $tutorId, date: $date)';
}

/// Event to update current user's availability (tutor-only)
class UpdateAvailabilityRequested extends TutorEvent {
  const UpdateAvailabilityRequested({required this.slots});

  final List<AvailabilitySlotEntity> slots;

  @override
  List<Object?> get props => [slots];

  @override
  String toString() =>
      'UpdateAvailabilityRequested(slotsCount: ${slots.length})';
}

// ──────────────── Verification Events ────────────────

/// Event to submit profile for verification (tutor-only)
class SubmitVerificationRequested extends TutorEvent {
  const SubmitVerificationRequested();

  @override
  String toString() => 'SubmitVerificationRequested()';
}

// ──────────────── Cache Management Events ────────────────

/// Event to clear all tutor cache
class ClearTutorCacheRequested extends TutorEvent {
  const ClearTutorCacheRequested();

  @override
  String toString() => 'ClearTutorCacheRequested()';
}

/// Event to clear only search cache (when filters change significantly)
class ClearSearchCacheRequested extends TutorEvent {
  const ClearSearchCacheRequested();

  @override
  String toString() => 'ClearSearchCacheRequested()';
}
