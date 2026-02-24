import 'package:dartz/dartz.dart';

import '../entities/booking_entity.dart';
import '../failures/booking_failures.dart';
import '../repositories/booking_repository.dart';

/// Use case for creating a new booking.
/// Implements all business rules and validation for booking creation.
class CreateBookingUseCase {
  const CreateBookingUseCase(this._repository);

  final BookingRepository _repository;

  /// Execute booking creation with comprehensive validation
  Future<Either<BookingFailure, BookingEntity>> call(
    CreateBookingParams params,
  ) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) {
      return Left(validation);
    }

    // 2. Check for time conflicts
    final conflictCheck = await _repository.checkAvailabilityConflict(
      tutorId: params.tutorId,
      startTime: params.startTime,
      endTime: params.endTime,
    );

    return conflictCheck.fold((failure) => Left(failure), (hasConflict) {
      if (hasConflict) {
        return const Left(
          ConflictFailure(
            'This time slot is not available. Please choose a different time.',
          ),
        );
      }

      // 3. Create booking with validated data
      return _repository.createBooking(
        studentId: params.studentId,
        tutorId: params.tutorId,
        startTime: params.startTime,
        endTime: params.endTime,
        hourlyRate: params.hourlyRate,
        notes: params.notes,
      );
    });
  }

  /// Validate booking parameters
  ValidationFailure? _validateParams(CreateBookingParams params) {
    final errors = <String>[];

    // Check time range validity
    if (!params.endTime.isAfter(params.startTime)) {
      errors.add('End time must be after start time');
    }

    // Check minimum session duration (15 minutes)
    final duration = params.endTime.difference(params.startTime);
    if (duration.inMinutes < 15) {
      errors.add('Session must be at least 15 minutes long');
    }

    // Check maximum session duration (8 hours)
    if (duration.inHours > 8) {
      errors.add('Session cannot be longer than 8 hours');
    }

    // Check if booking is in the future (at least 1 hour from now)
    final minBookingTime = DateTime.now().add(const Duration(hours: 1));
    if (params.startTime.isBefore(minBookingTime)) {
      errors.add('Booking must be at least 1 hour in advance');
    }

    // Check if booking is not too far in the future (3 months)
    final maxBookingTime = DateTime.now().add(const Duration(days: 90));
    if (params.startTime.isAfter(maxBookingTime)) {
      errors.add('Booking cannot be more than 3 months in advance');
    }

    // Check hourly rate validity
    if (params.hourlyRate <= 0) {
      errors.add('Hourly rate must be greater than 0');
    }

    // Check business hours (optional - can be configured)
    if (_isOutsideBusinessHours(params.startTime, params.endTime)) {
      errors.add('Bookings are only allowed between 6:00 AM and 11:00 PM');
    }

    // Check for student/tutor ID validity
    if (params.studentId.isEmpty) {
      errors.add('Student ID is required');
    }

    if (params.tutorId.isEmpty) {
      errors.add('Tutor ID is required');
    }

    if (params.studentId == params.tutorId) {
      errors.add('Student cannot book a session with themselves');
    }

    return errors.isEmpty
        ? null
        : ValidationFailure('Invalid booking parameters', errors: errors);
  }

  /// Check if booking time is outside business hours
  bool _isOutsideBusinessHours(DateTime start, DateTime end) {
    const businessStartHour = 6; // 6:00 AM
    const businessEndHour = 23; // 11:00 PM

    return start.hour < businessStartHour ||
        end.hour > businessEndHour ||
        (end.hour == businessEndHour && end.minute > 0);
  }
}

/// Parameters for creating a booking
class CreateBookingParams {
  const CreateBookingParams({
    required this.studentId,
    required this.tutorId,
    required this.startTime,
    required this.endTime,
    required this.hourlyRate,
    this.notes,
  });

  final String studentId;
  final String tutorId;
  final DateTime startTime;
  final DateTime endTime;
  final double hourlyRate;
  final String? notes;

  /// Calculate session duration in hours
  double get durationInHours {
    return endTime.difference(startTime).inMinutes / 60.0;
  }

  /// Calculate total price
  double get totalPrice {
    return hourlyRate * durationInHours;
  }

  @override
  String toString() {
    return 'CreateBookingParams(studentId: $studentId, tutorId: $tutorId, '
        'startTime: $startTime, endTime: $endTime, hourlyRate: $hourlyRate)';
  }
}
