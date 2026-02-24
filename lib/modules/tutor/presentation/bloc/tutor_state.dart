import 'package:equatable/equatable.dart';

import '../../domain/entities/availability_slot_entity.dart';
import '../../domain/entities/tutor_entity.dart';
import '../../domain/entities/tutor_list_result_entity.dart';
import '../../domain/entities/tutor_search_params.dart';

/// Base class for all tutor-related states.
/// States represent the current condition of the tutor feature.
abstract class TutorState extends Equatable {
  const TutorState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the tutor module is first loaded
class TutorInitial extends TutorState {
  const TutorInitial();

  @override
  String toString() => 'TutorInitial()';
}

/// State when tutors are being loaded for the first time
class TutorLoading extends TutorState {
  const TutorLoading();

  @override
  String toString() => 'TutorLoading()';
}

/// State when tutors have been successfully loaded
class TutorLoaded extends TutorState {
  const TutorLoaded({
    required this.tutorListResult,
    required this.currentSearchParams,
    this.isRefreshing = false,
  });

  final TutorListResultEntity tutorListResult;
  final TutorSearchParams currentSearchParams;
  final bool isRefreshing;

  /// Helper getters
  List<TutorEntity> get tutors => tutorListResult.tutors;
  bool get hasNextPage => tutorListResult.hasNextPage;
  bool get isEmpty => tutorListResult.isEmpty;
  int get totalCount => tutorListResult.total;
  String get itemRangeDisplay => tutorListResult.itemRangeDisplay;

  @override
  List<Object?> get props => [
    tutorListResult,
    currentSearchParams,
    isRefreshing,
  ];

  @override
  String toString() =>
      'TutorLoaded(count: ${tutors.length}, total: $totalCount, hasNext: $hasNextPage)';
}

/// State when loading more tutors (pagination)
class TutorLoadingMore extends TutorState {
  const TutorLoadingMore({
    required this.currentTutorListResult,
    required this.currentSearchParams,
  });

  final TutorListResultEntity currentTutorListResult;
  final TutorSearchParams currentSearchParams;

  /// Helper getters
  List<TutorEntity> get currentTutors => currentTutorListResult.tutors;
  int get currentCount => currentTutors.length;

  @override
  List<Object?> get props => [currentTutorListResult, currentSearchParams];

  @override
  String toString() => 'TutorLoadingMore(currentCount: $currentCount)';
}

/// State when tutor detail is being loaded
class TutorDetailLoading extends TutorState {
  const TutorDetailLoading({required this.tutorId});

  final String tutorId;

  @override
  List<Object?> get props => [tutorId];

  @override
  String toString() => 'TutorDetailLoading(tutorId: $tutorId)';
}

/// State when tutor detail has been successfully loaded
class TutorDetailLoaded extends TutorState {
  const TutorDetailLoaded({required this.tutor});

  final TutorEntity tutor;

  @override
  List<Object?> get props => [tutor];

  @override
  String toString() => 'TutorDetailLoaded(tutor: ${tutor.fullName})';
}

/// State when availability is being loaded
class TutorAvailabilityLoading extends TutorState {
  const TutorAvailabilityLoading();

  @override
  String toString() => 'TutorAvailabilityLoading()';
}

/// State when availability has been successfully loaded
class TutorAvailabilityLoaded extends TutorState {
  const TutorAvailabilityLoaded({required this.availabilitySlots});

  final List<AvailabilitySlotEntity> availabilitySlots;

  /// Helper getters
  bool get hasSlots => availabilitySlots.isNotEmpty;
  int get slotCount => availabilitySlots.length;
  List<AvailabilitySlotEntity> get futureSlots =>
      availabilitySlots.where((slot) => slot.isFuture).toList();
  List<AvailabilitySlotEntity> get availableSlots => availabilitySlots
      .where((slot) => slot.isAvailable && slot.isFuture)
      .toList();

  @override
  List<Object?> get props => [availabilitySlots];

  @override
  String toString() => 'TutorAvailabilityLoaded(slotsCount: $slotCount)';
}

/// State when tutors or availability are being updated
class TutorUpdating extends TutorState {
  const TutorUpdating({required this.operation, this.currentState});

  final String
  operation; // e.g., 'updating_availability', 'submitting_verification'
  final TutorState? currentState; // Previous state to maintain UI

  @override
  List<Object?> get props => [operation, currentState];

  @override
  String toString() => 'TutorUpdating(operation: $operation)';
}

/// State when verification has been successfully submitted
class TutorVerificationSubmitted extends TutorState {
  const TutorVerificationSubmitted({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'TutorVerificationSubmitted(message: $message)';
}

/// State when an error occurs
class TutorError extends TutorState {
  const TutorError({
    required this.message,
    required this.errorType,
    this.previousState,
  });

  final String message;
  final TutorErrorType errorType;
  final TutorState? previousState; // To restore previous state after error

  @override
  List<Object?> get props => [message, errorType, previousState];

  @override
  String toString() => 'TutorError(type: $errorType, message: $message)';
}

/// Types of errors that can occur
enum TutorErrorType {
  network,
  server,
  validation,
  notFound,
  unauthorized,
  forbidden,
  cache,
  unknown;

  /// User-friendly description
  String get description {
    switch (this) {
      case TutorErrorType.network:
        return 'Network error. Please check your connection.';
      case TutorErrorType.server:
        return 'Server error. Please try again later.';
      case TutorErrorType.validation:
        return 'Invalid input. Please check your data.';
      case TutorErrorType.notFound:
        return 'Resource not found.';
      case TutorErrorType.unauthorized:
        return 'You are not authorized to access this resource.';
      case TutorErrorType.forbidden:
        return 'Access forbidden.';
      case TutorErrorType.cache:
        return 'Cache error. Data may be outdated.';
      case TutorErrorType.unknown:
        return 'An unexpected error occurred.';
    }
  }

  /// Whether this error type supports retry
  bool get canRetry {
    switch (this) {
      case TutorErrorType.network:
      case TutorErrorType.server:
      case TutorErrorType.cache:
      case TutorErrorType.unknown:
        return true;
      case TutorErrorType.validation:
      case TutorErrorType.notFound:
      case TutorErrorType.unauthorized:
      case TutorErrorType.forbidden:
        return false;
    }
  }
}
