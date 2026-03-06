class WebSocketEvents {
  // Incoming Events (from server to client)
  static const String newNotification = 'new_notification';
  static const String notificationRead = 'notification_read';
  static const String notificationDeleted = 'notification_deleted';
  static const String notificationUpdated = 'notification_updated';
  static const String notificationCountUpdated = 'notification_count_updated';

  // Outgoing Events (from client to server)
  static const String subscribeNotifications = 'subscribe_notifications';
  static const String unsubscribeNotifications = 'unsubscribe_notifications';
  static const String markAllNotificationsRead = 'mark_all_notifications_read';

  // Connection Events
  static const String connect = 'connect';
  static const String disconnect = 'disconnect';
  static const String reconnect = 'reconnect';
  static const String error = 'error';

  // Room Events
  static const String joinRoom = 'join_room';
  static const String leaveRoom = 'leave_room';

  // Authentication Events
  static const String authenticate = 'authenticate';
  static const String authenticationFailed = 'authentication_failed';
  static const String authenticationSuccess = 'authentication_success';
}
