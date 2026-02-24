import '../../../../core/utils/either.dart';
import '../../../../core/utils/unit.dart';

import '../entities/notification_entity.dart';
import '../failures/notification_failures.dart';

/// Repository interface for notification domain operations
///
/// This interface defines all data operations needed for notification management
/// following the Repository pattern. The interface belongs to the domain layer
/// and implementations are provided by the data layer.
abstract class NotificationRepository {
  // Core CRUD Operations

  /// Create a new notification
  Future<Either<NotificationFailure, NotificationEntity>> createNotification(
    NotificationEntity notification,
  );

  /// Update an existing notification
  Future<Either<NotificationFailure, Unit>> updateNotification(
    NotificationEntity notification,
  );

  /// Delete a notification by ID
  Future<Either<NotificationFailure, Unit>> deleteNotification(
    String notificationId,
    String userId, // For ownership validation
  );

  /// Get a specific notification by ID
  Future<Either<NotificationFailure, NotificationEntity>> getNotification(
    String notificationId,
    String userId, // For ownership validation
  );

  // Query Operations

  /// Get notifications for a specific recipient with pagination
  Future<Either<NotificationFailure, List<NotificationEntity>>>
  getNotifications(
    String recipientId, {
    int page = 1,
    int limit = 20,
    bool? readStatus, // null = all, true = read only, false = unread only
    List<String>? types, // Filter by notification types
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Get count of unread notifications for a recipient
  Future<Either<NotificationFailure, int>> getUnreadCount(String recipientId);

  /// Get recent notifications for a recipient (last 24 hours)
  Future<Either<NotificationFailure, List<NotificationEntity>>>
  getRecentNotifications(String recipientId, {int limit = 10});

  /// Search notifications for a recipient
  Future<Either<NotificationFailure, List<NotificationEntity>>>
  searchNotifications(
    String recipientId,
    String query, {
    int page = 1,
    int limit = 20,
  });

  // Bulk Operations

  /// Mark a specific notification as read
  Future<Either<NotificationFailure, Unit>> markAsRead(
    String notificationId,
    String userId, // For ownership validation
  );

  /// Mark all notifications as read for a recipient
  Future<Either<NotificationFailure, Unit>> markAllAsRead(String recipientId);

  /// Mark multiple notifications as read
  Future<Either<NotificationFailure, Unit>> markMultipleAsRead(
    List<String> notificationIds,
    String userId, // For ownership validation
  );

  /// Delete multiple notifications
  Future<Either<NotificationFailure, Unit>> deleteMultiple(
    List<String> notificationIds,
    String userId, // For ownership validation
  );

  /// Delete all read notifications for a recipient
  Future<Either<NotificationFailure, Unit>> deleteAllRead(String recipientId);

  /// Delete old notifications (older than specified days)
  Future<Either<NotificationFailure, int>> deleteOldNotifications(
    String recipientId,
    int daysOld,
  );

  // Statistics and Analytics

  /// Get notification statistics for a recipient
  Future<Either<NotificationFailure, NotificationStats>> getNotificationStats(
    String recipientId,
  );

  /// Get notification counts by type for a recipient
  Future<Either<NotificationFailure, Map<String, int>>>
  getNotificationCountsByType(String recipientId);

  // Real-time Operations

  /// Subscribe to real-time notification updates for a user
  Stream<Either<NotificationFailure, NotificationEntity>>
  subscribeToNotifications(String userId);

  /// Check if real-time connection is active
  Future<bool> isConnected(String userId);

  /// Reconnect to real-time service
  Future<Either<NotificationFailure, Unit>> reconnect(String userId);
}

/// Statistics data class for notification analytics
class NotificationStats {
  final int totalNotifications;
  final int unreadNotifications;
  final int readNotifications;
  final int notificationsToday;
  final int notificationsThisWeek;
  final int notificationsThisMonth;
  final Map<String, int> typeDistribution;
  final DateTime? lastNotificationDate;
  final double averageNotificationsPerDay;

  const NotificationStats({
    required this.totalNotifications,
    required this.unreadNotifications,
    required this.readNotifications,
    required this.notificationsToday,
    required this.notificationsThisWeek,
    required this.notificationsThisMonth,
    required this.typeDistribution,
    this.lastNotificationDate,
    required this.averageNotificationsPerDay,
  });

  @override
  String toString() {
    return 'NotificationStats('
        'total: $totalNotifications, '
        'unread: $unreadNotifications, '
        'today: $notificationsToday)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationStats &&
        other.totalNotifications == totalNotifications &&
        other.unreadNotifications == unreadNotifications &&
        other.readNotifications == readNotifications &&
        other.notificationsToday == notificationsToday &&
        other.notificationsThisWeek == notificationsThisWeek &&
        other.notificationsThisMonth == notificationsThisMonth &&
        _mapEquals(other.typeDistribution, typeDistribution) &&
        other.lastNotificationDate == lastNotificationDate &&
        other.averageNotificationsPerDay == averageNotificationsPerDay;
  }

  @override
  int get hashCode {
    return totalNotifications.hashCode ^
        unreadNotifications.hashCode ^
        readNotifications.hashCode ^
        notificationsToday.hashCode ^
        notificationsThisWeek.hashCode ^
        notificationsThisMonth.hashCode ^
        typeDistribution.hashCode ^
        lastNotificationDate.hashCode ^
        averageNotificationsPerDay.hashCode;
  }

  bool _mapEquals(Map<String, int> map1, Map<String, int> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }
}
