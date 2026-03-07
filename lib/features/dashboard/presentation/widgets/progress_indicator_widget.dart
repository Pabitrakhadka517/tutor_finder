import 'package:flutter/material.dart';

import '../models/dashboard_presentation_model.dart';

/// Widget for displaying student progress indicators
class ProgressIndicatorWidget extends StatelessWidget {
  final ProgressIndicatorData progressData;

  const ProgressIndicatorWidget({super.key, required this.progressData});

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
            'Learning Progress',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Overall progress
          _buildOverallProgress(context),
          const SizedBox(height: 24),

          // Subject progress
          if (progressData.subjectProgress.isNotEmpty) ...[
            Text(
              'Subject Progress',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            ...progressData.subjectProgress.entries.map(
              (entry) => _buildSubjectProgress(context, entry.key, entry.value),
            ),
          ],

          // Milestones
          const SizedBox(height: 20),
          _buildMilestones(context),
        ],
      ),
    );
  }

  Widget _buildOverallProgress(BuildContext context) {
    final progressPercentage = (progressData.overallProgress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Progress',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            Text(
              '$progressPercentage%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progressData.overallProgress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildSubjectProgress(
    BuildContext context,
    String subject,
    double progress,
  ) {
    final progressPercentage = (progress * 100).toInt();
    final color = _getSubjectColor(subject);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                '$progressPercentage%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildMilestones(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.emoji_events, color: Colors.blue[600], size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Milestones Achieved',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  '${progressData.completedMilestones} of ${progressData.totalMilestones} completed',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '${((progressData.completedMilestones / progressData.totalMilestones) * 100).toInt()}%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return Colors.blue[600]!;
      case 'science':
        return Colors.green[600]!;
      case 'english':
        return Colors.orange[600]!;
      case 'history':
        return Colors.purple[600]!;
      case 'physics':
        return Colors.teal[600]!;
      case 'chemistry':
        return Colors.indigo[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
