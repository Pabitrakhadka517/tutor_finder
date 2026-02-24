import 'package:dartz/dartz.dart';

import '../entities/availability_slot_entity.dart';
import '../entities/tutor_entity.dart';
import '../entities/tutor_list_result_entity.dart';
import '../entities/tutor_search_params.dart';
import '../failures/tutor_failures.dart';

/// Repository contract for tutor-related operations.
/// Defines the interface that the data layer must implement.
abstract class TutorRepository {
  /// Searches for tutors with given parameters and returns paginated results.
  ///
  /// [params] - Search and filter parameters including pagination
  /// Returns Either<Failure, TutorListResult> where:
  /// - Left side contains failure information
  /// - Right side contains paginated tutor list with metadata
  Future<Either<TutorFailure, TutorListResultEntity>> getTutors(
    TutorSearchParams params,
  );

  /// Gets detailed information for a specific tutor.
  ///
  /// [tutorId] - Unique identifier of the tutor
  /// Returns Either<Failure, Tutor> where:
  /// - Left side contains failure information (e.g., not found)
  /// - Right side contains complete tutor details
  Future<Either<TutorFailure, TutorEntity>> getTutorById(String tutorId);

  /// Gets the current user's availability slots (tutor-only operation).
  ///
  /// Returns Either<Failure, List<AvailabilitySlot>> where:
  /// - Left side contains failure information
  /// - Right side contains list of availability slots
  Future<Either<TutorFailure, List<AvailabilitySlotEntity>>>
  getMyAvailability();

  /// Sets/replaces the current user's availability slots (tutor-only operation).
  ///
  /// [slots] - List of new availability slots to set
  /// Returns Either<Failure, void> where:
  /// - Left side contains failure information (e.g., validation errors)
  /// - Right side indicates successful operation
  Future<Either<TutorFailure, void>> setAvailability(
    List<AvailabilitySlotEntity> slots,
  );

  /// Submits the current user's profile for verification (tutor-only operation).
  ///
  /// Returns Either<Failure, void> where:
  /// - Left side contains failure information (e.g., already verified)
  /// - Right side indicates successful submission
  Future<Either<TutorFailure, void>> submitVerification();

  /// Clears cached tutor data (for logout or cache refresh).
  ///
  /// Returns Either<Failure, void> where:
  /// - Left side contains cache operation failure
  /// - Right side indicates successful cache clearing
  Future<Either<TutorFailure, void>> clearTutorCache();
}
