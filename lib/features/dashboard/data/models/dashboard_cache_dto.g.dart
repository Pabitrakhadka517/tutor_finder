// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_cache_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardCacheDtoImpl _$$DashboardCacheDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$DashboardCacheDtoImpl(
      cacheKey: json['cacheKey'] as String,
      userId: json['userId'] as String,
      role: json['role'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      isValid: json['isValid'] as bool,
      version: json['version'] as String,
      data: json['data'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$DashboardCacheDtoImplToJson(
        _$DashboardCacheDtoImpl instance) =>
    <String, dynamic>{
      'cacheKey': instance.cacheKey,
      'userId': instance.userId,
      'role': instance.role,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'isValid': instance.isValid,
      'version': instance.version,
      'data': instance.data,
      'metadata': instance.metadata,
    };

_$CacheStatisticsDtoImpl _$$CacheStatisticsDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$CacheStatisticsDtoImpl(
      totalCacheEntries: (json['totalCacheEntries'] as num).toInt(),
      validEntries: (json['validEntries'] as num).toInt(),
      expiredEntries: (json['expiredEntries'] as num).toInt(),
      invalidEntries: (json['invalidEntries'] as num).toInt(),
      entriesByRole: Map<String, int>.from(json['entriesByRole'] as Map),
      averageAgeMinutes: (json['averageAgeMinutes'] as num).toDouble(),
      memoryUsage: json['memoryUsage'] as Map<String, dynamic>,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$$CacheStatisticsDtoImplToJson(
        _$CacheStatisticsDtoImpl instance) =>
    <String, dynamic>{
      'totalCacheEntries': instance.totalCacheEntries,
      'validEntries': instance.validEntries,
      'expiredEntries': instance.expiredEntries,
      'invalidEntries': instance.invalidEntries,
      'entriesByRole': instance.entriesByRole,
      'averageAgeMinutes': instance.averageAgeMinutes,
      'memoryUsage': instance.memoryUsage,
      'generatedAt': instance.generatedAt.toIso8601String(),
    };

_$DashboardSummaryDtoImpl _$$DashboardSummaryDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$DashboardSummaryDtoImpl(
      userId: json['userId'] as String,
      role: json['role'] as String,
      summary: json['summary'] as Map<String, dynamic>,
      quickStats: (json['quickStats'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      keyMetrics: (json['keyMetrics'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      lastCalculated: DateTime.parse(json['lastCalculated'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$DashboardSummaryDtoImplToJson(
        _$DashboardSummaryDtoImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'role': instance.role,
      'summary': instance.summary,
      'quickStats': instance.quickStats,
      'keyMetrics': instance.keyMetrics,
      'lastCalculated': instance.lastCalculated.toIso8601String(),
      'metadata': instance.metadata,
    };
