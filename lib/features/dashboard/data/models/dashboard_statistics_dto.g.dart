// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_statistics_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardStatisticsDto _$DashboardStatisticsDtoFromJson(
        Map<String, dynamic> json) =>
    DashboardStatisticsDto(
      totalActiveUsers: (json['totalActiveUsers'] as num).toInt(),
      totalSessions: (json['totalSessions'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      platformGrowthRate: (json['platformGrowthRate'] as num).toDouble(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$DashboardStatisticsDtoToJson(
        DashboardStatisticsDto instance) =>
    <String, dynamic>{
      'totalActiveUsers': instance.totalActiveUsers,
      'totalSessions': instance.totalSessions,
      'totalRevenue': instance.totalRevenue,
      'platformGrowthRate': instance.platformGrowthRate,
      'generatedAt': instance.generatedAt.toIso8601String(),
    };
