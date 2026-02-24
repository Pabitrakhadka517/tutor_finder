import 'package:dartz/dartz.dart';

import '../entities/booking_entity.dart';
import '../enums/booking_status.dart';
import '../enums/payment_status.dart';
import '../failures/booking_failures.dart';
import '../repositories/booking_repository.dart';

/// Use case for updating booking status with business rule validation.
/// Handles state transitions and authorization checks.
class UpdateBookingStatusUseCase {
  const UpdateBookingStatusUseCase(this._repository);

  final BookingRepository _repository;

  /// Update booking status with validation
  Future<Either<BookingFailure, BookingEntity>> call(
    UpdateBookingStatusParams params,
  ) async {
    // 1. Validate parameters
    final validation = _validateParams(params);
    if (validation != null) {
      return Left(validation);
    }

    // 2. Get current booking to check current state and permissions
    final bookingResult = await _repository.getBookingById(params.bookingId);

    return bookingResult.fold((failure) => Left(failure), (booking) async {
      // 3. Check authorization
      final authCheck = _checkAuthorization(booking, params);
      if (authCheck != null) {
        return Left(authCheck);
      }

      // 4. Validate state transition
      if (!booking.canTransitionTo(params.newStatus)) {
        return Left(
          BusinessRuleFailure(
            'Cannot change booking status from ${booking.status} to ${params.newStatus}',
          ),
        );
      }

      // 5. Additional business rules based on new status
      final businessRuleCheck = _checkBusinessRules(booking, params);
      if (businessRuleCheck != null) {
        return Left(businessRuleCheck);
      }

      // 6. Update the booking status
      return _repository.updateBookingStatus(
        bookingId: params.bookingId,
        newStatus: params.newStatus,
        userId: params.userId,
        userRole: params.userRole,
        reason: params.reason,
      );
    });
  }

  /// Validate input parameters
  ValidationFailure? _validateParams(UpdateBookingStatusParams params) {
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

    // Reason required for certain status changes
    if ((params.newStatus == BookingStatus.rejected ||
            params.newStatus == BookingStatus.cancelled) &&
        (params.reason?.isEmpty ?? true)) {
      errors.add('Reason is required for rejection or cancellation');
    }

    return errors.isEmpty
        ? null
        : ValidationFailure('Invalid parameters', errors: errors);
  }

  /// Check if user is authorized to perform this status change
  AuthorizationFailure? _checkAuthorization(
    BookingEntity booking,
    UpdateBookingStatusParams params,
  ) {
    // Admin can change any status
    if (params.userRole == 'admin') {
      return null;
    }

    // Check role-specific permissions
    switch (params.newStatus) {
      case BookingStatus.confirmed:
      case BookingStatus.rejected:
        // Only tutors can confirm or reject bookings
        if (params.userRole != 'tutor' || booking.tutorId != params.userId) {
          return const AuthorizationFailure(
            'Only the assigned tutor can confirm or reject bookings',
          );
        }
        break;

      case BookingStatus.cancelled:
        // Students and tutors can cancel their own bookings
        final isAuthorized =
            (params.userRole == 'student' &&
                booking.studentId == params.userId) ||
            (params.userRole == 'tutor' && booking.tutorId == params.userId);

        if (!isAuthorized) {
          return const AuthorizationFailure(
            'You can only cancel your own bookings',
          );
        }
        break;

      case BookingStatus.paid:
        // Payment status is typically handled by payment system
        return const AuthorizationFailure(
          'Payment status is managed automatically by the payment system',
        );

      case BookingStatus.completed:
        // Both student and tutor can mark as completed
        final isAuthorized =
            (params.userRole == 'student' &&
                booking.studentId == params.userId) ||
            (params.userRole == 'tutor' && booking.tutorId == params.userId);

        if (!isAuthorized) {
          return const AuthorizationFailure(
            'Only the student or tutor involved can mark the booking as completed',
          );
        }
        break;

      case BookingStatus.pending:
        // Generally not allowed to go back to pending
        return const AuthorizationFailure(
          'Cannot revert booking back to pending status',
        );
    }

    return null;
  }

  /// Check business rules for specific status transitions
  BusinessRuleFailure? _checkBusinessRules(
    BookingEntity booking,
    UpdateBookingStatusParams params,
  ) {
    switch (params.newStatus) {
      case BookingStatus.confirmed:
        // Cannot confirm if booking is in the past
        if (booking.startTime.isBefore(DateTime.now())) {
          return const BusinessRuleFailure(
            'Cannot confirm a booking that is in the past',
          );
        }
        break;

      case BookingStatus.completed:
        // Can only complete after session end time
        if (DateTime.now().isBefore(booking.endTime)) {
          return const BusinessRuleFailure(
            'Cannot complete a booking before the session ends',
          );
        }

        // Must be paid before completion
        if (booking.paymentStatus != PaymentStatus.paid) {
          return const BusinessRuleFailure(
            'Booking must be paid before it can be marked as completed',
          );
        }
        break;

      case BookingStatus.cancelled:
        // Check cancellation notice periods
        final timeUntilStart = booking.startTime.difference(DateTime.now());

        if (params.userRole == 'student' && timeUntilStart.inHours < 24) {
          return const BusinessRuleFailure(
            'Students must cancel at least 24 hours before the session',
          );
        }

        if (params.userRole == 'tutor' && timeUntilStart.inHours < 2) {
          return const BusinessRuleFailure(
            'Tutors must cancel at least 2 hours before the session',
          );
        }

        // Cannot cancel completed bookings
        if (booking.status == BookingStatus.completed) {
          return const BusinessRuleFailure('Cannot cancel a completed booking');
        }
        break;

      default:
        break;
    }

    return null;
  }
}

/// Parameters for updating booking status
class UpdateBookingStatusParams {
  const UpdateBookingStatusParams({
    required this.bookingId,
    required this.newStatus,
    required this.userId,
    required this.userRole,
    this.reason,
  });

  final String bookingId;
  final BookingStatus newStatus;
  final String userId;
  final String userRole; // 'student', 'tutor', or 'admin'
  final String? reason;

  @override
  String toString() {
    return 'UpdateBookingStatusParams(bookingId: $bookingId, newStatus: $newStatus, '
        'userId: $userId, userRole: $userRole, reason: $reason)';
  }
}
