import 'package:hive/hive.dart';

import '../models/tutor_hive_model.dart';
import 'tutor_local_datasource.dart';

/// Implementation of tutor local data source using Hive database.
/// Handles all local caching operations for tutor data.
class TutorLocalDatasourceImpl implements TutorLocalDatasource {
  TutorLocalDatasourceImpl({
    required this.tutorBox,
    required this.searchCacheBox,
    required this.availabilityBox,
  });

  final Box<TutorHiveModel> tutorBox;
  final Box<TutorSearchCacheHiveModel> searchCacheBox;
  final Box<List<AvailabilitySlotHiveModel>> availabilityBox;

  static const String _myAvailabilityKey = 'my_availability';

  @override
  Future<void> cacheTutorList(
    List<TutorHiveModel> tutors,
    String queryKey,
    int page,
    int total,
    int totalPages,
  ) async {
    try {
      // Cache individual tutors
      for (final tutor in tutors) {
        await tutorBox.put(tutor.id, tutor);
      }

      // Cache search result metadata
      final searchCache = TutorSearchCacheHiveModel(
        queryKey: queryKey,
        tutorIds: tutors.map((t) => t.id).toList(),
        total: total,
        page: page,
        totalPages: totalPages,
        limit: tutors.length,
        cachedAt: DateTime.now(),
        hasNextPage: page < totalPages,
        hasPreviousPage: page > 1,
      );

      await searchCacheBox.put('${queryKey}_page_$page', searchCache);
    } catch (e) {
      // Log error but don't throw to avoid disrupting the main flow
      print('Error caching tutor list: $e');
    }
  }

  @override
  Future<TutorSearchCacheHiveModel?> getCachedTutorList(
    String queryKey,
    int page,
  ) async {
    try {
      final cacheKey = '${queryKey}_page_$page';
      final searchCache = searchCacheBox.get(cacheKey);

      if (searchCache != null && isCacheValid(searchCache.cachedAt)) {
        // Verify that all referenced tutors are still available
        final allTutorsAvailable = searchCache.tutorIds.every(
          (id) => tutorBox.containsKey(id),
        );

        if (allTutorsAvailable) {
          return searchCache;
        } else {
          // Some tutors are missing, remove this cache entry
          await searchCacheBox.delete(cacheKey);
        }
      } else if (searchCache != null) {
        // Cache expired, remove it
        await searchCacheBox.delete(cacheKey);
      }
    } catch (e) {
      print('Error getting cached tutor list: $e');
    }

    return null;
  }

  @override
  Future<void> cacheTutorDetail(TutorHiveModel tutor) async {
    try {
      await tutorBox.put(tutor.id, tutor);
    } catch (e) {
      print('Error caching tutor detail: $e');
    }
  }

  @override
  Future<TutorHiveModel?> getCachedTutorDetail(String tutorId) async {
    try {
      final tutor = tutorBox.get(tutorId);

      if (tutor != null && isCacheValid(tutor.cachedAt)) {
        return tutor;
      } else if (tutor != null) {
        // Cache expired, remove it
        await tutorBox.delete(tutorId);
      }
    } catch (e) {
      print('Error getting cached tutor detail: $e');
    }

    return null;
  }

  @override
  Future<void> cacheMyAvailability(
    List<AvailabilitySlotHiveModel> slots,
  ) async {
    try {
      await availabilityBox.put(_myAvailabilityKey, slots);
    } catch (e) {
      print('Error caching availability: $e');
    }
  }

  @override
  Future<List<AvailabilitySlotHiveModel>?> getCachedMyAvailability() async {
    try {
      final slots = availabilityBox.get(_myAvailabilityKey);

      if (slots != null && slots.isNotEmpty) {
        // Check if any slot has valid cache time
        final hasValidCache = slots.any(
          (slot) => isCacheValid(DateTime.now(), maxAgeHours: 24),
        ); // Availability cache for 24 hours

        if (hasValidCache) {
          return slots;
        } else {
          // Cache expired
          await availabilityBox.delete(_myAvailabilityKey);
        }
      }
    } catch (e) {
      print('Error getting cached availability: $e');
    }

    return null;
  }

  @override
  Future<void> clearTutorCache() async {
    try {
      await tutorBox.clear();
      await searchCacheBox.clear();
      await availabilityBox.clear();
    } catch (e) {
      print('Error clearing tutor cache: $e');
    }
  }

  @override
  Future<void> clearExpiredCache() async {
    try {
      // Clear expired tutors
      final tutorsToRemove = <String>[];
      for (final key in tutorBox.keys) {
        final tutor = tutorBox.get(key);
        if (tutor != null && !isCacheValid(tutor.cachedAt)) {
          tutorsToRemove.add(key as String);
        }
      }
      for (final key in tutorsToRemove) {
        await tutorBox.delete(key);
      }

      // Clear expired search caches
      final searchCachesToRemove = <String>[];
      for (final key in searchCacheBox.keys) {
        final searchCache = searchCacheBox.get(key);
        if (searchCache != null && !isCacheValid(searchCache.cachedAt)) {
          searchCachesToRemove.add(key as String);
        }
      }
      for (final key in searchCachesToRemove) {
        await searchCacheBox.delete(key);
      }

      print('Cleared expired cache entries');
    } catch (e) {
      print('Error clearing expired cache: $e');
    }
  }

  @override
  bool isCacheValid(DateTime cachedAt, {int maxAgeHours = 1}) {
    final expirationTime = cachedAt.add(Duration(hours: maxAgeHours));
    return DateTime.now().isBefore(expirationTime);
  }
}
