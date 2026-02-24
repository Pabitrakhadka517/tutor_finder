import '../models/tutor_hive_model.dart';

/// Abstract interface for tutor local data operations.
/// Defines the contract for local caching using Hive.
abstract class TutorLocalDatasource {
  /// Caches a list of tutors from search results.
  ///
  /// [tutors] - List of tutors to cache
  /// [queryKey] - Unique key representing the search query
  /// [page] - Page number for pagination support
  Future<void> cacheTutorList(
    List<TutorHiveModel> tutors,
    String queryKey,
    int page,
    int total,
    int totalPages,
  );

  /// Gets cached tutor list for a specific query.
  ///
  /// [queryKey] - Unique key representing the search query
  /// [page] - Page number to retrieve
  /// Returns cached tutors if available and not expired
  /// Returns null if cache miss or expired
  Future<TutorSearchCacheHiveModel?> getCachedTutorList(
    String queryKey,
    int page,
  );

  /// Caches detailed information for a specific tutor.
  ///
  /// [tutor] - Tutor data to cache
  Future<void> cacheTutorDetail(TutorHiveModel tutor);

  /// Gets cached tutor detail.
  ///
  /// [tutorId] - Unique identifier of the tutor
  /// Returns cached tutor if available and not expired
  /// Returns null if cache miss or expired
  Future<TutorHiveModel?> getCachedTutorDetail(String tutorId);

  /// Caches availability slots for the current user.
  ///
  /// [slots] - List of availability slots to cache
  Future<void> cacheMyAvailability(List<AvailabilitySlotHiveModel> slots);

  /// Gets cached availability slots for the current user.
  ///
  /// Returns cached slots if available and not expired
  /// Returns null if cache miss or expired
  Future<List<AvailabilitySlotHiveModel>?> getCachedMyAvailability();

  /// Clears all tutor-related cached data.
  ///
  /// Used for logout or cache refresh scenarios
  Future<void> clearTutorCache();

  /// Clears expired cache entries.
  ///
  /// Should be called periodically to maintain cache size
  Future<void> clearExpiredCache();

  /// Checks if cached data is valid (not expired).
  ///
  /// [cachedAt] - When the data was cached
  /// [maxAge] - Maximum age in hours (default: 1 hour)
  bool isCacheValid(DateTime cachedAt, {int maxAgeHours = 1});
}
