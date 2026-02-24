import 'package:dio/dio.dart';

import '../../domain/enums/booking_status.dart';
import '../../domain/failures/booking_failures.dart';
import '../dtos/booking_dto.dart';
import '../dtos/booking_list_response_dto.dart';
import '../dtos/create_booking_dto.dart';
import '../dtos/update_booking_status_dto.dart';
import '../../utils/booking_api_endpoints.dart';
import 'booking_remote_datasource.dart';

/// Implementation of remote data source using Dio HTTP client.
/// Handles API communication with comprehensive error handling.
class BookingRemoteDatasourceImpl implements BookingRemoteDatasource {
  const BookingRemoteDatasourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<BookingDto> createBooking(CreateBookingDto createBookingDto) async {
    try {
      final response = await dio.post(
        BookingApiEndpoints.createBooking,
        data: createBookingDto.toJson(),
      );

      return BookingDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownFailure('Failed to create booking: $e');
    }
  }

  @override
  Future<BookingDto> getBookingById(String bookingId) async {
    try {
      final response = await dio.get(
        BookingApiEndpoints.getBookingById(bookingId),
      );

      return BookingDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownFailure('Failed to get booking: $e');
    }
  }

  @override
  Future<BookingListResponseDto> getMyBookings({
    required String userId,
    required String userRole,
    BookingStatus? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = {
        'user_role': userRole,
        if (statusFilter != null) 'status': statusFilter.value,
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      };

      final response = await dio.get(
        BookingApiEndpoints.getMyBookings,
        queryParameters: queryParams,
      );

      return BookingListResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownFailure('Failed to get bookings: $e');
    }
  }

  @override
  Future<List<BookingDto>> getOverlappingBookings({
    required String tutorId,
    required DateTime startTime,
    required DateTime endTime,
    String? excludeBookingId,
  }) async {
    try {
      final queryParams = {
        'tutor_id': tutorId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        if (excludeBookingId != null) 'exclude_booking_id': excludeBookingId,
      };

      final response = await dio.get(
        BookingApiEndpoints.checkOverlapping,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data;
      return data.map((json) => BookingDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownFailure('Failed to check overlapping bookings: $e');
    }
  }

  @override
  Future<BookingDto> updateBookingStatus({
    required String bookingId,
    required UpdateBookingStatusDto updateDto,
  }) async {
    try {
      final response = await dio.patch(
        BookingApiEndpoints.updateBookingStatus(bookingId),
        data: updateDto.toJson(),
      );

      return BookingDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownFailure('Failed to update booking status: $e');
    }
  }

  @override
  Future<BookingDto> updateBooking({
    required String bookingId,
    DateTime? newStartTime,
    DateTime? newEndTime,
    String? newNotes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (newStartTime != null)
        data['start_time'] = newStartTime.toIso8601String();
      if (newEndTime != null) data['end_time'] = newEndTime.toIso8601String();
      if (newNotes != null) data['notes'] = newNotes;

      final response = await dio.put(
        BookingApiEndpoints.updateBooking(bookingId),
        data: data,
      );

      return BookingDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownFailure('Failed to update booking: $e');
    }
  }

  @override
  Future<BookingDto> completeBooking({
    required String bookingId,
    String? sessionNotes,
  }) async {
    try {
      final data = <String, dynamic>{
        if (sessionNotes != null) 'session_notes': sessionNotes,
      };

      final response = await dio.patch(
        BookingApiEndpoints.completeBooking(bookingId),
        data: data,
      );

      return BookingDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownFailure('Failed to complete booking: $e');
    }
  }

  @override
  Future<BookingDto> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    try {
      final response = await dio.patch(
        BookingApiEndpoints.cancelBooking(bookingId),
        data: {'reason': reason},
      );

      return BookingDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownFailure('Failed to cancel booking: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getBookingStats({
    required String userId,
    required String userRole,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = {
        'user_role': userRole,
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
      };

      final response = await dio.get(
        BookingApiEndpoints.getBookingStats,
        queryParameters: queryParams,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownFailure('Failed to get booking stats: $e');
    }
  }

  @override
  Future<BookingListResponseDto> searchBookings({
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
      final queryParams = <String, String>{};
      if (query != null) queryParams['q'] = query;
      if (status != null) queryParams['status'] = status.value;
      if (fromDate != null)
        queryParams['from_date'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['to_date'] = toDate.toIso8601String();
      if (tutorId != null) queryParams['tutor_id'] = tutorId;
      if (studentId != null) queryParams['student_id'] = studentId;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final response = await dio.get(
        BookingApiEndpoints.searchBookings,
        queryParameters: queryParams,
      );

      return BookingListResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownFailure('Failed to search bookings: $e');
    }
  }

  @override
  Future<List<BookingDto>> getUpcomingBookings({
    required String userId,
    required String userRole,
    int days = 7,
  }) async {
    try {
      final queryParams = {'user_role': userRole, 'days': days.toString()};

      final response = await dio.get(
        BookingApiEndpoints.getUpcomingBookings,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data;
      return data.map((json) => BookingDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownFailure('Failed to get upcoming bookings: $e');
    }
  }

  /// Map Dio exceptions to domain failures
  BookingFailure _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'No internet connection. Please check your network.',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Unknown server error';

        return switch (statusCode) {
          400 => ValidationFailure('Invalid request: $message'),
          401 => const AuthorizationFailure(
            'Authentication required. Please log in.',
          ),
          403 => const AuthorizationFailure(
            'Access denied. You don\'t have permission.',
          ),
          404 => NotFoundFailure('Booking not found: $message'),
          409 => ConflictFailure('Booking conflict: $message'),
          422 => ValidationFailure('Validation error: $message'),
          _ when statusCode != null && statusCode >= 500 => ServerFailure(
            'Server error: $message',
            statusCode: statusCode,
          ),
          _ => ServerFailure('HTTP error: $message', statusCode: statusCode),
        };

      case DioExceptionType.cancel:
        return const UnknownFailure('Request was cancelled');

      case DioExceptionType.unknown:
        return UnknownFailure('Network error: ${e.message}');

      default:
        return UnknownFailure('Unknown error: ${e.message}');
    }
  }
}
