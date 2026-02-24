import 'package:dartz/dartz.dart';

import '../entities/booking_entity.dart';
import '../enums/booking_status.dart';
import '../failures/booking_failures.dart';
import '../repositories/booking_repository.dart';

/// Use case for completing a booking session.
/// Handles completion validation and business rules.
class CompleteBookingUseCase {
  const CompleteBookingUseCase(this._repository);

  final BookingRepository _repository;

  /// Complete a booking with validation
  Future<Either<BookingFailure, BookingEntity>> call(
    CompleteBookingParams params,
  ) async {
    // 1. Validate parameters
    final validation = _validateParams(params);
    if (validation != null) {
      return Left(validation);
    }

    // 2. Get current booking to check state and permissions
    final bookingResult = await _repository.getBookingById(params.bookingId);

    return bookingResult.fold((failure) => Left(failure), (booking) async {
      // 3. Check if booking can be completed
      final canComplete = _canCompleteBooking(booking, params);
      if (canComplete != null) {
        return Left(canComplete);
      }

      // 4. Complete the booking
      return _repository.completeBooking(
        bookingId: params.bookingId,
        userId: params.userId,
        userRole: params.userRole,
        sessionNotes: params.sessionNotes,
      );
    });
  }

  /// Validate input parameters
  ValidationFailure? _validateParams(CompleteBookingParams params) {
    final errors = <String>[];

    if (params.bookingId.isEmpty) {
      errors.add('Booking ID is required');
    }

    if (params.userId.isEmpty) {
      errors.add('User ID is required');
    }

    if (params.userRole != 'student' &&
        params.userRole != 'tutor' &&
        params.userRole != 'admin') {
      errors.add('Invalid user role');
    }

    return errors.isEmpty
        ? null
        : ValidationFailure('Invalid parameters', errors: errors);
  }

  /// Check if booking can be completed
  BookingFailure? _canCompleteBooking(
    BookingEntity booking,
    CompleteBookingParams params,
  ) {
    // Check authorization
    if (params.userRole != 'admin') {
      final isAuthorized =
          (params.userRole == 'student' &&
              booking.studentId == params.userId) ||
          (params.userRole == 'tutor' && booking.tutorId == params.userId);

      if (!isAuthorized) {
        return const AuthorizationFailure(
          'You can only complete your own bookings',
        );
      }
    }

    // Check if booking is in correct status
    if (booking.status != BookingStatus.paid) {
      return BusinessRuleFailure(
        'Booking must be paid before it can be completed. Current status: ${booking.status}',
      );
    }

    // Check if payment is successful
    if (!booking.paymentStatus.isSuccessful) {
      return BusinessRuleFailure(
        'Payment must be completed before marking booking as complete. Payment status: ${booking.paymentStatus}',
      );
    }

    // Check if session has ended
    final now = DateTime.now();
    if (now.isBefore(booking.endTime)) {
      final remainingTime = booking.endTime.difference(now);
      return BusinessRuleFailure(
        'Cannot complete booking before session ends. ${remainingTime.inMinutes} minutes remaining.',
      );
    }

    // Check if booking is already completed
    if (booking.status == BookingStatus.completed) {
      return const BusinessRuleFailure(
        'This booking has already been marked as completed',
      );
    }

    return null;
  }
}

/// Parameters for completing a booking
class CompleteBookingParams {
  const CompleteBookingParams({
    required this.bookingId,
    required this.userId,
    required this.userRole,
    this.sessionNotes,
  });

  final String bookingId;
  final String userId;
  final String userRole; // 'student', 'tutor', or 'admin'
  final String? sessionNotes;

  @override
  String toString() {
    return 'CompleteBookingParams(bookingId: $bookingId, userId: $userId, '
        'userRole: $userRole, sessionNotes: ${sessionNotes != null ? "provided" : "none"})';
  }
}
