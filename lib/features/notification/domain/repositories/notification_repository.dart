import '../../../../core/utils/either.dart';
import '../../../../core/utils/unit.dart';
import '../entities/notification_entity.dart';
import '../failures/notification_failures.dart';

/// Domain repository interface for notifications.
///
/// Maps to the 5 actual backend endpoints plus WebSocket real-time support.
/// All operations use JWT authentication - the backend extracts the
/// userId from the token automatically.
abstract class NotificationRepository {
  /// Fetch paginated notifications for the authenticated user.
  Future<Either<NotificationFailure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 20,
  });

  /// Get the count of unread notifications.
  Future<Either<NotificationFailure, int>> getUnreadCount();

  /// Mark a single notification as read.
  Future<Either<NotificationFailure, Unit>> markAsRead(String notificationId);

  /// Mark all notifications as read.
  Future<Either<NotificationFailure, Unit>> markAllAsRead();

  /// Delete a notification.
  Future<Either<NotificationFailure, Unit>> deleteNotification(
    String notificationId,
  );

  /// Subscribe to real-time notification updates via WebSocket.
  Stream<NotificationEntity> get realtimeNotifications;

  /// Connect the WebSocket for the given user.
  Future<void> connectWebSocket(String userId);

  /// Disconnect the WebSocket.
  Future<void> disconnectWebSocket();
}
