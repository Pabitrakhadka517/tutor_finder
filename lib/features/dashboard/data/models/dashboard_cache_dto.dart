import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/value_objects/user_role.dart';

part 'dashboard_cache_dto.freezed.dart';
part 'dashboard_cache_dto.g.dart';

/// Data Transfer Object for Dashboard Cache Information
///
/// This DTO handles serialization/deserialization for dashboard cache
/// metadata and status information used for cache management.
@freezed
class DashboardCacheDto with _$DashboardCacheDto {
  const factory DashboardCacheDto({
    required String cacheKey,
    required String userId,
    required String role,
    required DateTime lastUpdated,
    required DateTime expiresAt,
    required bool isValid,
    required String version,
    required Map<String, dynamic> data,
    Map<String, dynamic>? metadata,
  }) = _DashboardCacheDto;

  const DashboardCacheDto._();

  /// Create DTO from JSON
  factory DashboardCacheDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardCacheDtoFromJson(json);

  /// Create cache DTO for user dashboard
  static DashboardCacheDto create({
    required String userId,
    required UserRole role,
    required Map<String, dynamic> data,
    Duration? cacheExpiry,
    String version = '1.0',
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    final expiry = cacheExpiry ?? const Duration(minutes: 30);

    return DashboardCacheDto(
      cacheKey: 'dashboard_${role.value}_$userId',
      userId: userId,
      role: role.value,
      lastUpdated: now,
      expiresAt: now.add(expiry),
      isValid: true,
      version: version,
      data: Map.from(data),
      metadata: metadata,
    );
  }

  /// Check if cache is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if cache needs refresh
  bool needsRefresh({Duration? maxAge}) {
    if (!isValid || isExpired) return true;

    if (maxAge != null) {
      final ageLimit = lastUpdated.add(maxAge);
      return DateTime.now().isAfter(ageLimit);
    }

    return false;
  }

  /// Get cache age in minutes
  int get ageInMinutes => DateTime.now().difference(lastUpdated).inMinutes;

  /// Get time until expiry in minutes
  int get minutesUntilExpiry {
    final diff = expiresAt.difference(DateTime.now()).inMinutes;
    return diff < 0 ? 0 : diff;
  }

  /// Create updated cache with new data
  DashboardCacheDto withUpdatedData(
    Map<String, dynamic> newData, {
    Duration? newExpiry,
  }) {
    final now = DateTime.now();
    final expiry = newExpiry ?? const Duration(minutes: 30);

    return copyWith(
      data: Map.from(newData),
      lastUpdated: now,
      expiresAt: now.add(expiry),
      isValid: true,
    );
  }

  /// Mark cache as invalid
  DashboardCacheDto markInvalid() {
    return copyWith(isValid: false);
  }

  /// Extract cache statistics
  Map<String, dynamic> getStatistics() {
    return {
      'cacheKey': cacheKey,
      'userId': userId,
      'role': role,
      'ageInMinutes': ageInMinutes,
      'minutesUntilExpiry': minutesUntilExpiry,
      'isExpired': isExpired,
      'isValid': isValid,
      'dataSize': data.length,
      'version': version,
      'lastUpdated': lastUpdated.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}

/// Data Transfer Object for Aggregated Cache Statistics
@freezed
class CacheStatisticsDto with _$CacheStatisticsDto {
  const factory CacheStatisticsDto({
    required int totalCacheEntries,
    required int validEntries,
    required int expiredEntries,
    required int invalidEntries,
    required Map<String, int> entriesByRole,
    required double averageAgeMinutes,
    required Map<String, dynamic> memoryUsage,
    required DateTime generatedAt,
  }) = _CacheStatisticsDto;

  const CacheStatisticsDto._();

  factory CacheStatisticsDto.fromJson(Map<String, dynamic> json) =>
      _$CacheStatisticsDtoFromJson(json);

  /// Calculate cache efficiency percentage
  double get efficiency {
    if (totalCacheEntries == 0) return 0.0;
    return (validEntries / totalCacheEntries) * 100.0;
  }

  /// Get expiry rate percentage
  double get expiryRate {
    if (totalCacheEntries == 0) return 0.0;
    return (expiredEntries / totalCacheEntries) * 100.0;
  }
}

/// Data Transfer Object for Dashboard Summary Cache
@freezed
class DashboardSummaryDto with _$DashboardSummaryDto {
  const factory DashboardSummaryDto({
    required String userId,
    required String role,
    required Map<String, dynamic> summary,
    required List<String> quickStats,
    required Map<String, double> keyMetrics,
    required DateTime lastCalculated,
    Map<String, dynamic>? metadata,
  }) = _DashboardSummaryDto;

  factory DashboardSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardSummaryDtoFromJson(json);

  /// Create student summary
  static DashboardSummaryDto forStudent({
    required String studentId,
    required Map<String, dynamic> dashboardData,
  }) {
    final metrics = _extractStudentMetrics(dashboardData);
    final stats = _generateStudentStats(dashboardData);

    return DashboardSummaryDto(
      userId: studentId,
      role: 'student',
      summary: {
        'totalBookings': dashboardData['totalBookings'] ?? 0,
        'totalSpent': dashboardData['totalSpent'] ?? 0.0,
        'hoursLearned': dashboardData['totalHoursLearned'] ?? 0,
      },
      quickStats: stats,
      keyMetrics: metrics,
      lastCalculated: DateTime.now(),
    );
  }

  /// Create tutor summary
  static DashboardSummaryDto forTutor({
    required String tutorId,
    required Map<String, dynamic> dashboardData,
  }) {
    final metrics = _extractTutorMetrics(dashboardData);
    final stats = _generateTutorStats(dashboardData);

    return DashboardSummaryDto(
      userId: tutorId,
      role: 'tutor',
      summary: {
        'totalEarnings': dashboardData['totalEarnings'] ?? 0.0,
        'totalBookings': dashboardData['totalBookings'] ?? 0,
        'averageRating': dashboardData['averageRating'] ?? 0.0,
      },
      quickStats: stats,
      keyMetrics: metrics,
      lastCalculated: DateTime.now(),
    );
  }

  // Private helper methods for metric extraction

  static Map<String, double> _extractStudentMetrics(Map<String, dynamic> data) {
    return {
      'averageSessionCost': (data['averageSessionCost'] ?? 0.0).toDouble(),
      'completionRate': _calculateStudentCompletionRate(data),
      'learningVelocity': _calculateLearningVelocity(data),
    };
  }

  static Map<String, double> _extractTutorMetrics(Map<String, dynamic> data) {
    return {
      'earningsGrowth': _calculateEarningsGrowth(data),
      'studentRetention': _calculateStudentRetention(data),
      'performanceScore': _calculatePerformanceScore(data),
    };
  }

  static List<String> _generateStudentStats(Map<String, dynamic> data) {
    return [
      '${data['completedBookings'] ?? 0} sessions completed',
      '${data['totalHoursLearned'] ?? 0} hours learned',
      '${data['totalTutorsWorkedWith'] ?? 0} tutors worked with',
    ];
  }

  static List<String> _generateTutorStats(Map<String, dynamic> data) {
    return [
      '\$${(data['totalEarnings'] ?? 0.0).toStringAsFixed(2)} earned',
      '${data['totalStudentsWorkedWith'] ?? 0} students taught',
      '${(data['averageRating'] ?? 0.0).toStringAsFixed(1)}/5.0 rating',
    ];
  }

  static double _calculateStudentCompletionRate(Map<String, dynamic> data) {
    final completed = (data['completedBookings'] ?? 0).toDouble();
    final total = (data['totalBookings'] ?? 1).toDouble();
    return total > 0 ? (completed / total) * 100 : 0.0;
  }

  static double _calculateLearningVelocity(Map<String, dynamic> data) {
    final hours = (data['totalHoursLearned'] ?? 0).toDouble();
    final sessions = (data['completedBookings'] ?? 1).toDouble();
    return sessions > 0 ? hours / sessions : 0.0;
  }

  static double _calculateEarningsGrowth(Map<String, dynamic> data) {
    final thisMonth = (data['thisMonthEarnings'] ?? 0.0).toDouble();
    final lastMonth = (data['lastMonthEarnings'] ?? 0.0).toDouble();
    return lastMonth > 0 ? ((thisMonth - lastMonth) / lastMonth) * 100 : 0.0;
  }

  static double _calculateStudentRetention(Map<String, dynamic> data) {
    final active = (data['activeStudents'] ?? 0).toDouble();
    final total = (data['totalStudentsWorkedWith'] ?? 1).toDouble();
    return total > 0 ? (active / total) * 100 : 0.0;
  }

  static double _calculatePerformanceScore(Map<String, dynamic> data) {
    final rating = (data['averageRating'] ?? 0.0).toDouble();
    final completion = (data['completionRate'] ?? 0.0).toDouble();
    final response = (data['responseRate'] ?? 0.0).toDouble();

    return (rating * 0.4 + completion * 0.3 + response * 0.3).clamp(0.0, 5.0);
  }
}
