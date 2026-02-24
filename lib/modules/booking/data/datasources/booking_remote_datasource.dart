import '../../domain/enums/booking_status.dart';
import '../dtos/booking_dto.dart';
import '../dtos/booking_list_response_dto.dart';
import '../dtos/create_booking_dto.dart';
import '../dtos/update_booking_status_dto.dart';

/// Abstract interface for remote booking data source.
/// Defines contract for API communication.
abstract class BookingRemoteDatasource {
  /// Create a new booking via API
  Future<BookingDto> createBooking(CreateBookingDto createBookingDto);

  /// Get booking by ID from API
  Future<BookingDto> getBookingById(String bookingId);

  /// Get user's bookings with filtering and pagination
  Future<BookingListResponseDto> getMyBookings({
    required String userId,
    required String userRole,
    BookingStatus? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
  });

  /// Check for overlapping bookings
  Future<List<BookingDto>> getOverlappingBookings({
    required String tutorId,
    required DateTime startTime,
    required DateTime endTime,
    String? excludeBookingId,
  });

  /// Update booking status
  Future<BookingDto> updateBookingStatus({
    required String bookingId,
    required UpdateBookingStatusDto updateDto,
  });

  /// Update booking details (time, notes)
  Future<BookingDto> updateBooking({
    required String bookingId,
    DateTime? newStartTime,
    DateTime? newEndTime,
    String? newNotes,
  });

  /// Complete a booking
  Future<BookingDto> completeBooking({
    required String bookingId,
    String? sessionNotes,
  });

  /// Cancel a booking
  Future<BookingDto> cancelBooking({
    required String bookingId,
    required String reason,
  });

  /// Get booking statistics
  Future<Map<String, dynamic>> getBookingStats({
    required String userId,
    required String userRole,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Search bookings with filters
  Future<BookingListResponseDto> searchBookings({
    String? query,
    BookingStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? tutorId,
    String? studentId,
    int? limit,
    int? offset,
  });

  /// Get upcoming bookings
  Future<List<BookingDto>> getUpcomingBookings({
    required String userId,
    required String userRole,
    int days = 7,
  });
}
