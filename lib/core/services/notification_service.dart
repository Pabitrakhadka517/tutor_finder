/// Core notification service interface.
/// Implement with flutter_local_notifications or firebase_messaging as needed.
abstract class NotificationService {
  Future<void> initialize();

  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  });

  /// Send a notification to a specific user
  Future<void> sendNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });

  /// Send a push notification to a specific user
  Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });

  /// Send a real-time notification via WebSocket
  Future<void> sendRealTimeNotification(dynamic notification);

  Future<void> cancelNotification(String id);
  Future<void> cancelAllNotifications();
}
