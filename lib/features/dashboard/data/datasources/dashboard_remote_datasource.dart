import 'package:dio/dio.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/dashboard_models.dart';

abstract class DashboardRemoteDataSource {
  Future<StudentDashboardModel> getStudentDashboard();
  Future<TutorDashboardModel> getTutorDashboard();
  Future<AdminDashboardModel> getAdminDashboard();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  DashboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<StudentDashboardModel> getStudentDashboard() async {
    try {
      final response = await dio.get(ApiEndpoints.studentDashboard);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          // Backend returns { success, stats, recentBookings, recentTransactions }
          final stats = data['stats'] is Map<String, dynamic>
              ? data['stats'] as Map<String, dynamic>
              : data;
          return StudentDashboardModel.fromJson(
            stats,
            recentBookings: data['recentBookings'] as List? ?? [],
            recentTransactions: data['recentTransactions'] as List? ?? [],
          );
        }
        return StudentDashboardModel.fromJson({});
      }
      throw ServerException('Failed to fetch student dashboard');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to fetch student dashboard',
      );
    }
  }

  @override
  Future<TutorDashboardModel> getTutorDashboard() async {
    try {
      final response = await dio.get(ApiEndpoints.tutorDashboard);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final stats = data['stats'] is Map<String, dynamic>
              ? data['stats'] as Map<String, dynamic>
              : data;
          return TutorDashboardModel.fromJson(
            stats,
            recentBookings: data['recentBookings'] as List? ?? [],
            recentTransactions: data['recentTransactions'] as List? ?? [],
          );
        }
        return TutorDashboardModel.fromJson({});
      }
      throw ServerException('Failed to fetch tutor dashboard');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to fetch tutor dashboard',
      );
    }
  }

  @override
  Future<AdminDashboardModel> getAdminDashboard() async {
    try {
      final response = await dio.get(ApiEndpoints.adminDashboard);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final stats = data['stats'] is Map<String, dynamic>
              ? data['stats'] as Map<String, dynamic>
              : data;
          return AdminDashboardModel.fromJson(stats);
        }
        return AdminDashboardModel.fromJson({});
      }
      throw ServerException('Failed to fetch admin dashboard');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to fetch admin dashboard',
      );
    }
  }
}
