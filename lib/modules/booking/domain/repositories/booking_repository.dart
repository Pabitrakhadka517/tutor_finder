import 'package:dartz/dartz.dart';

import '../entities/booking_entity.dart';
import '../enums/booking_status.dart';
import '../failures/booking_failures.dart';

/// Repository interface for booking operations.
/// Defines contract for data access without implementation details.
abstract class BookingRepository {
  /// Create a new booking
  Future<Either<BookingFailure, BookingEntity>> createBooking({
    required String studentId,
    required String tutorId,
    required DateTime startTime,
    required DateTime endTime,
    required double hourlyRate,
    String? notes,
  });

  /// Get booking by ID
  Future<Either<BookingFailure, BookingEntity>> getBookingById(
    String bookingId,
  );

  /// Get bookings for a specific user (student or tutor)
  Future<Either<BookingFailure, List<BookingEntity>>> getMyBookings({
    required String userId,
    required String userRole, // 'student' or 'tutor'
    BookingStatus? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
  });

  /// Get overlapping bookings for a tutor in a time range
  Future<Either<BookingFailure, List<BookingEntity>>> getOverlappingBookings({
    required String tutorId,
    required DateTime startTime,
    required DateTime endTime,
    String? excludeBookingId, // Exclude specific booking (for updates)
  });

  /// Update booking status
  Future<Either<BookingFailure, BookingEntity>> updateBookingStatus({
    required String bookingId,
    required BookingStatus newStatus,
    required String userId,
    required String userRole,
    String? reason,
  });

  /// Update booking details (only for pending bookings)
  Future<Either<BookingFailure, BookingEntity>> updateBooking({
    required String bookingId,
    required String userId,
    DateTime? newStartTime,
    DateTime? newEndTime,
    String? newNotes,
  });

  /// Complete a booking (mark as completed)
  Future<Either<BookingFailure, BookingEntity>> completeBooking({
    required String bookingId,
    required String userId,
    required String userRole,
    String? sessionNotes,
  });

  /// Cancel a booking
  Future<Either<BookingFailure, BookingEntity>> cancelBooking({
    required String bookingId,
    required String userId,
    required String userRole,
    String? reason,
  });

  /// Get tutor's availability conflicts
  Future<Either<BookingFailure, bool>> checkAvailabilityConflict({
    required String tutorId,
    required DateTime startTime,
    required DateTime endTime,
    String? excludeBookingId,
  });

  /// Get booking statistics for analytics
  Future<Either<BookingFailure, Map<String, dynamic>>> getBookingStats({
    required String userId,
    required String userRole,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Search bookings with filters
  Future<Either<BookingFailure, List<BookingEntity>>> searchBookings({
    String? query,
    BookingStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? tutorId,
    String? studentId,
    int? limit,
    int? offset,
  });

  /// Get upcoming bookings (next 7 days)
  Future<Either<BookingFailure, List<BookingEntity>>> getUpcomingBookings({
    required String userId,
    required String userRole,
    int days = 7,
  });

  /// Refresh booking data from remote source
  Future<Either<BookingFailure, List<BookingEntity>>> refreshBookings({
    required String userId,
    required String userRole,
  });
}
