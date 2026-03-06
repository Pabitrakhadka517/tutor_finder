import '../../domain/failures/dashboard_failure.dart';
import 'dashboard_presentation_model.dart';

/// State class for dashboard UI
class DashboardState {
  final bool isLoading;
  final DashboardFailure? failure;
  final StudentDashboardPresentationModel? studentDashboard;
  final TutorDashboardPresentationModel? tutorDashboard;
  final DashboardAnalyticsPresentationModel? analytics;
  final DashboardSummaryPresentationModel? summary;
  final DateTime? lastUpdated;

  const DashboardState({
    required this.isLoading,
    this.failure,
    this.studentDashboard,
    this.tutorDashboard,
    this.analytics,
    this.summary,
    this.lastUpdated,
  });

  /// Initial state
  factory DashboardState.initial() {
    return const DashboardState(
      isLoading: false,
      failure: null,
      studentDashboard: null,
      tutorDashboard: null,
      analytics: null,
      summary: null,
      lastUpdated: null,
    );
  }

  /// Loading state
  factory DashboardState.loading() {
    return const DashboardState(isLoading: true, failure: null);
  }

  /// Error state
  factory DashboardState.error(DashboardFailure failure) {
    return DashboardState(isLoading: false, failure: failure);
  }

  /// Success state with student dashboard
  factory DashboardState.studentLoaded(
    StudentDashboardPresentationModel dashboard,
  ) {
    return DashboardState(
      isLoading: false,
      failure: null,
      studentDashboard: dashboard,
      lastUpdated: DateTime.now(),
    );
  }

  /// Success state with tutor dashboard
  factory DashboardState.tutorLoaded(
    TutorDashboardPresentationModel dashboard,
  ) {
    return DashboardState(
      isLoading: false,
      failure: null,
      tutorDashboard: dashboard,
      lastUpdated: DateTime.now(),
    );
  }

  /// Copy with method for state updates
  DashboardState copyWith({
    bool? isLoading,
    DashboardFailure? failure,
    StudentDashboardPresentationModel? studentDashboard,
    TutorDashboardPresentationModel? tutorDashboard,
    DashboardAnalyticsPresentationModel? analytics,
    DashboardSummaryPresentationModel? summary,
    DateTime? lastUpdated,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      failure: failure,
      studentDashboard: studentDashboard ?? this.studentDashboard,
      tutorDashboard: tutorDashboard ?? this.tutorDashboard,
      analytics: analytics ?? this.analytics,
      summary: summary ?? this.summary,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Check if state has any dashboard data
  bool get hasData => studentDashboard != null || tutorDashboard != null;

  /// Check if state has error
  bool get hasError => failure != null;

  /// Check if data is fresh (less than 30 minutes old)
  bool get isDataFresh {
    if (lastUpdated == null) return false;
    final thirtyMinutesAgo = DateTime.now().subtract(
      const Duration(minutes: 30),
    );
    return lastUpdated!.isAfter(thirtyMinutesAgo);
  }

  @override
  String toString() {
    return 'DashboardState(isLoading: $isLoading, hasError: $hasError, hasData: $hasData)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DashboardState &&
        other.isLoading == isLoading &&
        other.failure == failure &&
        other.studentDashboard == studentDashboard &&
        other.tutorDashboard == tutorDashboard &&
        other.analytics == analytics &&
        other.summary == summary &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        failure.hashCode ^
        studentDashboard.hashCode ^
        tutorDashboard.hashCode ^
        analytics.hashCode ^
        summary.hashCode ^
        lastUpdated.hashCode;
  }
}
