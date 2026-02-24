import '../../domain/entities/booking_entity.dart';
import '../../domain/enums/booking_status.dart';

/// Abstract interface for local booking data source.
/// Defines contract for local storage/caching.
abstract class BookingLocalDatasource {
  /// Cache a single booking
  Future<void> cacheBooking(BookingEntity booking);

  /// Cache multiple bookings
  Future<void> cacheBookings(List<BookingEntity> bookings);

  /// Get cached booking by ID
  Future<BookingEntity?> getCachedBooking(String bookingId);

  /// Get all cached bookings for a user
  Future<List<BookingEntity>> getCachedBookingsForUser({
    required String userId,
    required String userRole,
    BookingStatus? statusFilter,
  });

  /// Get cached upcoming bookings
  Future<List<BookingEntity>> getCachedUpcomingBookings({
    required String userId,
    required String userRole,
    int days = 7,
  });

  /// Update cached booking
  Future<void> updateCachedBooking(BookingEntity booking);

  /// Remove cached booking
  Future<void> removeCachedBooking(String bookingId);

  /// Clear all cached bookings for a user
  Future<void> clearCachedBookingsForUser(String userId);

  /// Clear expired cache entries
  Future<void> clearExpiredCache();

  /// Check if booking exists in cache and is not expired
  Future<bool> isBookingCachedAndValid(String bookingId);

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats();

  /// Clear all cached bookings
  Future<void> clearAllCache();
}
