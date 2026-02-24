import 'package:flutter/material.dart';

import '../../domain/entities/tutor_entity.dart';

/// Widget displaying comprehensive information about a tutor.
/// Used in the tutor detail screen to show bio, skills, ratings, etc.
class TutorDetailInfo extends StatelessWidget {
  const TutorDetailInfo({super.key, required this.tutor});

  final TutorEntity tutor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic info card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange[600], size: 20),
                    const SizedBox(width: 4),
                    Text(
                      tutor.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${tutor.reviewCount} reviews)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const Spacer(),
                    _buildVerificationBadge(context, tutor),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(
                      Icons.school,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tutor.education ?? 'Not specified',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tutor.location ?? 'Not specified',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Biography section
        if (tutor.biography.isNotEmpty) ...[
          Text(
            'About',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                tutor.biography,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Subjects section
        Text(
          'Subjects',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tutor.subjects
                  .map(
                    (subject) => Chip(
                      label: Text(subject),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Experience and availability info
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                context,
                icon: Icons.access_time,
                title: 'Experience',
                value: '${tutor.experienceYears} years',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildInfoCard(
                context,
                icon: Icons.schedule,
                title: 'Availability',
                value: tutor.isAvailable ? 'Available' : 'Unavailable',
                valueColor: tutor.isAvailable ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Languages section (if available)
        if (tutor.languages.isNotEmpty) ...[
          Text(
            'Languages',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tutor.languages
                    .map(
                      (language) => Chip(
                        label: Text(language),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVerificationBadge(BuildContext context, TutorEntity tutor) {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (tutor.verificationStatus) {
      case VerificationStatus.verified:
        badgeColor = Colors.green;
        badgeText = 'Verified';
        badgeIcon = Icons.verified;
        break;
      case VerificationStatus.pending:
        badgeColor = Colors.orange;
        badgeText = 'Pending';
        badgeIcon = Icons.pending;
        break;
      case VerificationStatus.unverified:
        badgeColor = Colors.grey;
        badgeText = 'Unverified';
        badgeIcon = Icons.help_outline;
        break;
      case VerificationStatus.rejected:
        badgeColor = Colors.red;
        badgeText = 'Rejected';
        badgeIcon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
