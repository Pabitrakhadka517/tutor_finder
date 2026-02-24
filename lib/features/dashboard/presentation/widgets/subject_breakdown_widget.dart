import 'package:flutter/material.dart';

import '../models/dashboard_presentation_model.dart';

/// Widget for displaying subject breakdown statistics
class SubjectBreakdownWidget extends StatelessWidget {
  final List<SubjectStatistic> subjects;
  final String? title;

  const SubjectBreakdownWidget({Key? key, required this.subjects, this.title})
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
          if (title != null)
            Text(
              title!,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 20),

          // Subject list
          ...subjects.map((subject) => _buildSubjectItem(context, subject)),

          if (subjects.length > 3) const SizedBox(height: 12),

          if (subjects.length > 3)
            TextButton(
              onPressed: () => _showAllSubjects(context),
              child: const Text('View All Subjects'),
            ),
        ],
      ),
    );
  }

  Widget _buildSubjectItem(BuildContext context, SubjectStatistic subject) {
    final color = _getSubjectColor(subject.color);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                subject.subject[0].toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
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
                      subject.subject,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${subject.percentage.toInt()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${subject.sessions} sessions',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 60,
                      child: LinearProgressIndicator(
                        value: subject.percentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAllSubjects(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title ?? 'All Subjects',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    return _buildSubjectItem(context, subjects[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSubjectColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blue':
        return Colors.blue[600]!;
      case 'green':
        return Colors.green[600]!;
      case 'orange':
        return Colors.orange[600]!;
      case 'purple':
        return Colors.purple[600]!;
      case 'teal':
        return Colors.teal[600]!;
      case 'indigo':
        return Colors.indigo[600]!;
      case 'cyan':
        return Colors.cyan[600]!;
      case 'amber':
        return Colors.amber[600]!;
      case 'red':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
