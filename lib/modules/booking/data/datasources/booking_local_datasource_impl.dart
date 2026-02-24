import 'package:hive/hive.dart';

import '../../domain/entities/booking_entity.dart';
import '../../domain/enums/booking_status.dart';
import '../models/booking_hive_model.dart';
import 'booking_local_datasource.dart';

/// Implementation of local data source using Hive.
/// Handles local storage and caching of booking data.
class BookingLocalDatasourceImpl implements BookingLocalDatasource {
  const BookingLocalDatasourceImpl({required this.bookingBox});

  final Box<BookingHiveModel> bookingBox;

  @override
  Future<void> cacheBooking(BookingEntity booking) async {
    try {
      final hiveModel = BookingHiveModel.fromEntity(booking);
      await bookingBox.put(booking.id, hiveModel);
    } catch (e) {
      throw Exception('Failed to cache booking: $e');
    }
  }

  @override
  Future<void> cacheBookings(List<BookingEntity> bookings) async {
    try {
      final Map<String, BookingHiveModel> bookingMap = {};
      for (final booking in bookings) {
        bookingMap[booking.id] = BookingHiveModel.fromEntity(booking);
      }
      await bookingBox.putAll(bookingMap);
    } catch (e) {
      throw Exception('Failed to cache bookings: $e');
    }
  }

  @override
  Future<BookingEntity?> getCachedBooking(String bookingId) async {
    try {
      final hiveModel = bookingBox.get(bookingId);
      if (hiveModel == null) return null;

      // Check if expired
      if (hiveModel.isExpired()) {
        await bookingBox.delete(bookingId);
        return null;
      }

      return hiveModel.toEntity();
    } catch (e) {
      // If error, remove corrupted data and return null
      await bookingBox.delete(bookingId);
      return null;
    }
  }

  @override
  Future<List<BookingEntity>> getCachedBookingsForUser({
    required String userId,
    required String userRole,
    BookingStatus? statusFilter,
  }) async {
    try {
      final List<BookingEntity> results = [];
      final List<String> toDelete = [];

      for (final hiveModel in bookingBox.values) {
        // Check if expired
        if (hiveModel.isExpired()) {
          toDelete.add(hiveModel.id);
          continue;
        }

        // Check user match
        final isUserMatch = userRole == 'student'
            ? hiveModel.studentId == userId
            : hiveModel.tutorId == userId;

        if (!isUserMatch) continue;

        // Check status filter
        if (statusFilter != null && hiveModel.status != statusFilter.value) {
          continue;
        }

        try {
          results.add(hiveModel.toEntity());
        } catch (e) {
          // If conversion fails, mark for deletion
          toDelete.add(hiveModel.id);
        }
      }

      // Clean up expired/corrupted data
      await bookingBox.deleteAll(toDelete);

      // Sort by start time (upcoming first, then newest completed)
      results.sort((a, b) {
        if (a.isUpcoming && b.isUpcoming) {
          return a.startTime.compareTo(b.startTime);
        }
        if (a.isUpcoming && !b.isUpcoming) return -1;
        if (!a.isUpcoming && b.isUpcoming) return 1;
        return b.startTime.compareTo(a.startTime);
      });

      return results;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<BookingEntity>> getCachedUpcomingBookings({
    required String userId,
    required String userRole,
    int days = 7,
  }) async {
    try {
      final cutoffDate = DateTime.now().add(Duration(days: days));
      final allBookings = await getCachedBookingsForUser(
        userId: userId,
        userRole: userRole,
      );

      return allBookings
          .where(
            (booking) =>
                booking.isUpcoming && booking.startTime.isBefore(cutoffDate),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> updateCachedBooking(BookingEntity booking) async {
    try {
      final existing = bookingBox.get(booking.id);
      if (existing != null) {
        // Update existing with new data but preserve cache timestamp if recent
        final updated = BookingHiveModel.fromEntity(booking);
        if (!existing.isExpired(const Duration(minutes: 5))) {
          updated.cachedAt = existing.cachedAt;
        }
        await bookingBox.put(booking.id, updated);
      } else {
        // Create new cache entry
        await cacheBooking(booking);
      }
    } catch (e) {
      throw Exception('Failed to update cached booking: $e');
    }
  }

  @override
  Future<void> removeCachedBooking(String bookingId) async {
    try {
      await bookingBox.delete(bookingId);
    } catch (e) {
      throw Exception('Failed to remove cached booking: $e');
    }
  }

  @override
  Future<void> clearCachedBookingsForUser(String userId) async {
    try {
      final toDelete = <String>[];

      for (final hiveModel in bookingBox.values) {
        if (hiveModel.studentId == userId || hiveModel.tutorId == userId) {
          toDelete.add(hiveModel.id);
        }
      }

      await bookingBox.deleteAll(toDelete);
    } catch (e) {
      throw Exception('Failed to clear cached bookings for user: $e');
    }
  }

  @override
  Future<void> clearExpiredCache() async {
    try {
      final toDelete = <String>[];

      for (final hiveModel in bookingBox.values) {
        if (hiveModel.isExpired()) {
          toDelete.add(hiveModel.id);
        }
      }

      await bookingBox.deleteAll(toDelete);
    } catch (e) {
      throw Exception('Failed to clear expired cache: $e');
    }
  }

  @override
  Future<bool> isBookingCachedAndValid(String bookingId) async {
    try {
      final hiveModel = bookingBox.get(bookingId);
      return hiveModel != null && !hiveModel.isExpired();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      int total = 0;
      int expired = 0;
      int upcoming = 0;
      int completed = 0;

      for (final hiveModel in bookingBox.values) {
        total++;

        if (hiveModel.isExpired()) {
          expired++;
          continue;
        }

        final entity = hiveModel.toEntity();
        if (entity.isUpcoming) {
          upcoming++;
        } else if (entity.status == BookingStatus.completed) {
          completed++;
        }
      }

      return {
        'total_cached': total,
        'expired': expired,
        'valid': total - expired,
        'upcoming': upcoming,
        'completed': completed,
      };
    } catch (e) {
      return {
        'total_cached': 0,
        'expired': 0,
        'valid': 0,
        'upcoming': 0,
        'completed': 0,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      await bookingBox.clear();
    } catch (e) {
      throw Exception('Failed to clear all cache: $e');
    }
  }
}
