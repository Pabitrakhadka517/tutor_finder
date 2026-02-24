import 'package:dartz/dartz.dart';

import '../entities/booking_entity.dart';
import '../enums/booking_status.dart';
import '../failures/booking_failures.dart';
import '../repositories/booking_repository.dart';

/// Use case for editing a booking (e.g., changing time or notes).
/// Only allowed for pending bookings with proper validation.
class EditBookingUseCase {
  const EditBookingUseCase(this._repository);

  final BookingRepository _repository;

  /// Edit booking with comprehensive validation
  Future<Either<BookingFailure, BookingEntity>> call(
    EditBookingParams params,
  ) async {
    // 1. Validate parameters
    final validation = _validateParams(params);
    if (validation != null) {
      return Left(validation);
    }

    // 2. Get current booking to check state and permissions
    final bookingResult = await _repository.getBookingById(params.bookingId);

    return bookingResult.fold((failure) => Left(failure), (booking) async {
      // 3. Check if booking can be edited
      final canEdit = _canEditBooking(booking, params);
      if (canEdit != null) {
        return Left(canEdit);
      }

      // 4. Check for conflicts if time is being changed
      if (_isTimeBeingChanged(params)) {
        final conflictCheck = await _repository.checkAvailabilityConflict(
          tutorId: booking.tutorId,
          startTime: params.newStartTime ?? booking.startTime,
          endTime: params.newEndTime ?? booking.endTime,
          excludeBookingId: params.bookingId,
        );

        return conflictCheck.fold((failure) => Left(failure), (hasConflict) {
          if (hasConflict) {
            return const Left(
              ConflictFailure(
                'The new time slot conflicts with another booking',
              ),
            );
          }

          // No conflict, proceed with update
          return _repository.updateBooking(
            bookingId: params.bookingId,
            userId: params.userId,
            newStartTime: params.newStartTime,
            newEndTime: params.newEndTime,
            newNotes: params.newNotes,
          );
        });
      } else {
        // No time change, no need to check conflicts
        return _repository.updateBooking(
          bookingId: params.bookingId,
          userId: params.userId,
          newStartTime: params.newStartTime,
          newEndTime: params.newEndTime,
          newNotes: params.newNotes,
        );
      }
    });
  }

  /// Validate input parameters
  ValidationFailure? _validateParams(EditBookingParams params) {
    final errors = <String>[];

    if (params.bookingId.isEmpty) {
      errors.add('Booking ID is required');
    }

    if (params.userId.isEmpty) {
      errors.add('User ID is required');
    }

    // Validate new time range if provided
    if (params.newStartTime != null && params.newEndTime != null) {
      if (!params.newEndTime!.isAfter(params.newStartTime!)) {
        errors.add('End time must be after start time');
      }

      // Check minimum session duration (15 minutes)
      final duration = params.newEndTime!.difference(params.newStartTime!);
      if (duration.inMinutes < 15) {
        errors.add('Session must be at least 15 minutes long');
      }

      // Check maximum session duration (8 hours)
      if (duration.inHours > 8) {
        errors.add('Session cannot be longer than 8 hours');
      }

      // Check if new booking time is in the future (at least 1 hour)
      final minBookingTime = DateTime.now().add(const Duration(hours: 1));
      if (params.newStartTime!.isBefore(minBookingTime)) {
        errors.add('Booking must be at least 1 hour in advance');
      }
    }

    // At least one field must be provided for update
    if (params.newStartTime == null &&
        params.newEndTime == null &&
        params.newNotes == null) {
      errors.add('At least one field must be provided for update');
    }

    return errors.isEmpty
        ? null
        : ValidationFailure('Invalid parameters', errors: errors);
  }

  /// Check if booking can be edited
  BookingFailure? _canEditBooking(
    BookingEntity booking,
    EditBookingParams params,
  ) {
    // Check authorization (only student who created the booking can edit it)
    if (booking.studentId != params.userId) {
      return const AuthorizationFailure(
        'Only the student who made the booking can edit it',
      );
    }

    // Check if booking status allows editing
    if (booking.status != BookingStatus.pending) {
      return BusinessRuleFailure(
        'Only pending bookings can be edited. Current status: ${booking.status}',
      );
    }

    // Check if booking is too close to start time (1-hour notice)
    final timeUntilStart = booking.startTime.difference(DateTime.now());
    if (timeUntilStart.inHours < 1) {
      return BusinessRuleFailure(
        'Cannot edit booking less than 1 hour before start time. '
        'Only ${timeUntilStart.inMinutes} minutes remaining.',
      );
    }

    return null;
  }

  /// Check if the time is being changed
  bool _isTimeBeingChanged(EditBookingParams params) {
    return params.newStartTime != null || params.newEndTime != null;
  }
}

/// Parameters for editing a booking
class EditBookingParams {
  const EditBookingParams({
    required this.bookingId,
    required this.userId,
    this.newStartTime,
    this.newEndTime,
    this.newNotes,
  });

  final String bookingId;
  final String userId; // Must be the student who made the booking
  final DateTime? newStartTime;
  final DateTime? newEndTime;
  final String? newNotes;

  /// Check if time is being modified
  bool get isTimeBeingModified {
    return newStartTime != null || newEndTime != null;
  }

  /// Calculate new duration if time is being changed
  double? get newDurationInHours {
    if (newStartTime != null && newEndTime != null) {
      return newEndTime!.difference(newStartTime!).inMinutes / 60.0;
    }
    return null;
  }

  @override
  String toString() {
    return 'EditBookingParams(bookingId: $bookingId, userId: $userId, '
        'newStartTime: $newStartTime, newEndTime: $newEndTime, '
        'newNotes: ${newNotes != null ? "provided" : "none"})';
  }
}
