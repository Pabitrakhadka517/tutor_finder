/// API endpoints configuration for booking module.
/// Centralizes all booking-related API paths for maintainability.
class BookingApiEndpoints {
  static const String _baseBooking = '/api/bookings';

  // Core CRUD operations
  static const String createBooking = '$_baseBooking';
  static const String getMyBookings = '$_baseBooking/my-bookings';
  static const String searchBookings = '$_baseBooking/search';
  static const String getUpcomingBookings = '$_baseBooking/upcoming';
  static const String getBookingStats = '$_baseBooking/stats';
  static const String checkOverlapping = '$_baseBooking/check-overlap';

  // Individual booking operations
  static String getBookingById(String id) => '$_baseBooking/$id';
  static String updateBooking(String id) => '$_baseBooking/$id';
  static String deleteBooking(String id) => '$_baseBooking/$id';

  // Status management operations
  static String updateBookingStatus(String id) => '$_baseBooking/$id/status';
  static String confirmBooking(String id) => '$_baseBooking/$id/confirm';
  static String cancelBooking(String id) => '$_baseBooking/$id/cancel';
  static String completeBooking(String id) => '$_baseBooking/$id/complete';

  // Admin operations (if needed later)
  static const String getAllBookings = '$_baseBooking/admin/all';
  static const String getBookingsByTutor = '$_baseBooking/admin/by-tutor';
  static const String getBookingsByStudent = '$_baseBooking/admin/by-student';
}
