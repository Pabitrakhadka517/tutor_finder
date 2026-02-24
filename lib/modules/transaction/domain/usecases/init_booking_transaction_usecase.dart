import 'package:dartz/dartz.dart';

import '../../../booking/domain/entities/booking_entity.dart';
import '../../../booking/domain/enums/booking_status.dart';
import '../../../booking/domain/repositories/booking_repository.dart';
import '../entities/transaction_entity.dart';
import '../enums/reference_type.dart';
import '../failures/transaction_failures.dart';
import '../repositories/transaction_repository.dart';

/// Use case to initialize a transaction for a booking payment.
/// Validates booking state and creates a pending transaction.
class InitBookingTransactionUseCase {
  const InitBookingTransactionUseCase({
    required this.transactionRepository,
    required this.bookingRepository,
  });

  final TransactionRepository transactionRepository;
  final BookingRepository bookingRepository;

  /// Initialize a booking transaction
  Future<Either<TransactionFailure, TransactionEntity>> call({
    required String bookingId,
    required String studentId,
  }) async {
    // 1. Validate booking exists
    final bookingResult = await bookingRepository.getBookingById(bookingId);
    if (bookingResult.isLeft()) {
      return const Left(TransactionValidationFailure('Booking not found'));
    }

    final booking = bookingResult.getOrElse(
      () => throw StateError('Handled above'),
    );

    // 2. Ensure booking status is confirmed
    if (booking.status != BookingStatus.confirmed) {
      return const Left(
        TransactionValidationFailure(
          'Booking must be confirmed before payment can be processed',
        ),
      );
    }

    // 3. Ensure booking is not already paid
    if (booking.status == BookingStatus.paid) {
      return const Left(
        TransactionConflictFailure('Booking has already been paid'),
      );
    }

    // 4. Validate user authorization (student can only pay for their own bookings)
    if (booking.studentId != studentId) {
      return const Left(
        TransactionAuthorizationFailure(
          'Not authorized to pay for this booking',
        ),
      );
    }

    // 5. Check if pending transaction already exists
    final existingTransactionResult = await transactionRepository
        .findTransactionByReference(bookingId);

    if (existingTransactionResult.isLeft()) {
      return Left(
        existingTransactionResult.fold(
          (l) => l,
          (r) => throw StateError('Unreachable'),
        ),
      );
    }

    final existingTransaction = existingTransactionResult.getOrElse(
      () => throw StateError('Handled above'),
    );

    if (existingTransaction != null && existingTransaction.isPending) {
      return Left(
        TransactionConflictFailure(
          'A pending transaction already exists for this booking',
        ),
      );
    }

    // 6. Create new transaction
    final createResult = await transactionRepository.createTransaction(
      senderId: booking.studentId,
      receiverId: booking.tutorId,
      referenceId: bookingId,
      referenceType: ReferenceType.booking,
      totalAmount: booking.price,
      notes: 'Payment for booking session',
    );

    return createResult;
  }
}
