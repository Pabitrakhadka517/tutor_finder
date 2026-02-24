import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/dashboard_repository.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../state/dashboard_state.dart';

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository repository;

  DashboardNotifier({required this.repository}) : super(const DashboardState());

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
    // Admin dashboard not currently supported by repository
    state = state.copyWith(
      isLoading: false,
      errorMessage: 'Admin dashboard not yet implemented',
    );
  }
}
