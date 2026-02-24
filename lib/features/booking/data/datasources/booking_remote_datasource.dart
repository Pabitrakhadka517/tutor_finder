import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<BookingModel> createBooking({
    required String tutorId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  });

  Future<List<BookingModel>> getBookings({String? status});

  Future<BookingModel> updateBookingStatus({
    required String bookingId,
    required String status,
  });

  Future<BookingModel> completeBooking(String bookingId);
  Future<BookingModel> cancelBooking(String bookingId);

  Future<BookingModel> updateBooking({
    required String bookingId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  });
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final ApiClient apiClient;
  BookingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<BookingModel> createBooking({
    required String tutorId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.createBooking,
        data: {
          'tutorId': tutorId,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return BookingModel.fromJson(response.data['booking']);
      }
      throw ServerException( response.data['message'] ?? 'Failed to create booking',
      );
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to create booking',
      );
    }
  }

  @override
  Future<List<BookingModel>> getBookings({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status != 'all') queryParams['status'] = status;

      final response = await apiClient.dio.get(
        ApiEndpoints.bookings,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final bookingsJson = response.data['bookings'] as List? ?? [];
        return bookingsJson
            .map((b) => BookingModel.fromJson(b as Map<String, dynamic>))
            .toList();
      }
      throw ServerException( 'Failed to fetch bookings');
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to fetch bookings',
      );
    }
  }

  @override
  Future<BookingModel> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      final response = await apiClient.dio.patch(
        ApiEndpoints.bookingStatus(bookingId),
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data['booking']);
      }
      throw ServerException( 'Failed to update booking status');
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to update booking status',
      );
    }
  }

  @override
  Future<BookingModel> completeBooking(String bookingId) async {
    try {
      final response = await apiClient.dio.patch(
        ApiEndpoints.completeBooking(bookingId),
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data['booking']);
      }
      throw ServerException( 'Failed to complete booking');
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to complete booking',
      );
    }
  }

  @override
  Future<BookingModel> cancelBooking(String bookingId) async {
    try {
      final response = await apiClient.dio.patch(
        ApiEndpoints.cancelBooking(bookingId),
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data['booking']);
      }
      throw ServerException( 'Failed to cancel booking');
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to cancel booking',
      );
    }
  }

  @override
  Future<BookingModel> updateBooking({
    required String bookingId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    try {
      final response = await apiClient.dio.put(
        ApiEndpoints.editBooking(bookingId),
        data: {
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data['booking']);
      }
      throw ServerException( 'Failed to update booking');
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to update booking',
      );
    }
  }
}
