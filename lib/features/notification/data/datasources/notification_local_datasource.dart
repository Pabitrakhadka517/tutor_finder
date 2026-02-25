import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/exceptions/cache_exception.dart';
import '../dtos/notification_dto.dart';

abstract class NotificationLocalDataSource {
  // Notification Caching
  Future<void> cacheNotification(NotificationDto notificationDto);
  Future<void> cacheNotifications(
    List<NotificationDto> notifications,
    String cacheKey,
  );
  Future<NotificationDto?> getCachedNotification(String id);
  Future<List<NotificationDto>?> getCachedNotifications(String cacheKey);
  Future<void> removeCachedNotification(String id);
  Future<void> updateCachedNotificationReadStatus(String id, bool readStatus);

  // Unread Count Caching
  Future<void> cacheUnreadCount(String userId, int count);
  Future<int?> getCachedUnreadCount(String userId);
  Future<void> removeCachedUnreadCount(String userId);

  // Cache Management
  Future<void> clearAllCache();
  Future<void> clearUserCache(String userId);
  Future<bool> isCacheExpired(String cacheKey);
  Future<void> setCacheTimestamp(String cacheKey);
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final SharedPreferences _sharedPreferences;

  static const String _notificationCachePrefix = 'notification_cache_';
  static const String _notificationsCachePrefix = 'notifications_cache_';
  static const String _unreadCountCachePrefix = 'unread_count_cache_';
  static const String _statsCachePrefix = 'notification_stats_cache_';
  static const String _timestampSuffix = '_timestamp';

  // Cache duration in milliseconds (15 minutes for notifications, 5 minutes for counts)
  static const int _notificationCacheDuration = 15 * 60 * 1000;
  static const int _countCacheDuration = 5 * 60 * 1000;

  NotificationLocalDataSourceImpl(this._sharedPreferences);

  @override
  Future<void> cacheNotification(NotificationDto notificationDto) async {
    try {
      final cacheKey = '$_notificationCachePrefix${notificationDto.id}';
      final json = jsonEncode(notificationDto.toJson());
      await _sharedPreferences.setString(cacheKey, json);
      await setCacheTimestamp(cacheKey);
    } catch (e) {
      throw CacheException('Failed to cache notification: $e');
    }
  }

  @override
  Future<void> cacheNotifications(
    List<NotificationDto> notifications,
    String cacheKey,
  ) async {
    try {
      final fullCacheKey = '$_notificationsCachePrefix$cacheKey';
      final json = jsonEncode(notifications.map((n) => n.toJson()).toList());
      await _sharedPreferences.setString(fullCacheKey, json);
      await setCacheTimestamp(fullCacheKey);
    } catch (e) {
      throw CacheException('Failed to cache notifications: $e');
    }
  }

  @override
  Future<NotificationDto?> getCachedNotification(String id) async {
    try {
      final cacheKey = '$_notificationCachePrefix$id';

      if (await _isCacheExpired(cacheKey, _notificationCacheDuration)) {
        await removeCachedNotification(id);
        return null;
      }

      final json = _sharedPreferences.getString(cacheKey);
      if (json == null) return null;

      final Map<String, dynamic> map = jsonDecode(json);
      return NotificationDto.fromJson(map);
    } catch (e) {
      throw CacheException('Failed to get cached notification: $e');
    }
  }

  @override
  Future<List<NotificationDto>?> getCachedNotifications(String cacheKey) async {
    try {
      final fullCacheKey = '$_notificationsCachePrefix$cacheKey';

      if (await _isCacheExpired(fullCacheKey, _notificationCacheDuration)) {
        await _sharedPreferences.remove(fullCacheKey);
        await _sharedPreferences.remove('$fullCacheKey$_timestampSuffix');
        return null;
      }

      final json = _sharedPreferences.getString(fullCacheKey);
      if (json == null) return null;

      final List<dynamic> list = jsonDecode(json);
      return list.map((item) => NotificationDto.fromJson(item)).toList();
    } catch (e) {
      throw CacheException('Failed to get cached notifications: $e');
    }
  }

  @override
  Future<void> removeCachedNotification(String id) async {
    try {
      final cacheKey = '$_notificationCachePrefix$id';
      await _sharedPreferences.remove(cacheKey);
      await _sharedPreferences.remove('$cacheKey$_timestampSuffix');
    } catch (e) {
      throw CacheException('Failed to remove cached notification: $e');
    }
  }

  @override
  Future<void> updateCachedNotificationReadStatus(
    String id,
    bool readStatus,
  ) async {
    try {
      final cachedNotification = await getCachedNotification(id);
      if (cachedNotification != null) {
        final updatedNotification = cachedNotification.copyWith(
          read: readStatus,
          updatedAt: DateTime.now(),
        );
        await cacheNotification(updatedNotification);
      }
    } catch (e) {
      // Don't throw exception for cache update failures
      print('Warning: Failed to update cached notification read status: $e');
    }
  }

  @override
  Future<void> cacheUnreadCount(String userId, int count) async {
    try {
      final cacheKey = '$_unreadCountCachePrefix$userId';
      await _sharedPreferences.setInt(cacheKey, count);
      await setCacheTimestamp(cacheKey);
    } catch (e) {
      throw CacheException('Failed to cache unread count: $e');
    }
  }

  @override
  Future<int?> getCachedUnreadCount(String userId) async {
    try {
      final cacheKey = '$_unreadCountCachePrefix$userId';

      if (await _isCacheExpired(cacheKey, _countCacheDuration)) {
        await removeCachedUnreadCount(userId);
        return null;
      }

      return _sharedPreferences.getInt(cacheKey);
    } catch (e) {
      throw CacheException('Failed to get cached unread count: $e');
    }
  }

  @override
  Future<void> removeCachedUnreadCount(String userId) async {
    try {
      final cacheKey = '$_unreadCountCachePrefix$userId';
      await _sharedPreferences.remove(cacheKey);
      await _sharedPreferences.remove('$cacheKey$_timestampSuffix');
    } catch (e) {
      throw CacheException('Failed to remove cached unread count: $e');
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      final keys = _sharedPreferences.getKeys();
      final notificationKeys = keys.where(
        (key) =>
            key.startsWith(_notificationCachePrefix) ||
            key.startsWith(_notificationsCachePrefix) ||
            key.startsWith(_unreadCountCachePrefix) ||
            key.startsWith(_statsCachePrefix),
      );

      for (final key in notificationKeys) {
        await _sharedPreferences.remove(key);
      }
    } catch (e) {
      throw CacheException('Failed to clear all notification cache: $e');
    }
  }

  @override
  Future<void> clearUserCache(String userId) async {
    try {
      final keys = _sharedPreferences.getKeys();
      final userKeys = keys.where((key) => key.contains(userId));

      for (final key in userKeys) {
        if (key.startsWith(_notificationCachePrefix) ||
            key.startsWith(_notificationsCachePrefix) ||
            key.startsWith(_unreadCountCachePrefix) ||
            key.startsWith(_statsCachePrefix)) {
          await _sharedPreferences.remove(key);
        }
      }
    } catch (e) {
      throw CacheException('Failed to clear user notification cache: $e');
    }
  }

  @override
  Future<bool> isCacheExpired(String cacheKey) async {
    return _isCacheExpired(cacheKey, _notificationCacheDuration);
  }

  Future<bool> _isCacheExpired(String cacheKey, int duration) async {
    try {
      final timestampKey = '$cacheKey$_timestampSuffix';
      final timestamp = _sharedPreferences.getInt(timestampKey);

      if (timestamp == null) return true;

      final now = DateTime.now().millisecondsSinceEpoch;
      return (now - timestamp) > duration;
    } catch (e) {
      // If there's an error checking the timestamp, consider it expired
      return true;
    }
  }

  @override
  Future<void> setCacheTimestamp(String cacheKey) async {
    try {
      final timestampKey = '$cacheKey$_timestampSuffix';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await _sharedPreferences.setInt(timestampKey, timestamp);
    } catch (e) {
      throw CacheException('Failed to set cache timestamp: $e');
    }
  }
}
