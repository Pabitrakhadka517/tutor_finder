import '../models/availability_slot_dto.dart';
import '../models/tutor_detail_dto.dart';
import '../models/tutor_list_response_dto.dart';

/// Abstract interface for tutor remote data operations.
/// Defines the contract for API communication.
abstract class TutorRemoteDatasource {
  /// Searches for tutors with given query parameters.
  ///
  /// [query] - Query parameters map containing search criteria
  /// Returns paginated list of tutors from API
  /// Throws exception on network or server errors
  Future<TutorListResponseDto> getTutors(Map<String, dynamic> query);

  /// Gets detailed information for a specific tutor.
  ///
  /// [tutorId] - Unique identifier of the tutor
  /// Returns complete tutor details from API
  /// Throws exception if tutor not found or network issues
  Future<TutorDetailDto> getTutorById(String tutorId);

  /// Gets the current user's availability slots (tutor-only operation).
  ///
  /// Returns list of availability slots from API
  /// Requires proper authentication
  /// Throws exception on authorization or network issues
  Future<List<AvailabilitySlotDto>> getMyAvailability();

  /// Sets/replaces the current user's availability slots (tutor-only operation).
  ///
  /// [slots] - List of availability slots to set
  /// Throws exception on validation or network issues
  Future<void> setAvailability(List<Map<String, dynamic>> slots);

  /// Submits the current user's profile for verification (tutor-only operation).
  ///
  /// Throws exception if already verified or network issues
  Future<void> submitVerification();
}
