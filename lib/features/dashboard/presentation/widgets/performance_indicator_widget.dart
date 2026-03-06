import 'package:flutter/material.dart';

import '../models/dashboard_presentation_model.dart';

/// Widget for displaying tutor performance indicators
class PerformanceIndicatorWidget extends StatelessWidget {
  final PerformanceIndicatorData performanceData;

  const PerformanceIndicatorWidget({Key? key, required this.performanceData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Indicators',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Overall performance score
          _buildOverallScore(context),
          const SizedBox(height: 24),

          // Individual metrics
          _buildMetricRow(
            context,
            'Rating Score',
            performanceData.ratingScore,
            Icons.star,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            context,
            'Completion Rate',
            performanceData.completionRate,
            Icons.check_circle,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            context,
            'Response Rate',
            performanceData.responseRate,
            Icons.reply,
            Colors.blue,
          ),

          const SizedBox(height: 20),
          _buildVerificationStatus(context),
        ],
      ),
    );
  }

  Widget _buildOverallScore(BuildContext context) {
    final scorePercentage = performanceData.overallScore.toInt();
    final color = _getScoreColor(performanceData.overallScore);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                '$scorePercentage',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Performance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getScoreDescription(performanceData.overallScore),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(
            _getScoreIcon(performanceData.overallScore),
            color: color,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context,
    String label,
    double value,
    IconData icon,
    Color color,
  ) {
    final percentage = value.toInt();

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: value / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationStatus(BuildContext context) {
    final isVerified =
        performanceData.verificationStatus.toLowerCase() == 'verified';
    final color = isVerified ? Colors.green : Colors.orange;
    final icon = isVerified ? Icons.verified_user : Icons.schedule;
    final status = isVerified ? 'Verified' : 'Pending Verification';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Verification Status: $status',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) {
      return Colors.green[600]!;
    } else if (score >= 60) {
      return Colors.orange[600]!;
    } else {
      return Colors.red[600]!;
    }
  }

  IconData _getScoreIcon(double score) {
    if (score >= 80) {
      return Icons.emoji_events;
    } else if (score >= 60) {
      return Icons.trending_up;
    } else {
      return Icons.trending_down;
    }
  }

  String _getScoreDescription(double score) {
    if (score >= 90) {
      return 'Excellent performance!';
    } else if (score >= 80) {
      return 'Great performance!';
    } else if (score >= 70) {
      return 'Good performance';
    } else if (score >= 60) {
      return 'Room for improvement';
    } else {
      return 'Needs improvement';
    }
  }
}
