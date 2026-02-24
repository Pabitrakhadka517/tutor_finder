import 'package:dartz/dartz.dart';

import '../entities/booking_entity.dart';
import '../enums/booking_status.dart';
import '../failures/booking_failures.dart';
import '../repositories/booking_repository.dart';

/// Use case for retrieving user's bookings (student or tutor).
/// Handles role-based filtering and sorting.
class GetMyBookingsUseCase {
  const GetMyBookingsUseCase(this._repository);

  final BookingRepository _repository;

  /// Get bookings for the current user
  Future<Either<BookingFailure, List<BookingEntity>>> call(
    GetMyBookingsParams params,
  ) async {
    // Validate parameters
    final validation = _validateParams(params);
    if (validation != null) {
      return Left(validation);
    }

    // Get bookings from repository
    final result = await _repository.getMyBookings(
      userId: params.userId,
      userRole: params.userRole,
      statusFilter: params.statusFilter,
      fromDate: params.fromDate,
      toDate: params.toDate,
      limit: params.limit,
      offset: params.offset,
    );

    // Sort bookings by start time (newest first for completed, oldest first for upcoming)
    return result.map((bookings) {
      final sortedBookings = List<BookingEntity>.from(bookings);

      sortedBookings.sort((a, b) {
        // Completed bookings: newest first
        if (a.status == BookingStatus.completed &&
            b.status == BookingStatus.completed) {
          return b.startTime.compareTo(a.startTime);
        }

        // Upcoming/active bookings: oldest first (soonest first)
        if (a.isUpcoming && b.isUpcoming) {
          return a.startTime.compareTo(b.startTime);
        }

        // Mixed: upcoming before completed
        if (a.isUpcoming && !b.isUpcoming) return -1;
        if (!a.isUpcoming && b.isUpcoming) return 1;

        // Default: sort by start time
        return a.startTime.compareTo(b.startTime);
      });

      return sortedBookings;
    });
  }

  /// Validate input parameters
  ValidationFailure? _validateParams(GetMyBookingsParams params) {
    final errors = <String>[];

    if (params.userId.isEmpty) {
      errors.add('User ID is required');
    }

    if (params.userRole != 'student' && params.userRole != 'tutor') {
      errors.add('User role must be either "student" or "tutor"');
    }

    if (params.fromDate != null && params.toDate != null) {
      if (params.toDate!.isBefore(params.fromDate!)) {
        errors.add('To date must be after from date');
      }
    }

    if (params.limit != null && params.limit! <= 0) {
      errors.add('Limit must be greater than 0');
    }

    if (params.offset != null && params.offset! < 0) {
      errors.add('Offset must be 0 or greater');
    }

    return errors.isEmpty
        ? null
        : ValidationFailure('Invalid parameters', errors: errors);
  }
}

/// Parameters for getting user bookings
class GetMyBookingsParams {
  const GetMyBookingsParams({
    required this.userId,
    required this.userRole,
    this.statusFilter,
    this.fromDate,
    this.toDate,
    this.limit,
    this.offset,
    this.includeCompleted = true,
  });

  final String userId;
  final String userRole; // 'student' or 'tutor'
  final BookingStatus? statusFilter;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? limit;
  final int? offset;
  final bool includeCompleted;

  /// Create params for student bookings
  factory GetMyBookingsParams.forStudent({
    required String studentId,
    BookingStatus? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
  }) {
    return GetMyBookingsParams(
      userId: studentId,
      userRole: 'student',
      statusFilter: statusFilter,
      fromDate: fromDate,
      toDate: toDate,
      limit: limit,
      offset: offset,
    );
  }

  /// Create params for tutor bookings
  factory GetMyBookingsParams.forTutor({
    required String tutorId,
    BookingStatus? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
  }) {
    return GetMyBookingsParams(
      userId: tutorId,
      userRole: 'tutor',
      statusFilter: statusFilter,
      fromDate: fromDate,
      toDate: toDate,
      limit: limit,
      offset: offset,
    );
  }

  /// Create params for upcoming bookings only
  factory GetMyBookingsParams.upcomingOnly({
    required String userId,
    required String userRole,
    int? limit,
  }) {
    return GetMyBookingsParams(
      userId: userId,
      userRole: userRole,
      fromDate: DateTime.now(),
      toDate: DateTime.now().add(const Duration(days: 30)),
      limit: limit,
      includeCompleted: false,
    );
  }

  @override
  String toString() {
    return 'GetMyBookingsParams(userId: $userId, userRole: $userRole, '
        'statusFilter: $statusFilter, fromDate: $fromDate, toDate: $toDate)';
  }
}
