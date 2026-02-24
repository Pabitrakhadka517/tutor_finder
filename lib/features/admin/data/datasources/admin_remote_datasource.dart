import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/admin_models.dart';

abstract class AdminRemoteDataSource {
  Future<({List<AdminUserModel> users, int total, int pages})> getAllUsers({
    int page,
    int limit,
    String? role,
  });
  Future<PlatformStatsModel> getPlatformStats();
  Future<String> seedTutors({int count});
  Future<void> verifyTutor({required String tutorId, required String status});
  Future<AdminUserModel> getUserById(String id);
  Future<AdminUserModel> updateUser({
    required String id,
    required Map<String, dynamic> data,
  });
  Future<void> deleteUser(String id);
  Future<AnnouncementModel> createAnnouncement({
    required String title,
    required String content,
    String targetRole,
    String type,
    DateTime? expiresAt,
  });
  Future<List<AnnouncementModel>> getAnnouncements();
  Future<void> deleteAnnouncement(String id);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient apiClient;
  AdminRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<({List<AdminUserModel> users, int total, int pages})> getAllUsers({
    int page = 1,
    int limit = 10,
    String? role,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (role != null && role.isNotEmpty) queryParams['role'] = role;

      final response = await apiClient.dio.get(
        ApiEndpoints.adminUsers,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final usersJson = data['users'] as List? ?? [];
        return (
          users: usersJson
              .map((u) => AdminUserModel.fromJson(u as Map<String, dynamic>))
              .toList(),
          total: data['total'] as int? ?? 0,
          pages: data['pages'] as int? ?? 1,
        );
      }
      throw ServerException( 'Failed to fetch users');
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Failed to fetch users',
      );
    }
  }

  @override
  Future<PlatformStatsModel> getPlatformStats() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.adminStats);

      if (response.statusCode == 200) {
        return PlatformStatsModel.fromJson(response.data);
      }
      throw ServerException( 'Failed to fetch stats');
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Failed to fetch stats',
      );
    }
  }

  @override
  Future<String> seedTutors({int count = 5}) async {
    try {
      final response = await apiClient.dio.post(
        '${ApiEndpoints.adminUsers}/seed',
        queryParameters: {'count': count},
      );

      if (response.statusCode == 200) {
        return response.data['message']?.toString() ?? 'Tutors seeded';
      }
      throw ServerException( 'Failed to seed tutors');
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to seed tutors',
      );
    }
  }

  @override
  Future<void> verifyTutor({
    required String tutorId,
    required String status,
  }) async {
    try {
      final response = await apiClient.dio.patch(
        ApiEndpoints.verifyTutor(tutorId),
        data: {'status': status},
      );

      if (response.statusCode == 200) return;
      throw ServerException( response.data['message'] ?? 'Failed to verify tutor',
      );
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to verify tutor',
      );
    }
  }

  @override
  Future<AdminUserModel> getUserById(String id) async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.adminUserById(id));

      if (response.statusCode == 200) {
        return AdminUserModel.fromJson(response.data['user']);
      }
      throw ServerException( 'Failed to fetch user');
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to fetch user',
      );
    }
  }

  @override
  Future<AdminUserModel> updateUser({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await apiClient.dio.put(
        ApiEndpoints.adminUserById(id),
        data: data,
      );

      if (response.statusCode == 200) {
        return AdminUserModel.fromJson(response.data['user']);
      }
      throw ServerException( 'Failed to update user');
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to update user',
      );
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      final response = await apiClient.dio.delete(
        ApiEndpoints.adminUserById(id),
      );

      if (response.statusCode == 200) return;
      throw ServerException( response.data['message'] ?? 'Failed to delete user',
      );
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to delete user',
      );
    }
  }

  @override
  Future<AnnouncementModel> createAnnouncement({
    required String title,
    required String content,
    String targetRole = 'ALL',
    String type = 'INFO',
    DateTime? expiresAt,
  }) async {
    try {
      final data = <String, dynamic>{
        'title': title,
        'content': content,
        'targetRole': targetRole,
        'type': type,
      };
      if (expiresAt != null) data['expiresAt'] = expiresAt.toIso8601String();

      final response = await apiClient.dio.post(
        ApiEndpoints.announcements,
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AnnouncementModel.fromJson(response.data['announcement']);
      }
      throw ServerException( response.data['message'] ?? 'Failed to create announcement',
      );
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to create announcement',
      );
    }
  }

  @override
  Future<List<AnnouncementModel>> getAnnouncements() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.announcements);

      if (response.statusCode == 200) {
        final list = response.data['announcements'] as List? ?? [];
        return list
            .map((a) => AnnouncementModel.fromJson(a as Map<String, dynamic>))
            .toList();
      }
      throw ServerException( 'Failed to fetch announcements');
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to fetch announcements',
      );
    }
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    try {
      final response = await apiClient.dio.delete(
        ApiEndpoints.deleteAnnouncement(id),
      );

      if (response.statusCode == 200) return;
      throw ServerException( response.data['message'] ?? 'Failed to delete announcement',
      );
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to delete announcement',
      );
    }
  }
}
