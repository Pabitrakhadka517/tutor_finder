import '../../domain/entities/dashboard_entity.dart';
import '../../domain/usecases/dashboard_analytics_usecase.dart';

/// Presentation model for student dashboard
class StudentDashboardPresentationModel {
  final String studentId;
  final List<DashboardStatistic> primaryStatistics;
  final List<DashboardStatistic> secondaryStatistics;
  final List<DashboardActivityItem> recentActivity;
  final ProgressIndicatorData? progressData;
  final List<SubjectStatistic> subjectBreakdown;
  final String formattedTotalSpent;
  final String formattedLastActivity;
  final bool hasRecentActivity;

  const StudentDashboardPresentationModel({
    required this.studentId,
    required this.primaryStatistics,
    required this.secondaryStatistics,
    required this.recentActivity,
    this.progressData,
    required this.subjectBreakdown,
    required this.formattedTotalSpent,
    required this.formattedLastActivity,
    required this.hasRecentActivity,
  });

  /// Create presentation model from domain entity
  factory StudentDashboardPresentationModel.fromEntity(
    StudentDashboardEntity entity,
  ) {
    final aggregates = entity.calculateAggregates();

    // Format primary statistics
    final primaryStats = [
      DashboardStatistic(
        label: 'Total Bookings',
        value: entity.totalBookings.toString(),
        icon: 'calendar',
        color: 'blue',
        trend: null,
      ),
      DashboardStatistic(
        label: 'Completed Sessions',
        value: entity.completedBookings.toString(),
        icon: 'check_circle',
        color: 'green',
        trend: null,
      ),
      DashboardStatistic(
        label: 'Total Spent',
        value: '\$${entity.totalSpent.toStringAsFixed(2)}',
        icon: 'paid',
        color: 'orange',
        trend: null,
      ),
      DashboardStatistic(
        label: 'Tutors Worked With',
        value: entity.totalTutorsWorkedWith.toString(),
        icon: 'people',
        color: 'purple',
        trend: null,
      ),
    ];

    // Format secondary statistics
    final secondaryStats = [
      DashboardStatistic(
        label: 'Completion Rate',
        value: '${aggregates['completionRate']?.toStringAsFixed(1) ?? 0}%',
        icon: 'percent',
        color: 'teal',
        trend: null,
      ),
      DashboardStatistic(
        label: 'Avg. Session Cost',
        value:
            '\$${aggregates['averageSpentPerBooking']?.toStringAsFixed(2) ?? 0}',
        icon: 'attach_money',
        color: 'indigo',
        trend: null,
      ),
      DashboardStatistic(
        label: 'Upcoming Sessions',
        value: entity.upcomingBookings.toString(),
        icon: 'schedule',
        color: 'cyan',
        trend: null,
      ),
    ];

    // Format recent activity
    final recentActivity = <DashboardActivityItem>[
      ...entity.recentBookings
          .take(3)
          .map(
            (booking) => DashboardActivityItem(
              id: booking.id,
              type: 'booking',
              title: '${booking.subject} Session',
              subtitle: 'Scheduled for ${_formatDate(booking.scheduledDate)}',
              timestamp: booking.scheduledDate,
              status: booking.status.toString(),
              amount: booking.amount,
            ),
          ),
      ...entity.recentTransactions
          .take(2)
          .map(
            (transaction) => DashboardActivityItem(
              id: transaction.id,
              type: 'transaction',
              title: transaction.description,
              subtitle: _formatDate(transaction.createdAt),
              timestamp: transaction.createdAt,
              status: transaction.status.toString(),
              amount: transaction.amount,
            ),
          ),
    ];

    // Sort by timestamp (most recent first)
    recentActivity.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Progress data
    ProgressIndicatorData? progressData;
    if (entity.progress != null) {
      final totalProgress =
          entity.progress!.subjectProgress.values.fold(
            0.0,
            (sum, progress) => sum + progress,
          ) /
          entity.progress!.subjectProgress.length;

      progressData = ProgressIndicatorData(
        overallProgress: totalProgress,
        subjectProgress: entity.progress!.subjectProgress,
        completedMilestones: entity.progress!.completedMilestones.length,
        totalMilestones:
            entity.progress!.completedMilestones.length + 5, // Estimated
      );
    }

    // Subject breakdown (mocked for now, would come from aggregates)
    final subjectBreakdown = <SubjectStatistic>[
      SubjectStatistic(
        subject: 'Mathematics',
        sessions: entity.completedBookings ~/ 3,
        percentage: 35.0,
        color: 'blue',
      ),
      SubjectStatistic(
        subject: 'Science',
        sessions: entity.completedBookings ~/ 4,
        percentage: 25.0,
        color: 'green',
      ),
      SubjectStatistic(
        subject: 'English',
        sessions: entity.completedBookings ~/ 5,
        percentage: 20.0,
        color: 'orange',
      ),
    ];

    return StudentDashboardPresentationModel(
      studentId: entity.studentId,
      primaryStatistics: primaryStats,
      secondaryStatistics: secondaryStats,
      recentActivity: recentActivity.take(5).toList(),
      progressData: progressData,
      subjectBreakdown: subjectBreakdown,
      formattedTotalSpent: '\$${entity.totalSpent.toStringAsFixed(2)}',
      formattedLastActivity: _formatDate(entity.lastActivity),
      hasRecentActivity: recentActivity.isNotEmpty,
    );
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return '${difference.inHours}h ago';
      }
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

/// Presentation model for tutor dashboard
class TutorDashboardPresentationModel {
  final String tutorId;
  final List<DashboardStatistic> primaryStatistics;
  final List<DashboardStatistic> secondaryStatistics;
  final List<DashboardActivityItem> recentActivity;
  final PerformanceIndicatorData performanceData;
  final List<SubjectStatistic> subjectBreakdown;
  final String formattedTotalEarnings;
  final String formattedThisMonthEarnings;
  final String verificationStatusDisplay;
  final bool hasRecentActivity;

  const TutorDashboardPresentationModel({
    required this.tutorId,
    required this.primaryStatistics,
    required this.secondaryStatistics,
    required this.recentActivity,
    required this.performanceData,
    required this.subjectBreakdown,
    required this.formattedTotalEarnings,
    required this.formattedThisMonthEarnings,
    required this.verificationStatusDisplay,
    required this.hasRecentActivity,
  });

  /// Create presentation model from domain entity
  factory TutorDashboardPresentationModel.fromEntity(
    TutorDashboardEntity entity,
  ) {
    final aggregates = entity.calculateAggregates();

    // Format primary statistics
    final primaryStats = [
      DashboardStatistic(
        label: 'Total Earnings',
        value: '\$${entity.totalEarnings.toStringAsFixed(2)}',
        icon: 'paid',
        color: 'green',
        trend: null,
      ),
      DashboardStatistic(
        label: 'Students Taught',
        value: entity.totalStudentsWorkedWith.toString(),
        icon: 'school',
        color: 'blue',
        trend: null,
      ),
      DashboardStatistic(
        label: 'Average Rating',
        value: entity.averageRating.toStringAsFixed(1),
        icon: 'star',
        color: 'orange',
        trend: null,
      ),
      DashboardStatistic(
        label: 'Completed Sessions',
        value: entity.completedBookings.toString(),
        icon: 'check_circle',
        color: 'purple',
        trend: null,
      ),
    ];

    // Format secondary statistics
    final secondaryStats = [
      DashboardStatistic(
        label: 'This Month',
        value: '\$${entity.thisMonthEarnings.toStringAsFixed(2)}',
        icon: 'calendar_today',
        color: 'teal',
        trend: null,
      ),
      DashboardStatistic(
        label: 'Total Reviews',
        value: entity.totalReviews.toString(),
        icon: 'rate_review',
        color: 'indigo',
        trend: null,
      ),
      DashboardStatistic(
        label: 'Pending Sessions',
        value: entity.pendingBookings.toString(),
        icon: 'pending',
        color: 'amber',
        trend: null,
      ),
    ];

    // Format recent activity
    final recentActivity = entity.recentBookings
        .map(
          (booking) => DashboardActivityItem(
            id: booking.id,
            type: 'booking',
            title: '${booking.subject} Session',
            subtitle: 'With Student ${booking.studentId}',
            timestamp: booking.scheduledDate,
            status: booking.status.toString(),
            amount: booking.amount,
          ),
        )
        .take(5)
        .toList();

    // Performance data
    final performanceData = PerformanceIndicatorData(
      overallScore: aggregates['performanceScore']?.toDouble() ?? 0.0,
      ratingScore: (entity.averageRating / 5.0) * 100,
      completionRate: aggregates['completionRate']?.toDouble() ?? 0.0,
      responseRate: aggregates['responseRate']?.toDouble() ?? 0.0,
      verificationStatus: entity.verificationStatus.toString(),
    );

    // Subject breakdown
    final subjectBreakdown = entity.teachingSubjects.asMap().entries.map((
      entry,
    ) {
      final index = entry.key;
      final subject = entry.value;
      final colors = ['blue', 'green', 'orange', 'purple', 'teal'];

      return SubjectStatistic(
        subject: subject,
        sessions: entity.completedBookings ~/ (index + 1),
        percentage: 100.0 / entity.teachingSubjects.length,
        color: colors[index % colors.length],
      );
    }).toList();

    return TutorDashboardPresentationModel(
      tutorId: entity.tutorId,
      primaryStatistics: primaryStats,
      secondaryStatistics: secondaryStats,
      recentActivity: recentActivity,
      performanceData: performanceData,
      subjectBreakdown: subjectBreakdown,
      formattedTotalEarnings: '\$${entity.totalEarnings.toStringAsFixed(2)}',
      formattedThisMonthEarnings:
          '\$${entity.thisMonthEarnings.toStringAsFixed(2)}',
      verificationStatusDisplay: entity.verificationStatus
          .toString()
          .split('.')
          .last,
      hasRecentActivity: recentActivity.isNotEmpty,
    );
  }
}

/// Presentation model for dashboard analytics
class DashboardAnalyticsPresentationModel {
  final String userId;
  final String userRole;
  final List<ChartData> trendsData;
  final List<InsightItem> insights;
  final List<RecommendationItem> recommendations;
  final String analysisDepth;
  final String generatedAt;

  const DashboardAnalyticsPresentationModel({
    required this.userId,
    required this.userRole,
    required this.trendsData,
    required this.insights,
    required this.recommendations,
    required this.analysisDepth,
    required this.generatedAt,
  });

  /// Create from domain analytics
  factory DashboardAnalyticsPresentationModel.fromAnalytics(
    DashboardAnalytics analytics,
  ) {
    final trendsData = <ChartData>[
      ChartData(label: 'Jan', value: 100.0, color: 'blue'),
      ChartData(label: 'Feb', value: 120.0, color: 'blue'),
      ChartData(label: 'Mar', value: 110.0, color: 'blue'),
    ];

    final insights = <InsightItem>[
      InsightItem(
        title: 'Performance Trend',
        description: 'Your metrics have improved by 15% this month',
        type: 'positive',
        icon: 'trending_up',
      ),
    ];

    final recommendations = <RecommendationItem>[
      RecommendationItem(
        title: 'Increase Session Frequency',
        description: 'Consider scheduling more sessions to boost earnings',
        priority: 'medium',
        actionable: true,
      ),
    ];

    return DashboardAnalyticsPresentationModel(
      userId: analytics.userId,
      userRole: analytics.role.value,
      trendsData: trendsData,
      insights: insights,
      recommendations: recommendations,
      analysisDepth: analytics.analysisDepth.toString(),
      generatedAt: analytics.generatedAt.toString(),
    );
  }
}

/// Presentation model for dashboard summary
class DashboardSummaryPresentationModel {
  final List<String> quickStats;
  final Map<String, String> formattedMetrics;
  final String lastCalculated;

  const DashboardSummaryPresentationModel({
    required this.quickStats,
    required this.formattedMetrics,
    required this.lastCalculated,
  });

  /// Create from map data
  factory DashboardSummaryPresentationModel.fromMap(Map<String, dynamic> data) {
    return DashboardSummaryPresentationModel(
      quickStats: List<String>.from(data['quickStats'] ?? []),
      formattedMetrics: Map<String, String>.from(
        data['formattedMetrics'] ?? {},
      ),
      lastCalculated: data['lastCalculated'] ?? '',
    );
  }
}

// Supporting classes for presentation

class DashboardStatistic {
  final String label;
  final String value;
  final String icon;
  final String color;
  final TrendIndicator? trend;

  const DashboardStatistic({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });
}

class DashboardActivityItem {
  final String id;
  final String type;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String status;
  final double amount;

  const DashboardActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.status,
    required this.amount,
  });
}

class ProgressIndicatorData {
  final double overallProgress;
  final Map<String, double> subjectProgress;
  final int completedMilestones;
  final int totalMilestones;

  const ProgressIndicatorData({
    required this.overallProgress,
    required this.subjectProgress,
    required this.completedMilestones,
    required this.totalMilestones,
  });
}

class PerformanceIndicatorData {
  final double overallScore;
  final double ratingScore;
  final double completionRate;
  final double responseRate;
  final String verificationStatus;

  const PerformanceIndicatorData({
    required this.overallScore,
    required this.ratingScore,
    required this.completionRate,
    required this.responseRate,
    required this.verificationStatus,
  });
}

class SubjectStatistic {
  final String subject;
  final int sessions;
  final double percentage;
  final String color;

  const SubjectStatistic({
    required this.subject,
    required this.sessions,
    required this.percentage,
    required this.color,
  });
}

class TrendIndicator {
  final double value;
  final bool isPositive;
  final String formattedValue;

  const TrendIndicator({
    required this.value,
    required this.isPositive,
    required this.formattedValue,
  });
}

class ChartData {
  final String label;
  final double value;
  final String color;

  const ChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class InsightItem {
  final String title;
  final String description;
  final String type;
  final String icon;

  const InsightItem({
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
  });
}

class RecommendationItem {
  final String title;
  final String description;
  final String priority;
  final bool actionable;

  const RecommendationItem({
    required this.title,
    required this.description,
    required this.priority,
    required this.actionable,
  });
}
