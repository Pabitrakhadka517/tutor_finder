import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/failures/dashboard_failure.dart';
import '../../domain/usecases/get_student_dashboard_usecase.dart';
import '../../domain/usecases/get_tutor_dashboard_usecase.dart';
import '../../domain/usecases/refresh_dashboard_usecase.dart';
import '../../domain/usecases/dashboard_analytics_usecase.dart';
import '../../domain/value_objects/user_role.dart';
import '../models/dashboard_state.dart';
import '../models/dashboard_presentation_model.dart';

/// Controller for managing dashboard state and operations
///
/// This controller handles all dashboard-related UI state management,
/// user interactions, and coordination between use cases.
@injectable
class DashboardController extends ChangeNotifier {
  final GetStudentDashboardUseCase _getStudentDashboardUseCase;
  final GetTutorDashboardUseCase _getTutorDashboardUseCase;
  final RefreshDashboardUseCase _refreshDashboardUseCase;
  final DashboardAnalyticsUseCase _analyticsUseCase;

  DashboardController(
    this._getStudentDashboardUseCase,
    this._getTutorDashboardUseCase,
    this._refreshDashboardUseCase,
    this._analyticsUseCase,
  );

  // State management
  DashboardState _state = DashboardState.initial();
  DashboardState get state => _state;

  bool get isLoading => _state.isLoading;
  bool get hasError => _state.failure != null;
  String? get errorMessage => _state.failure?.toString();

  // Dashboard data
  StudentDashboardPresentationModel? get studentDashboard =>
      _state.studentDashboard;
  TutorDashboardPresentationModel? get tutorDashboard => _state.tutorDashboard;
  DashboardAnalyticsPresentationModel? get analytics => _state.analytics;

  // User context
  String? _currentUserId;
  UserRole? _currentUserRole;

  String? get currentUserId => _currentUserId;
  UserRole? get currentUserRole => _currentUserRole;

  /// Initialize controller with user context
  void initialize(String userId, UserRole role) {
    _currentUserId = userId;
    _currentUserRole = role;

    // Auto-load dashboard on initialization
    loadDashboard();
  }

  /// Load dashboard data based on user role
  Future<void> loadDashboard({bool forceRefresh = false}) async {
    if (_currentUserId == null || _currentUserRole == null) {
      _updateState(
        _state.copyWith(
          failure: const DashboardFailure.validationError(
            'User context not initialized',
          ),
        ),
      );
      return;
    }

    _updateState(_state.copyWith(isLoading: true, failure: null));

    try {
      if (_currentUserRole == UserRole.student) {
        await _loadStudentDashboard(forceRefresh: forceRefresh);
      } else if (_currentUserRole == UserRole.tutor) {
        await _loadTutorDashboard(forceRefresh: forceRefresh);
      } else {
        _updateState(
          _state.copyWith(
            isLoading: false,
            failure: const DashboardFailure.permissionDenied(
              'Dashboard not available for this user role',
            ),
          ),
        );
      }
    } catch (e) {
      _updateState(
        _state.copyWith(
          isLoading: false,
          failure: DashboardFailure.serverError(
            'Failed to load dashboard: ${e.toString()}',
          ),
        ),
      );
    }
  }

  /// Load student-specific dashboard
  Future<void> _loadStudentDashboard({bool forceRefresh = false}) async {
    final result = await _getStudentDashboardUseCase.execute(
      _currentUserId!,
      forceRefresh: forceRefresh,
    );

    result.fold(
      (failure) {
        _updateState(_state.copyWith(isLoading: false, failure: failure));
      },
      (dashboard) {
        final presentationModel = StudentDashboardPresentationModel.fromEntity(
          dashboard,
        );
        _updateState(
          _state.copyWith(
            isLoading: false,
            failure: null,
            studentDashboard: presentationModel,
          ),
        );
      },
    );
  }

  /// Load tutor-specific dashboard
  Future<void> _loadTutorDashboard({bool forceRefresh = false}) async {
    final result = await _getTutorDashboardUseCase.execute(
      _currentUserId!,
      forceRefresh: forceRefresh,
    );

    result.fold(
      (failure) {
        _updateState(_state.copyWith(isLoading: false, failure: failure));
      },
      (dashboard) {
        final presentationModel = TutorDashboardPresentationModel.fromEntity(
          dashboard,
        );
        _updateState(
          _state.copyWith(
            isLoading: false,
            failure: null,
            tutorDashboard: presentationModel,
          ),
        );
      },
    );
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    if (_currentUserId == null || _currentUserRole == null) return;

    final result = await _refreshDashboardUseCase.refreshDashboard(
      _currentUserId!,
      _currentUserRole!,
      forceFullRefresh: true,
    );

    final failure = result.getLeftOrNull();
    if (failure != null) {
      _updateState(_state.copyWith(failure: failure));
      return;
    }

    await loadDashboard(forceRefresh: true);
  }

  /// Load analytics data
  Future<void> loadAnalytics({
    DateRangeFilter? dateRange,
    AnalysisDepth depth = AnalysisDepth.detailed,
  }) async {
    if (_currentUserId == null || _currentUserRole == null) return;

    _updateState(_state.copyWith(isLoading: true));

    final result = await _analyticsUseCase.getAnalytics(
      _currentUserId!,
      _currentUserRole!,
      analysisDepth: depth,
      dateRange: dateRange,
    );

    result.fold(
      (failure) {
        _updateState(_state.copyWith(isLoading: false, failure: failure));
      },
      (analytics) {
        final presentationModel =
            DashboardAnalyticsPresentationModel.fromAnalytics(analytics);
        _updateState(
          _state.copyWith(
            isLoading: false,
            failure: null,
            analytics: presentationModel,
          ),
        );
      },
    );
  }

  /// Load dashboard summary for quick view
  Future<void> loadSummary() async {
    if (_currentUserId == null || _currentUserRole == null) return;

    if (_currentUserRole == UserRole.student) {
      final result = await _getStudentDashboardUseCase.getSummary(
        _currentUserId!,
      );

      result.fold(
        (failure) {
          _updateState(_state.copyWith(failure: failure));
        },
        (summary) {
          // Update state with summary data
          _updateState(
            _state.copyWith(
              summary: DashboardSummaryPresentationModel.fromMap(summary),
            ),
          );
        },
      );
    } else if (_currentUserRole == UserRole.tutor) {
      final result = await _getTutorDashboardUseCase.getSummary(
        _currentUserId!,
      );

      result.fold(
        (failure) {
          _updateState(_state.copyWith(failure: failure));
        },
        (summary) {
          // Update state with summary data
          _updateState(
            _state.copyWith(
              summary: DashboardSummaryPresentationModel.fromMap(summary),
            ),
          );
        },
      );
    }
  }

  /// Clear error state
  void clearError() {
    _updateState(_state.copyWith(failure: null));
  }

  /// Reset controller state
  void reset() {
    _currentUserId = null;
    _currentUserRole = null;
    _updateState(DashboardState.initial());
  }

  /// Update state and notify listeners
  void _updateState(DashboardState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }

  // Utility methods for presentation logic

  /// Get formatted dashboard title based on user role
  String getDashboardTitle() {
    return _currentUserRole?.displayName ?? 'Dashboard';
  }

  /// Check if user can access analytics
  bool canAccessAnalytics() {
    return _currentUserRole != null &&
        (_currentUserRole == UserRole.tutor ||
            _currentUserRole == UserRole.student);
  }

  /// Get primary statistics for current dashboard
  List<DashboardStatistic> getPrimaryStatistics() {
    if (_currentUserRole == UserRole.student && studentDashboard != null) {
      return studentDashboard!.primaryStatistics;
    } else if (_currentUserRole == UserRole.tutor && tutorDashboard != null) {
      return tutorDashboard!.primaryStatistics;
    }
    return [];
  }

  /// Get recent activity items
  List<DashboardActivityItem> getRecentActivity() {
    if (_currentUserRole == UserRole.student && studentDashboard != null) {
      return studentDashboard!.recentActivity;
    } else if (_currentUserRole == UserRole.tutor && tutorDashboard != null) {
      return tutorDashboard!.recentActivity;
    }
    return [];
  }

  /// Check if dashboard has data
  bool hasDashboardData() {
    return (_currentUserRole == UserRole.student && studentDashboard != null) ||
        (_currentUserRole == UserRole.tutor && tutorDashboard != null);
  }

  /// Get dashboard loading message
  String getLoadingMessage() {
    if (_currentUserRole == UserRole.student) {
      return 'Loading student dashboard...';
    } else if (_currentUserRole == UserRole.tutor) {
      return 'Loading tutor dashboard...';
    }
    return 'Loading dashboard...';
  }
}
