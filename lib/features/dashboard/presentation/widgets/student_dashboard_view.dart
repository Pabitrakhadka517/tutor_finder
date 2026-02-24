import 'package:flutter/material.dart';

import '../models/dashboard_presentation_model.dart';
import 'dashboard_statistics_grid.dart';
import 'recent_activity_widget.dart';
import 'progress_indicator_widget.dart';
import 'subject_breakdown_widget.dart';

/// Student-specific dashboard view
class StudentDashboardView extends StatelessWidget {
  final StudentDashboardPresentationModel dashboard;
  final VoidCallback? onRefresh;

  const StudentDashboardView({
    Key? key,
    required this.dashboard,
    this.onRefresh,
  }) : super(key: key);

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
            title: 'Learning Overview',
          ),
          const SizedBox(height: 24),

          // Progress indicator (if available)
          if (dashboard.progressData != null) ...[
            ProgressIndicatorWidget(progressData: dashboard.progressData!),
            const SizedBox(height: 24),
          ],

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
              title: 'Subjects Studied',
            ),
            const SizedBox(height: 24),
          ],

          // Recent activity
          if (dashboard.hasRecentActivity)
            RecentActivityWidget(
              activities: dashboard.recentActivity,
              title: 'Recent Activity',
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
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
              const Icon(Icons.school, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Student Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Total Spent: ${dashboard.formattedTotalSpent}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last Activity: ${dashboard.formattedLastActivity}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
