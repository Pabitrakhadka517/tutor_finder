import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import 'package:dio/dio.dart';

/// Remote data source for student-specific API calls.
abstract class StudentRemoteDataSource {
  Future<Map<String, dynamic>> getProfile(String userId);
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getRecommendedTutors({int limit = 10});
  Future<List<Map<String, dynamic>>> searchTutors({
    required String query,
    String? subject,
    int page = 1,
    int limit = 20,
  });
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final ApiClient apiClient;

  StudentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final response = await apiClient.get(ApiEndpoints.getProfile);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ?? 'Failed to fetch profile',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.updateProfile,
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ?? 'Failed to update profile',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecommendedTutors({
    int limit = 10,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.tutors,
        queryParameters: {'limit': limit, 'sortBy': 'rating', 'order': 'desc'},
      );
      final list = response.data['tutors'] as List? ?? [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ??
            'Failed to fetch recommended tutors',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchTutors({
    required String query,
    String? subject,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{
        'search': query,
        'page': page,
        'limit': limit,
      };
      if (subject != null && subject.trim().isNotEmpty) {
        params['subject'] = subject;
      }

      final response = await apiClient.get(
        ApiEndpoints.tutors,
        queryParameters: params,
      );
      final list = response.data['tutors'] as List? ?? [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ?? 'Failed to search tutors',
      );
    }
  }
}
