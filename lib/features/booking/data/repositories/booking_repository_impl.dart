import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, BookingEntity>> createBooking({
    required String tutorId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    try {
      final booking = await remoteDataSource.createBooking(
        tutorId: tutorId,
        startTime: startTime,
        endTime: endTime,
        notes: notes,
      );
      return Either.right(booking);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getBookings({
    String? status,
  }) async {
    try {
      final bookings = await remoteDataSource.getBookings(status: status);
      return Either.right(bookings);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      final booking = await remoteDataSource.updateBookingStatus(
        bookingId: bookingId,
        status: status,
      );
      return Either.right(booking);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> completeBooking(
    String bookingId,
  ) async {
    try {
      final booking = await remoteDataSource.completeBooking(bookingId);
      return Either.right(booking);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> cancelBooking(String bookingId) async {
    try {
      final booking = await remoteDataSource.cancelBooking(bookingId);
      return Either.right(booking);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> updateBooking({
    required String bookingId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    try {
      final booking = await remoteDataSource.updateBooking(
        bookingId: bookingId,
        startTime: startTime,
        endTime: endTime,
        notes: notes,
      );
      return Either.right(booking);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }
}
