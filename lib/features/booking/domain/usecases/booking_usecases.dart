import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking_entity.dart';
import '../booking_repository.dart';

// ================= Create Booking =================
class CreateBookingParams {
  final String tutorId;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;

  const CreateBookingParams({
    required this.tutorId,
    required this.startTime,
    required this.endTime,
    this.notes,
  });
}

class CreateBookingUseCase extends UseCase<BookingEntity, CreateBookingParams> {
  final BookingRepository repository;
  CreateBookingUseCase(this.repository);

  @override
  Future<Either<Failure, BookingEntity>> call(CreateBookingParams params) {
    return repository.createBooking(
      tutorId: params.tutorId,
      startTime: params.startTime,
      endTime: params.endTime,
      notes: params.notes,
    );
  }
}

// ================= Get Bookings =================
class GetBookingsParams {
  final String? status;
  const GetBookingsParams({this.status});
}

class GetBookingsUseCase
    extends UseCase<List<BookingEntity>, GetBookingsParams> {
  final BookingRepository repository;
  GetBookingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<BookingEntity>>> call(GetBookingsParams params) {
    return repository.getBookings(status: params.status);
  }
}

// ================= Update Booking Status =================
class UpdateBookingStatusParams {
  final String bookingId;
  final String status;
  const UpdateBookingStatusParams({
    required this.bookingId,
    required this.status,
  });
}

class UpdateBookingStatusUseCase
    extends UseCase<BookingEntity, UpdateBookingStatusParams> {
  final BookingRepository repository;
  UpdateBookingStatusUseCase(this.repository);

  @override
  Future<Either<Failure, BookingEntity>> call(
    UpdateBookingStatusParams params,
  ) {
    return repository.updateBookingStatus(
      bookingId: params.bookingId,
      status: params.status,
    );
  }
}

// ================= Complete Booking =================
class CompleteBookingUseCase extends UseCase<BookingEntity, String> {
  final BookingRepository repository;
  CompleteBookingUseCase(this.repository);

  @override
  Future<Either<Failure, BookingEntity>> call(String bookingId) {
    return repository.completeBooking(bookingId);
  }
}

// ================= Cancel Booking =================
class CancelBookingUseCase extends UseCase<BookingEntity, String> {
  final BookingRepository repository;
  CancelBookingUseCase(this.repository);

  @override
  Future<Either<Failure, BookingEntity>> call(String bookingId) {
    return repository.cancelBooking(bookingId);
  }
}
