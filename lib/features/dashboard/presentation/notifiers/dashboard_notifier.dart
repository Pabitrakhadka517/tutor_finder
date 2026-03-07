import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../domain/dashboard_repository.dart';
import '../state/dashboard_state.dart';

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository repository;
  final DashboardRemoteDataSource remoteDataSource;

  DashboardNotifier({required this.repository, required this.remoteDataSource})
    : super(const DashboardState());

  Future<void> fetchStudentDashboard(String studentId) async {
    state = state.copyWith(isLoading: true);
    final result = await repository.getStudentDashboard(studentId);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.toString(),
      ),
      (stats) => state = state.copyWith(isLoading: false, studentStats: stats),
    );
  }

  Future<void> fetchTutorDashboard(String tutorId) async {
    state = state.copyWith(isLoading: true);
    final result = await repository.getTutorDashboard(tutorId);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.toString(),
      ),
      (stats) => state = state.copyWith(isLoading: false, tutorStats: stats),
    );
  }

  Future<void> fetchAdminDashboard() async {
    state = state.copyWith(isLoading: true);
    try {
      final adminModel = await remoteDataSource.getAdminDashboard();
      state = state.copyWith(isLoading: false, adminStats: adminModel);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load admin dashboard: ${e.toString()}',
      );
    }
  }
}
