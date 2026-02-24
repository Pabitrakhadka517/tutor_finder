import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/availability_slot_entity.dart';
import '../failures/tutor_failures.dart';
import '../repositories/tutor_repository.dart';

/// Use case for setting/updating the current tutor's availability slots.
/// Validates slot data and handles business logic before delegating to repository.
class SetAvailabilityUsecase {
  const SetAvailabilityUsecase(this.repository);

  final TutorRepository repository;

  /// Sets the current user's availability slots.
  ///
  /// Performs comprehensive validation:
  /// - Validates slot times are valid
  /// - Checks for overlapping slots
  /// - Ensures slots are not in the past
  /// - Validates slot duration
  ///
  /// [params] - Contains list of availability slots to set
  /// Returns Either<Failure, void>
  Future<Either<TutorFailure, void>> call(SetAvailabilityParams params) async {
    // Frontend validation
    final validationFailure = _validateAvailabilitySlots(params.slots);
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    // Delegate to repository
    return repository.setAvailability(params.slots);
  }

  /// Validates availability slots for business rules
  TutorValidationFailure? _validateAvailabilitySlots(
    List<AvailabilitySlotEntity> slots,
  ) {
    final now = DateTime.now();

    for (final slot in slots) {
      // Check if slot times are valid
      if (slot.startTime.isAfter(slot.endTime)) {
        return TutorValidationFailure.invalidAvailabilitySlot();
      }

      // Check if slot is not in the past
      if (slot.startTime.isBefore(now)) {
        return TutorValidationFailure.slotInPast();
      }

      // Check minimum slot duration (e.g., at least 30 minutes)
      if (slot.duration.inMinutes < 30) {
        return const TutorValidationFailure(
          'Availability slots must be at least 30 minutes long.',
        );
      }

      // Check maximum slot duration (e.g., no more than 8 hours)
      if (slot.duration.inHours > 8) {
        return const TutorValidationFailure(
          'Availability slots cannot be more than 8 hours long.',
        );
      }
    }

    // Check for overlapping slots
    for (int i = 0; i < slots.length; i++) {
      for (int j = i + 1; j < slots.length; j++) {
        if (slots[i].overlapsWith(slots[j])) {
          return TutorValidationFailure.overlappingSlots();
        }
      }
    }

    return null;
  }
}

/// Parameters for SetAvailabilityUsecase
class SetAvailabilityParams extends Equatable {
  const SetAvailabilityParams({required this.slots});

  final List<AvailabilitySlotEntity> slots;

  @override
  List<Object?> get props => [slots];
}
