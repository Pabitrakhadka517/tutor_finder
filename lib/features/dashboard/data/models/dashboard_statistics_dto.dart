import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/dashboard_statistics.dart';

part 'dashboard_statistics_dto.g.dart';

@JsonSerializable()
class DashboardStatisticsDto {
  final int totalActiveUsers;
  final int totalSessions;
  final double totalRevenue;
  final double platformGrowthRate;
  final DateTime generatedAt;

  const DashboardStatisticsDto({
    required this.totalActiveUsers,
    required this.totalSessions,
    required this.totalRevenue,
    required this.platformGrowthRate,
    required this.generatedAt,
  });

  factory DashboardStatisticsDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatisticsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardStatisticsDtoToJson(this);

  DashboardStatistics toDomain() => DashboardStatistics(
    totalActiveUsers: totalActiveUsers,
    totalSessions: totalSessions,
    totalRevenue: totalRevenue,
    platformGrowthRate: platformGrowthRate,
    generatedAt: generatedAt,
  );

  factory DashboardStatisticsDto.fromDomain(DashboardStatistics entity) =>
      DashboardStatisticsDto(
        totalActiveUsers: entity.totalActiveUsers,
        totalSessions: entity.totalSessions,
        totalRevenue: entity.totalRevenue,
        platformGrowthRate: entity.platformGrowthRate,
        generatedAt: entity.generatedAt,
      );
}
