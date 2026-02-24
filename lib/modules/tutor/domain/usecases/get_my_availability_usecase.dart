import 'package:dartz/dartz.dart';

import '../entities/availability_slot_entity.dart';
import '../failures/tutor_failures.dart';
import '../repositories/tutor_repository.dart';

/// Use case for getting the current tutor's availability slots.
/// This is a tutor-only operation that requires proper authentication.
class GetMyAvailabilityUsecase {
  const GetMyAvailabilityUsecase(this.repository);

  final TutorRepository repository;

  /// Gets the current user's availability slots.
  ///
  /// No parameters needed as this gets the authenticated user's data.
  /// The repository handles authentication validation.
  ///
  /// Returns Either<Failure, List<AvailabilitySlot>>
  Future<Either<TutorFailure, List<AvailabilitySlotEntity>>> call() async {
    return repository.getMyAvailability();
  }
}
