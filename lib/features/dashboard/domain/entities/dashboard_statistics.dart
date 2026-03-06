import 'package:equatable/equatable.dart';

/// Platform-level statistics entity
class DashboardStatistics extends Equatable {
  final int totalActiveUsers;
  final int totalSessions;
  final double totalRevenue;
  final double platformGrowthRate;
  final DateTime generatedAt;

  const DashboardStatistics({
    required this.totalActiveUsers,
    required this.totalSessions,
    required this.totalRevenue,
    required this.platformGrowthRate,
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [totalActiveUsers, totalSessions, generatedAt];
}
