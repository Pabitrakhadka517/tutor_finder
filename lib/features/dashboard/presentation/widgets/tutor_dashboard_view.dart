import 'package:flutter/material.dart';

import '../models/dashboard_presentation_model.dart';
import 'dashboard_statistics_grid.dart';
import 'recent_activity_widget.dart';
import 'performance_indicator_widget.dart';
import 'subject_breakdown_widget.dart';

/// Tutor-specific dashboard view
class TutorDashboardView extends StatelessWidget {
  final TutorDashboardPresentationModel dashboard;
  final VoidCallback? onRefresh;

  const TutorDashboardView({
    super.key,
    required this.dashboard,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          _buildWelcomeSection(context),
          const SizedBox(height: 24),

          // Primary statistics
          DashboardStatisticsGrid(
            statistics: dashboard.primaryStatistics,
            title: 'Tutoring Overview',
          ),
          const SizedBox(height: 24),

          // Performance indicator
          PerformanceIndicatorWidget(
            performanceData: dashboard.performanceData,
          ),
          const SizedBox(height: 24),

          // Secondary statistics
          DashboardStatisticsGrid(
            statistics: dashboard.secondaryStatistics,
            title: 'Detailed Statistics',
            crossAxisCount: 3,
          ),
          const SizedBox(height: 24),

          // Subject breakdown
          if (dashboard.subjectBreakdown.isNotEmpty) ...[
            SubjectBreakdownWidget(
              subjects: dashboard.subjectBreakdown,
              title: 'Teaching Subjects',
            ),
            const SizedBox(height: 24),
          ],

          // Recent activity
          if (dashboard.hasRecentActivity)
            RecentActivityWidget(
              activities: dashboard.recentActivity,
              title: 'Recent Sessions',
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText = dashboard.verificationStatusDisplay;

    switch (dashboard.verificationStatusDisplay.toLowerCase()) {
      case 'verified':
        statusColor = Colors.green;
        statusIcon = Icons.verified;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tutor Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Total Earnings: ${dashboard.formattedTotalEarnings}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This Month: ${dashboard.formattedThisMonthEarnings}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
