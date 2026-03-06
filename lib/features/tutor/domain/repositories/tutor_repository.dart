import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/tutor_entity.dart';
import '../entities/availability_slot_entity.dart';

/// Repository interface for tutor operations
abstract class TutorRepository {
  /// Get list of verified tutors with filters
  Future<Either<Failure, List<TutorEntity>>> getTutors({
    int page,
    int limit,
    String? search,
    String? speciality,
    String? sortBy,
    String? order,
  });

  /// Get a single tutor profile by ID
  Future<Either<Failure, TutorEntity>> getTutorById(String id);

  /// Get tutor's availability slots
  Future<Either<Failure, List<AvailabilitySlotEntity>>> getMyAvailability({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get a specific tutor's availability slots (for students)
  Future<Either<Failure, List<AvailabilitySlotEntity>>> getTutorAvailability(
    String tutorId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Set tutor's availability slots (for tutor role)
  Future<Either<Failure, void>> setAvailability(
    List<AvailabilitySlotEntity> slots,
  );

  /// Submit tutor profile for verification
  Future<Either<Failure, void>> submitForVerification();
}
