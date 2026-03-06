import '../../../../core/utils/either.dart';
import '../entities/dashboard_entity.dart';
import '../failures/dashboard_failure.dart';
import '../value_objects/user_role.dart';

/// Repository interface for dashboard domain operations
///
/// This interface defines all data operations needed for dashboard management
/// following the Repository pattern. The interface belongs to the domain layer
/// and implementations are provided by the data layer.
abstract class DashboardRepository {
  // Core Dashboard Operations

  /// Get student dashboard statistics for the specified user
  ///
  /// Returns [StudentDashboardEntity] with complete statistics including:
  /// - Booking analytics (total, upcoming, completed, cancelled)
  /// - Financial data (total spent, average per booking)
  /// - Learning progress (tutors worked with, subject distribution)
  /// - Recent activity (bookings and transactions)
  Future<Either<DashboardFailure, StudentDashboardEntity>> getStudentDashboard(
    String studentId,
  );

  /// Get tutor dashboard statistics for the specified user
  ///
  /// Returns [TutorDashboardEntity] with complete statistics including:
  /// - Earnings analytics (total, pending, average per booking)
  /// - Performance metrics (completion rate, rating, reviews)
  /// - Student interactions (total students, repeat students)
  /// - Verification status and business insights
  Future<Either<DashboardFailure, TutorDashboardEntity>> getTutorDashboard(
    String tutorId,
  );

  // Enhanced Query Operations

  /// Get filtered student dashboard with date range
  ///
  /// Allows filtering dashboard statistics by date range for trend analysis
  Future<Either<DashboardFailure, StudentDashboardEntity>>
  getStudentDashboardByDateRange(
    String studentId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get filtered tutor dashboard with date range
  ///
  /// Allows filtering dashboard statistics by date range for performance tracking
  Future<Either<DashboardFailure, TutorDashboardEntity>>
  getTutorDashboardByDateRange(
    String tutorId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get dashboard for any user based on their role
  ///
  /// Automatically determines which dashboard to return based on user role
  Future<Either<DashboardFailure, DashboardEntity>> getDashboardByRole(
    String userId,
    UserRole role,
  );

  // Dashboard Analytics Operations

  /// Check if user has sufficient data for meaningful dashboard
  ///
  /// Returns true if user has enough activity to generate useful statistics
  Future<Either<DashboardFailure, bool>> hasMinimumDataForDashboard(
    String userId,
    UserRole role,
  );

  /// Get dashboard summary for quick overview
  ///
  /// Returns minimal dashboard data for fast loading scenarios
  Future<Either<DashboardFailure, Map<String, dynamic>>> getDashboardSummary(
    String userId,
    UserRole role,
  );

  // Cache Management Operations

  /// Refresh dashboard cache for user
  ///
  /// Forces refresh of cached dashboard data from source
  Future<Either<DashboardFailure, void>> refreshDashboardCache(
    String userId,
    UserRole role,
  );

  /// Check if dashboard cache is valid
  ///
  /// Returns true if cached dashboard data is still valid
  Future<Either<DashboardFailure, bool>> isDashboardCacheValid(
    String userId,
    UserRole role,
  );

  // Dashboard Comparison Operations

  /// Get dashboard comparison data for time periods
  ///
  /// Returns comparison between current period and previous period
  Future<Either<DashboardFailure, Map<String, dynamic>>> getDashboardComparison(
    String userId,
    UserRole role,
    DateTime currentStart,
    DateTime currentEnd,
    DateTime previousStart,
    DateTime previousEnd,
  );

  /// Get dashboard trends over time
  ///
  /// Returns trend data for key metrics over specified period
  Future<Either<DashboardFailure, Map<String, List<dynamic>>>>
  getDashboardTrends(
    String userId,
    UserRole role,
    DateTime startDate,
    DateTime endDate,
    String interval, // 'daily', 'weekly', 'monthly'
  );

  // Validation Operations

  /// Validate user access to dashboard
  ///
  /// Checks if user has permission to access dashboard data
  Future<Either<DashboardFailure, bool>> validateDashboardAccess(
    String userId,
    UserRole role,
  );

  /// Validate dashboard data integrity
  ///
  /// Checks if dashboard data is consistent and complete
  Future<Either<DashboardFailure, bool>> validateDashboardData(
    String userId,
    UserRole role,
  );
}
