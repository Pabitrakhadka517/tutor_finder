import 'package:flutter/material.dart';

import '../models/dashboard_presentation_model.dart';

/// Grid widget for displaying dashboard statistics
class DashboardStatisticsGrid extends StatelessWidget {
  final List<DashboardStatistic> statistics;
  final String? title;
  final int crossAxisCount;
  final double childAspectRatio;

  const DashboardStatisticsGrid({
    Key? key,
    required this.statistics,
    this.title,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: statistics.length,
          itemBuilder: (context, index) {
            return DashboardStatisticCard(statistic: statistics[index]);
          },
        ),
      ],
    );
  }
}

/// Individual statistic card widget
class DashboardStatisticCard extends StatelessWidget {
  final DashboardStatistic statistic;

  const DashboardStatisticCard({Key? key, required this.statistic})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getColorFromString(statistic.color);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconFromString(statistic.icon),
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              if (statistic.trend != null)
                _buildTrendIndicator(statistic.trend!),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            statistic.value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            statistic.label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator(TrendIndicator trend) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: trend.isPositive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trend.isPositive ? Icons.trending_up : Icons.trending_down,
            size: 12,
            color: trend.isPositive ? Colors.green[600] : Colors.red[600],
          ),
          const SizedBox(width: 2),
          Text(
            trend.formattedValue,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: trend.isPositive ? Colors.green[600] : Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      case 'cyan':
        return Colors.cyan;
      case 'amber':
        return Colors.amber;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'calendar':
        return Icons.calendar_today;
      case 'check_circle':
        return Icons.check_circle;
      case 'paid':
        return Icons.paid;
      case 'people':
        return Icons.people;
      case 'percent':
        return Icons.percent;
      case 'attach_money':
        return Icons.attach_money;
      case 'schedule':
        return Icons.schedule;
      case 'school':
        return Icons.school;
      case 'star':
        return Icons.star;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'rate_review':
        return Icons.rate_review;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.info;
    }
  }
}
