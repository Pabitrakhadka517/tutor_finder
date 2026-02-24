import 'package:dartz/dartz.dart';

import '../../domain/entities/booking_entity.dart';
import '../../domain/enums/booking_status.dart';
import '../../domain/failures/booking_failures.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_local_datasource.dart';
import '../datasources/booking_remote_datasource.dart';
import '../dtos/create_booking_dto.dart';
import '../dtos/update_booking_status_dto.dart';

/// Repository implementation for booking operations.
/// Implements cache-first strategy with comprehensive error handling.
class BookingRepositoryImpl implements BookingRepository {
  const BookingRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final BookingRemoteDatasource remoteDataSource;
  final BookingLocalDatasource localDataSource;

  @override
  Future<Either<BookingFailure, BookingEntity>> createBooking({
    required String tutorId,
    required String studentId,
    required DateTime startTime,
    required DateTime endTime,
    required double hourlyRate,
    String? notes,
  }) async {
    try {
      // Create DTO for API request
      final createDto = CreateBookingDto(
        tutorId: tutorId,
        studentId: studentId,
        startTime: startTime,
        endTime: endTime,
        hourlyRate: hourlyRate,
        notes: notes,
      );

      // Make API call
      final bookingDto = await remoteDataSource.createBooking(createDto);

      // Convert to entity
      final booking = bookingDto.toEntity();

      // Cache the new booking
      try {
        await localDataSource.cacheBooking(booking);
      } catch (cacheError) {
        // Don't fail the whole operation for cache errors
        print('Warning: Failed to cache new booking: $cacheError');
      }

      return Right(booking);
    } on BookingFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Failed to create booking: $e'));
    }
  }

  @override
  Future<Either<BookingFailure, List<BookingEntity>>> getMyBookings({
    required String userId,
    required String userRole,
    BookingStatus? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
  }) async {
    // Try cache first
    {
      try {
        final cachedBookings = await localDataSource.getCachedBookingsForUser(
          userId: userId,
          userRole: userRole,
          statusFilter: statusFilter,
        );

        if (cachedBookings.isNotEmpty) {
          // Apply date filters if specified (cache doesn't filter by date)
          final filteredBookings = _applyDateFilters(
            cachedBookings,
            fromDate: fromDate,
            toDate: toDate,
          );

          if (filteredBookings.isNotEmpty) {
            return Right(filteredBookings);
          }
        }
      } catch (cacheError) {
        print('Cache read error: $cacheError');
      }
    }

    // Fetch from API
    try {
      final response = await remoteDataSource.getMyBookings(
        userId: userId,
        userRole: userRole,
        statusFilter: statusFilter,
        fromDate: fromDate,
        toDate: toDate,
        limit: limit,
        offset: offset,
      );

      final bookings = response.bookings.map((dto) => dto.toEntity()).toList();

      // Cache the bookings
      try {
        await localDataSource.cacheBookings(bookings);
      } catch (cacheError) {
        print('Warning: Failed to cache bookings: $cacheError');
      }

      return Right(bookings);
    } on BookingFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Failed to get bookings: $e'));
    }
  }

  @override
  Future<Either<BookingFailure, BookingEntity>> getBookingById(
    String bookingId, {
    bool forceRefresh = false,
  }) async {
    // Try cache first unless force refresh
    if (!forceRefresh) {
      try {
        final cachedBooking = await localDataSource.getCachedBooking(bookingId);
        if (cachedBooking != null) {
          return Right(cachedBooking);
        }
      } catch (cacheError) {
        print('Cache read error: $cacheError');
      }
    }

    // Fetch from API
    try {
      final bookingDto = await remoteDataSource.getBookingById(bookingId);
      final booking = bookingDto.toEntity();

      // Cache the booking
      try {
        await localDataSource.cacheBooking(booking);
      } catch (cacheError) {
        print('Warning: Failed to cache booking: $cacheError');
      }

      return Right(booking);
    } on BookingFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Failed to get booking: $e'));
    }
  }

  @override
  Future<Either<BookingFailure, List<BookingEntity>>> getOverlappingBookings({
    required String tutorId,
    required DateTime startTime,
    required DateTime endTime,
    String? excludeBookingId,
  }) async {
    try {
      final overlappingBookings = await remoteDataSource.getOverlappingBookings(
        tutorId: tutorId,
        startTime: startTime,
        endTime: endTime,
        excludeBookingId: excludeBookingId,
      );

      final bookings = overlappingBookings
          .map((dto) => dto.toEntity())
          .toList();
      return Right(bookings);
    } on BookingFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Failed to check overlapping bookings: $e'));
    }
  }

  @override
  Future<Either<BookingFailure, BookingEntity>> updateBookingStatus({
    required String bookingId,
    required BookingStatus newStatus,
    required String userId,
    required String userRole,
    String? reason,
  }) async {
    try {
      final updateDto = UpdateBookingStatusDto(
        status: newStatus.value,
        reason: reason,
      );

      final bookingDto = await remoteDataSource.updateBookingStatus(
        bookingId: bookingId,
        updateDto: updateDto,
      );

      final updatedBooking = bookingDto.toEntity();

      // Update cache
      try {
        await localDataSource.updateCachedBooking(updatedBooking);
      } catch (cacheError) {
        print('Warning: Failed to update cached booking: $cacheError');
      }

      return Right(updatedBooking);
    } on BookingFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Failed to update booking status: $e'));
    }
  }

  @override
  Future<Either<BookingFailure, BookingEntity>> updateBooking({
    required String bookingId,
    required String userId,
    DateTime? newStartTime,
    DateTime? newEndTime,
    String? newNotes,
  }) async {
    try {
      final bookingDto = await remoteDataSource.updateBooking(
        bookingId: bookingId,
        newStartTime: newStartTime,
        newEndTime: newEndTime,
        newNotes: newNotes,
      );

      final updatedBooking = bookingDto.toEntity();

      // Update cache
      try {
        await localDataSource.updateCachedBooking(updatedBooking);
      } catch (cacheError) {
        print('Warning: Failed to update cached booking: $cacheError');
      }

      return Right(updatedBooking);
    } on BookingFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Failed to edit booking: $e'));
    }
  }

  @override
  Future<Either<BookingFailure, BookingEntity>> completeBooking({
    required String bookingId,
    required String userId,
    required String userRole,
    String? sessionNotes,
  }) async {
    try {
      final bookingDto = await remoteDataSource.completeBooking(
        bookingId: bookingId,
        sessionNotes: sessionNotes,
      );

      final completedBooking = bookingDto.toEntity();

      // Update cache
      try {
        await localDataSource.updateCachedBooking(completedBooking);
      } catch (cacheError) {
        print('Warning: Failed to update cached booking: $cacheError');
      }

      return Right(completedBooking);
    } on BookingFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Failed to complete booking: $e'));
    }
  }

  @override
  Future<Either<BookingFailure, BookingEntity>> cancelBooking({
    required String bookingId,
    required String userId,
    required String userRole,
    String? reason,
  }) async {
    try {
      final bookingDto = await remoteDataSource.cancelBooking(
        bookingId: bookingId,
        reason: reason ?? 'Cancelled',
      );

      final cancelledBooking = bookingDto.toEntity();

      // Update cache
      try {
        await localDataSource.updateCachedBooking(cancelledBooking);
      } catch (cacheError) {
        print('Warning: Failed to update cached booking: $cacheError');
      }

      return Right(cancelledBooking);
    } on BookingFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Failed to cancel booking: $e'));
    }
  }

  @override
  Future<Either<BookingFailure, List<BookingEntity>>> getUpcomingBookings({
    required String userId,
    required String userRole,
    int days = 7,
  }) async {
    // Try cache first
    {
      try {
        final cachedBookings = await localDataSource.getCachedUpcomingBookings(
          userId: userId,
          userRole: userRole,
          days: days,
        );

        if (cachedBookings.isNotEmpty) {
          return Right(cachedBookings);
        }
      } catch (cacheError) {
        print('Cache read error: $cacheError');
      }
    }

    // Fetch from API
    try {
      final bookingDtos = await remoteDataSource.getUpcomingBookings(
        userId: userId,
        userRole: userRole,
        days: days,
      );

      final bookings = bookingDtos.map((dto) => dto.toEntity()).toList();

      // Cache the bookings
      try {
        await localDataSource.cacheBookings(bookings);
      } catch (cacheError) {
        print('Warning: Failed to cache upcoming bookings: $cacheError');
      }

      return Right(bookings);
    } on BookingFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Failed to get upcoming bookings: $e'));
    }
  }

  /// Apply date filters to a list of bookings.
  List<BookingEntity> _applyDateFilters(
    List<BookingEntity> bookings, {
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    if (fromDate == null && toDate == null) return bookings;

    return bookings.where((booking) {
      if (fromDate != null && booking.startTime.isBefore(fromDate)) {
        return false;
      }
      if (toDate != null && booking.startTime.isAfter(toDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<Either<BookingFailure, bool>> checkAvailabilityConflict({
    required String tutorId,
    required DateTime startTime,
    required DateTime endTime,
    String? excludeBookingId,
  }) async {
    try {
      final overlapping = await remoteDataSource.getOverlappingBookings(
        tutorId: tutorId,
        startTime: startTime,
        endTime: endTime,
        excludeBookingId: excludeBookingId,
      );
      return Right(overlapping.isNotEmpty);
    } on BookingFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Failed to check availability conflict: $e'));
    }
  }

  @override
  Future<Either<BookingFailure, Map<String, dynamic>>> getBookingStats({
    required String userId,
    required String userRole,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final stats = await remoteDataSource.getBookingStats(
        userId: userId,
        userRole: userRole,
        fromDate: fromDate,
        toDate: toDate,
      );
      return Right(stats);
    } on BookingFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Failed to get booking stats: $e'));
    }
  }

  @override
  Future<Either<BookingFailure, List<BookingEntity>>> searchBookings({
    String? query,
    BookingStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? tutorId,
    String? studentId,
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await remoteDataSource.searchBookings(
        query: query,
        status: status,
        fromDate: fromDate,
        toDate: toDate,
        tutorId: tutorId,
        studentId: studentId,
        limit: limit,
        offset: offset,
      );
      final bookings = response.bookings.map((dto) => dto.toEntity()).toList();
      return Right(bookings);
    } on BookingFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Failed to search bookings: $e'));
    }
  }

  @override
  Future<Either<BookingFailure, List<BookingEntity>>> refreshBookings({
    required String userId,
    required String userRole,
  }) async {
    try {
      final response = await remoteDataSource.getMyBookings(
        userId: userId,
        userRole: userRole,
      );
      final bookings = response.bookings.map((dto) => dto.toEntity()).toList();
      try {
        await localDataSource.cacheBookings(bookings);
      } catch (_) {}
      return Right(bookings);
    } on BookingFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Failed to refresh bookings: $e'));
    }
  }
}
