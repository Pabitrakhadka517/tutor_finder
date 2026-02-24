import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dashboard_dto.dart';
import '../models/dashboard_cache_dto.dart';
import '../../domain/value_objects/user_role.dart';

/// Local data source interface for dashboard caching
abstract class IDashboardLocalDataSource {
  /// Cache student dashboard data
  Future<void> cacheStudentDashboard(
    String studentId,
    StudentDashboardDto dashboard,
  );

  /// Get cached student dashboard data
  Future<StudentDashboardDto?> getCachedStudentDashboard(String studentId);

  /// Cache tutor dashboard data
  Future<void> cacheTutorDashboard(String tutorId, TutorDashboardDto dashboard);

  /// Get cached tutor dashboard data
  Future<TutorDashboardDto?> getCachedTutorDashboard(String tutorId);

  /// Cache dashboard summary
  Future<void> cacheDashboardSummary(
    String userId,
    String role,
    DashboardSummaryDto summary,
  );

  /// Get cached dashboard summary
  Future<DashboardSummaryDto?> getCachedDashboardSummary(
    String userId,
    String role,
  );

  /// Cache dashboard trends data
  Future<void> cacheDashboardTrends(
    String userId,
    String role,
    Map<String, List<dynamic>> trends,
  );

  /// Get cached dashboard trends
  Future<Map<String, List<dynamic>>?> getCachedDashboardTrends(
    String userId,
    String role,
  );

  /// Get cache status for a user
  Future<DashboardCacheDto?> getCacheStatus(String userId, String role);

  /// Clear specific user's cache
  Future<void> clearUserCache(String userId, String role);

  /// Clear all dashboard cache
  Future<void> clearAllCache();

  /// Get cache statistics
  Future<CacheStatisticsDto> getCacheStatistics();

  /// Check if cache is valid for user
  Future<bool> isCacheValid(String userId, String role);
}

/// Implementation of local data source using SharedPreferences
@Injectable(as: IDashboardLocalDataSource)
class DashboardLocalDataSource implements IDashboardLocalDataSource {
  final SharedPreferences _prefs;

  // Cache key prefixes
  static const String _studentDashboardPrefix = 'dashboard_student_';
  static const String _tutorDashboardPrefix = 'dashboard_tutor_';
  static const String _summaryPrefix = 'summary_';
  static const String _trendsPrefix = 'trends_';
  static const String _cacheStatusPrefix = 'cache_status_';
  static const String _cacheStatsKey = 'cache_statistics';

  const DashboardLocalDataSource(this._prefs);

  @override
  Future<void> cacheStudentDashboard(
    String studentId,
    StudentDashboardDto dashboard,
  ) async {
    try {
      final cacheKey = '$_studentDashboardPrefix$studentId';
      final jsonString = json.encode(dashboard.toJson());

      await _prefs.setString(cacheKey, jsonString);

      // Update cache status
      await _updateCacheStatus(studentId, 'student', dashboard.toJson());

      // Update cache statistics
      await _updateCacheStatistics();
    } catch (e) {
      throw DashboardLocalDataSourceException(
        'Failed to cache student dashboard: ${e.toString()}',
      );
    }
  }

  @override
  Future<StudentDashboardDto?> getCachedStudentDashboard(
    String studentId,
  ) async {
    try {
      final cacheKey = '$_studentDashboardPrefix$studentId';
      final jsonString = _prefs.getString(cacheKey);

      if (jsonString == null) return null;

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return StudentDashboardDto.fromJson(jsonMap);
    } catch (e) {
      // If there's an error reading cache, remove corrupted data
      await _removeCacheEntry('$_studentDashboardPrefix$studentId');
      return null;
    }
  }

  @override
  Future<void> cacheTutorDashboard(
    String tutorId,
    TutorDashboardDto dashboard,
  ) async {
    try {
      final cacheKey = '$_tutorDashboardPrefix$tutorId';
      final jsonString = json.encode(dashboard.toJson());

      await _prefs.setString(cacheKey, jsonString);

      // Update cache status
      await _updateCacheStatus(tutorId, 'tutor', dashboard.toJson());

      // Update cache statistics
      await _updateCacheStatistics();
    } catch (e) {
      throw DashboardLocalDataSourceException(
        'Failed to cache tutor dashboard: ${e.toString()}',
      );
    }
  }

  @override
  Future<TutorDashboardDto?> getCachedTutorDashboard(String tutorId) async {
    try {
      final cacheKey = '$_tutorDashboardPrefix$tutorId';
      final jsonString = _prefs.getString(cacheKey);

      if (jsonString == null) return null;

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return TutorDashboardDto.fromJson(jsonMap);
    } catch (e) {
      // If there's an error reading cache, remove corrupted data
      await _removeCacheEntry('$_tutorDashboardPrefix$tutorId');
      return null;
    }
  }

  @override
  Future<void> cacheDashboardSummary(
    String userId,
    String role,
    DashboardSummaryDto summary,
  ) async {
    try {
      final cacheKey = '$_summaryPrefix${role}_$userId';
      final jsonString = json.encode(summary.toJson());

      await _prefs.setString(cacheKey, jsonString);
    } catch (e) {
      throw DashboardLocalDataSourceException(
        'Failed to cache dashboard summary: ${e.toString()}',
      );
    }
  }

  @override
  Future<DashboardSummaryDto?> getCachedDashboardSummary(
    String userId,
    String role,
  ) async {
    try {
      final cacheKey = '$_summaryPrefix${role}_$userId';
      final jsonString = _prefs.getString(cacheKey);

      if (jsonString == null) return null;

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return DashboardSummaryDto.fromJson(jsonMap);
    } catch (e) {
      // If there's an error reading cache, remove corrupted data
      await _removeCacheEntry('$_summaryPrefix${role}_$userId');
      return null;
    }
  }

  @override
  Future<void> cacheDashboardTrends(
    String userId,
    String role,
    Map<String, List<dynamic>> trends,
  ) async {
    try {
      final cacheKey = '$_trendsPrefix${role}_$userId';
      final jsonString = json.encode(trends);

      await _prefs.setString(cacheKey, jsonString);
    } catch (e) {
      throw DashboardLocalDataSourceException(
        'Failed to cache dashboard trends: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, List<dynamic>>?> getCachedDashboardTrends(
    String userId,
    String role,
  ) async {
    try {
      final cacheKey = '$_trendsPrefix${role}_$userId';
      final jsonString = _prefs.getString(cacheKey);

      if (jsonString == null) return null;

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

      // Convert to proper Map<String, List<dynamic>> structure
      final trends = <String, List<dynamic>>{};
      jsonMap.forEach((key, value) {
        if (value is List) {
          trends[key] = value;
        }
      });

      return trends;
    } catch (e) {
      // If there's an error reading cache, remove corrupted data
      await _removeCacheEntry('$_trendsPrefix${role}_$userId');
      return null;
    }
  }

  @override
  Future<DashboardCacheDto?> getCacheStatus(String userId, String role) async {
    try {
      final cacheKey = '$_cacheStatusPrefix${role}_$userId';
      final jsonString = _prefs.getString(cacheKey);

      if (jsonString == null) return null;

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return DashboardCacheDto.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearUserCache(String userId, String role) async {
    try {
      final keysToRemove = <String>[];

      // Collect all keys related to this user
      final allKeys = _prefs.getKeys();

      for (final key in allKeys) {
        if (key.contains('${role}_$userId') ||
            key.contains('${userId}_') ||
            (key.startsWith(_studentDashboardPrefix) && key.endsWith(userId)) ||
            (key.startsWith(_tutorDashboardPrefix) && key.endsWith(userId))) {
          keysToRemove.add(key);
        }
      }

      // Remove all identified keys
      for (final key in keysToRemove) {
        await _prefs.remove(key);
      }

      // Update cache statistics
      await _updateCacheStatistics();
    } catch (e) {
      throw DashboardLocalDataSourceException(
        'Failed to clear user cache: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      final allKeys = _prefs.getKeys().toList();
      final dashboardKeys = allKeys
          .where(
            (key) =>
                key.startsWith(_studentDashboardPrefix) ||
                key.startsWith(_tutorDashboardPrefix) ||
                key.startsWith(_summaryPrefix) ||
                key.startsWith(_trendsPrefix) ||
                key.startsWith(_cacheStatusPrefix) ||
                key == _cacheStatsKey,
          )
          .toList();

      for (final key in dashboardKeys) {
        await _prefs.remove(key);
      }
    } catch (e) {
      throw DashboardLocalDataSourceException(
        'Failed to clear all cache: ${e.toString()}',
      );
    }
  }

  @override
  Future<CacheStatisticsDto> getCacheStatistics() async {
    try {
      final jsonString = _prefs.getString(_cacheStatsKey);

      if (jsonString != null) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return CacheStatisticsDto.fromJson(jsonMap);
      }

      // Generate fresh statistics if not cached
      return await _generateCacheStatistics();
    } catch (e) {
      // If there's an error, generate fresh statistics
      return await _generateCacheStatistics();
    }
  }

  @override
  Future<bool> isCacheValid(String userId, String role) async {
    try {
      final cacheStatus = await getCacheStatus(userId, role);

      if (cacheStatus == null) return false;

      return cacheStatus.isValid && !cacheStatus.isExpired;
    } catch (e) {
      return false;
    }
  }

  // Private helper methods

  Future<void> _updateCacheStatus(
    String userId,
    String role,
    Map<String, dynamic> data,
  ) async {
    try {
      final cacheDto = DashboardCacheDto.create(
        userId: userId,
        role: role == 'student' ? UserRole.student : UserRole.tutor,
        data: data,
      );

      final cacheKey = '$_cacheStatusPrefix${role}_$userId';
      final jsonString = json.encode(cacheDto.toJson());

      await _prefs.setString(cacheKey, jsonString);
    } catch (e) {
      // Non-critical operation, log error but don't throw
      print('Failed to update cache status: $e');
    }
  }

  Future<void> _updateCacheStatistics() async {
    try {
      final statistics = await _generateCacheStatistics();
      final jsonString = json.encode(statistics.toJson());

      await _prefs.setString(_cacheStatsKey, jsonString);
    } catch (e) {
      // Non-critical operation, log error but don't throw
      print('Failed to update cache statistics: $e');
    }
  }

  Future<CacheStatisticsDto> _generateCacheStatistics() async {
    final allKeys = _prefs.getKeys();

    int studentEntries = 0;
    int tutorEntries = 0;
    int validEntries = 0;
    int expiredEntries = 0;
    int invalidEntries = 0;
    double totalAgeMinutes = 0.0;
    int entriesWithAge = 0;

    for (final key in allKeys) {
      if (key.startsWith(_cacheStatusPrefix)) {
        try {
          final jsonString = _prefs.getString(key);
          if (jsonString != null) {
            final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
            final cacheDto = DashboardCacheDto.fromJson(jsonMap);

            if (cacheDto.role == 'student') studentEntries++;
            if (cacheDto.role == 'tutor') tutorEntries++;

            if (cacheDto.isValid && !cacheDto.isExpired) {
              validEntries++;
            } else if (cacheDto.isExpired) {
              expiredEntries++;
            } else {
              invalidEntries++;
            }

            totalAgeMinutes += cacheDto.ageInMinutes;
            entriesWithAge++;
          }
        } catch (e) {
          invalidEntries++;
        }
      }
    }

    final totalEntries = studentEntries + tutorEntries;
    final averageAge = entriesWithAge > 0
        ? totalAgeMinutes / entriesWithAge
        : 0.0;

    return CacheStatisticsDto(
      totalCacheEntries: totalEntries,
      validEntries: validEntries,
      expiredEntries: expiredEntries,
      invalidEntries: invalidEntries,
      entriesByRole: {'student': studentEntries, 'tutor': tutorEntries},
      averageAgeMinutes: averageAge,
      memoryUsage: {
        'totalKeys': allKeys.length,
        'dashboardKeys': totalEntries,
        'estimatedSizeKB': totalEntries * 2, // Rough estimate
      },
      generatedAt: DateTime.now(),
    );
  }

  Future<void> _removeCacheEntry(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      // Non-critical operation, log error but don't throw
      print('Failed to remove cache entry $key: $e');
    }
  }
}

/// Custom exception for local data source errors
class DashboardLocalDataSourceException implements Exception {
  final String message;

  const DashboardLocalDataSourceException(this.message);

  @override
  String toString() {
    return 'DashboardLocalDataSourceException: $message';
  }
}
