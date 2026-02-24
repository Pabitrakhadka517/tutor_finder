import 'package:dartz/dartz.dart';

import '../entities/booking_entity.dart';
import '../enums/booking_status.dart';
import '../failures/booking_failures.dart';
import '../repositories/booking_repository.dart';

/// Use case for cancelling a booking.
/// Handles cancellation validation and business rules.
class CancelBookingUseCase {
  const CancelBookingUseCase(this._repository);

  final BookingRepository _repository;

  /// Cancel a booking with validation
  Future<Either<BookingFailure, BookingEntity>> call(
    CancelBookingParams params,
  ) async {
    // 1. Validate parameters
    final validation = _validateParams(params);
    if (validation != null) {
      return Left(validation);
    }

    // 2. Get current booking to check state and permissions
    final bookingResult = await _repository.getBookingById(params.bookingId);

    return bookingResult.fold((failure) => Left(failure), (booking) async {
      // 3. Check if booking can be cancelled
      final canCancel = _canCancelBooking(booking, params);
      if (canCancel != null) {
        return Left(canCancel);
      }

      // 4. Cancel the booking
      return _repository.cancelBooking(
        bookingId: params.bookingId,
        userId: params.userId,
        userRole: params.userRole,
        reason: params.reason,
      );
    });
  }

  /// Validate input parameters
  ValidationFailure? _validateParams(CancelBookingParams params) {
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

    if (params.reason.isEmpty) {
      errors.add('Cancellation reason is required');
    }

    return errors.isEmpty
        ? null
        : ValidationFailure('Invalid parameters', errors: errors);
  }

  /// Check if booking can be cancelled
  BookingFailure? _canCancelBooking(
    BookingEntity booking,
    CancelBookingParams params,
  ) {
    // Check authorization
    if (params.userRole != 'admin') {
      final isAuthorized =
          (params.userRole == 'student' &&
              booking.studentId == params.userId) ||
          (params.userRole == 'tutor' && booking.tutorId == params.userId);

      if (!isAuthorized) {
        return const AuthorizationFailure(
          'You can only cancel your own bookings',
        );
      }
    }

    // Check if booking can be cancelled (business rule)
    if (!booking.status.canBeCancelled) {
      return BusinessRuleFailure(
        'Cannot cancel booking with status: ${booking.status}',
      );
    }

    // Check cancellation notice periods
    final now = DateTime.now();
    final timeUntilStart = booking.startTime.difference(now);

    // Student cancellation rules (24-hour notice)
    if (params.userRole == 'student') {
      if (timeUntilStart.inHours < 24) {
        return BusinessRuleFailure(
          'Students must cancel at least 24 hours before the session. '
          'Only ${timeUntilStart.inHours} hours remaining.',
        );
      }
    }

    // Tutor cancellation rules (2-hour notice)
    if (params.userRole == 'tutor') {
      if (timeUntilStart.inHours < 2) {
        return BusinessRuleFailure(
          'Tutors must cancel at least 2 hours before the session. '
          'Only ${timeUntilStart.inHours} hours remaining.',
        );
      }
    }

    // Cannot cancel if session has already started
    if (now.isAfter(booking.startTime)) {
      return const BusinessRuleFailure(
        'Cannot cancel a booking that has already started',
      );
    }

    // Additional business rules based on status
    switch (booking.status) {
      case BookingStatus.completed:
        return const BusinessRuleFailure('Cannot cancel a completed booking');

      case BookingStatus.cancelled:
        return const BusinessRuleFailure(
          'This booking has already been cancelled',
        );

      case BookingStatus.rejected:
        return const BusinessRuleFailure('Cannot cancel a rejected booking');

      default:
        break;
    }

    return null;
  }
}

/// Parameters for cancelling a booking
class CancelBookingParams {
  const CancelBookingParams({
    required this.bookingId,
    required this.userId,
    required this.userRole,
    required this.reason,
    this.refundRequested = false,
  });

  final String bookingId;
  final String userId;
  final String userRole; // 'student', 'tutor', or 'admin'
  final String reason;
  final bool refundRequested;

  @override
  String toString() {
    return 'CancelBookingParams(bookingId: $bookingId, userId: $userId, '
        'userRole: $userRole, reason: $reason, refundRequested: $refundRequested)';
  }
}
