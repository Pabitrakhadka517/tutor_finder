import '../models/tutor_model.dart';
import '../models/availability_slot_model.dart';

/// Remote data source interface for tutor operations
abstract class TutorRemoteDataSource {
  /// Get list of verified tutors
  Future<List<TutorModel>> getTutors({
    int page,
    int limit,
    String? search,
    String? speciality,
    String? sortBy,
    String? order,
  });

  /// Get a single tutor profile
  Future<TutorModel> getTutorById(String id);

  /// Get own availability slots (for tutor role)
  Future<List<AvailabilitySlotModel>> getMyAvailability({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get a specific tutor's availability slots (for students)
  Future<List<AvailabilitySlotModel>> getTutorAvailability(
    String tutorId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Set availability slots (for tutor role)
  Future<void> setAvailability(List<AvailabilitySlotModel> slots);

  /// Submit profile for verification
  Future<void> submitForVerification();
}
