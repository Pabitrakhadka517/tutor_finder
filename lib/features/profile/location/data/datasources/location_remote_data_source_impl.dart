import 'package:dio/dio.dart';

import '../../../../../core/api/api_client.dart';
import '../../../../../core/api/api_endpoints.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/location_failures.dart';
import '../models/location_model.dart';
import '../datasources/location_remote_data_source.dart';

/// Implementation of LocationRemoteDataSource using Dio
class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final ApiClient apiClient;

  LocationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<void> updateLocation(LocationEntity location) async {
    try {
      final locationModel = LocationModel.fromEntity(location);

      // Using PATCH to update only the location field in profile
      await apiClient.patch(
        ApiEndpoints.updateProfile,
        data: {'address': location.address, 'location': locationModel.toJson()},
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = _extractErrorMessage(e);

      throw LocationUpdateFailure(message, statusCode: statusCode);
    } catch (e) {
      throw LocationUpdateFailure('Failed to update location: $e');
    }
  }

  String _extractErrorMessage(DioException e) {
    // Try to extract message from response
    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      if (data['message'] != null) {
        return data['message'].toString();
      }
      if (data['error'] != null) {
        return data['error'].toString();
      }
    }

    // Fallback to Dio exception type
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.sendTimeout:
        return 'Request timed out. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timed out. Please try again.';
      case DioExceptionType.badResponse:
        return 'Server error (${e.response?.statusCode}). Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      default:
        return 'Failed to update location. Please try again.';
    }
  }
}
