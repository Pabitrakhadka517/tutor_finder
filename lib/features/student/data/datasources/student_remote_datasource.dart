import '../../../../core/api/api_client.dart';

/// Remote data source for student-specific API calls.
///
/// TODO: Implement actual HTTP calls as the student feature matures.
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
    final response = await apiClient.get('/api/profile');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await apiClient.put('/api/profile', data: data);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getRecommendedTutors({
    int limit = 10,
  }) async {
    final response = await apiClient.get(
      '/api/tutors',
      queryParameters: {'limit': limit, 'sort': 'rating'},
    );
    final list = response.data['tutors'] as List? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> searchTutors({
    required String query,
    String? subject,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{
      'search': query,
      'page': page,
      'limit': limit,
    };
    if (subject != null) params['subject'] = subject;

    final response = await apiClient.get(
      '/api/tutors',
      queryParameters: params,
    );
    final list = response.data['tutors'] as List? ?? [];
    return list.cast<Map<String, dynamic>>();
  }
}
