import '../../../core/utils/either.dart';
import '../../../core/error/failures.dart';
import 'entities/booking_entity.dart';

abstract class BookingRepository {
  Future<Either<Failure, BookingEntity>> createBooking({
    required String tutorId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  });

  Future<Either<Failure, List<BookingEntity>>> getBookings({String? status});

  Future<Either<Failure, BookingEntity>> updateBookingStatus({
    required String bookingId,
    required String status,
  });

  Future<Either<Failure, BookingEntity>> completeBooking(String bookingId);
  Future<Either<Failure, BookingEntity>> cancelBooking(String bookingId);

  Future<Either<Failure, BookingEntity>> updateBooking({
    required String bookingId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  });
}
