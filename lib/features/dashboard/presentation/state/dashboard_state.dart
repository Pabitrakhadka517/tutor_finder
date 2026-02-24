import '../../domain/entities/dashboard_entity.dart';

class DashboardState {
  final bool isLoading;
  final String? errorMessage;
  final StudentDashboardEntity? studentStats;
  final TutorDashboardEntity? tutorStats;
  final dynamic adminStats;

  const DashboardState({
    this.isLoading = false,
    this.errorMessage,
    this.studentStats,
    this.tutorStats,
    this.adminStats,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    StudentDashboardEntity? studentStats,
    TutorDashboardEntity? tutorStats,
    dynamic adminStats,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      studentStats: studentStats ?? this.studentStats,
      tutorStats: tutorStats ?? this.tutorStats,
      adminStats: adminStats ?? this.adminStats,
    );
  }
}
