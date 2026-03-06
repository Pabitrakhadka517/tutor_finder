import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/notification_repository.dart';
import '../../domain/value_objects/notification_type.dart';
import '../state/notification_state.dart';

/// StateNotifier managing the notification list state.
///
/// Handles:
/// - Fetching notifications from REST API
/// - Marking as read / deleting
/// - Receiving real-time notifications via WebSocket
class NotificationNotifier extends StateNotifier<NotificationListState> {
  final NotificationRepository _repository;
  String? _currentUserId;
  StreamSubscription<NotificationEntity>? _realtimeSub;

  NotificationNotifier(this._repository) : super(const NotificationListState());

  /// Set the current user and connect WebSocket for real-time updates.
  ///
  /// Note: The dashboard pages also connect via the shared SocketService
  /// and route 'new_notification' events here via [addIncomingNotification].
  /// The repository WebSocket is a supplementary connection for cases where
  /// the notification page is opened outside the dashboard context.
  void setCurrentUser(String userId) {
    if (_currentUserId == userId) return;
    _currentUserId = userId;

    // Subscribe to repository's real-time stream (from WebSocket datasource)
    _realtimeSub?.cancel();
    _realtimeSub = _repository.realtimeNotifications.listen(
      _onRealtimeNotification,
    );

    // Attempt WebSocket connection (fire-and-forget, non-blocking).
    // This is supplementary - the dashboard SocketService is the primary path.
    _repository.connectWebSocket(userId);
  }

  /// Fetch notifications from the backend REST API.
  Future<void> fetchNotifications() async {
    if (_currentUserId == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please log in to view notifications',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getNotifications();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.toString(),
      ),
      (notifications) {
        final unread = notifications.where((n) => !n.read).length;
        state = state.copyWith(
          isLoading: false,
          notifications: notifications,
          unreadCount: unread,
        );
      },
    );
  }

  /// Fetch only the unread count (lightweight).
  /// Does not require setCurrentUser - uses JWT auth from ApiClient.
  Future<void> fetchUnreadCount() async {
    final result = await _repository.getUnreadCount();
    result.fold((_) {}, (count) => state = state.copyWith(unreadCount: count));
  }

  /// Mark a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    final result = await _repository.markAsRead(notificationId);

    result.fold((_) {}, (_) {
      final updated = state.notifications.map((n) {
        if (n.id == notificationId) return n.copyWith(read: true);
        return n;
      }).toList();

      state = state.copyWith(
        notifications: updated,
        unreadCount: (state.unreadCount - 1).clamp(0, 999),
      );
    });
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead() async {
    final result = await _repository.markAllAsRead();

    result.fold((_) {}, (_) {
      final updated = state.notifications
          .map((n) => n.copyWith(read: true))
          .toList();
      state = state.copyWith(notifications: updated, unreadCount: 0);
    });
  }

  /// Delete a notification.
  Future<void> deleteNotification(String notificationId) async {
    final result = await _repository.deleteNotification(notificationId);

    result.fold((_) {}, (_) {
      final deleted = state.notifications.firstWhere(
        (n) => n.id == notificationId,
        orElse: () => state.notifications.first,
      );
      final wasUnread = !deleted.read;

      final updated = state.notifications
          .where((n) => n.id != notificationId)
          .toList();
      state = state.copyWith(
        notifications: updated,
        unreadCount: wasUnread
            ? (state.unreadCount - 1).clamp(0, 999)
            : state.unreadCount,
      );
    });
  }

  /// Handle a real-time notification from WebSocket.
  void _onRealtimeNotification(NotificationEntity notification) {
    // Avoid duplicates
    final exists = state.notifications.any((n) => n.id == notification.id);
    if (exists) return;

    state = state.copyWith(
      notifications: [notification, ...state.notifications],
      unreadCount: state.unreadCount + 1,
    );
  }

  /// Handle incoming notification from raw JSON (for external callers).
  /// Only adds the notification if it belongs to the current user.
  void addIncomingNotification(Map<String, dynamic> json) {
    try {
      // Extract recipient ID from the notification
      final recipientId = json['recipient']?.toString() ?? '';

      // CRITICAL: Only process notifications intended for the current user
      if (_currentUserId == null || recipientId.isEmpty) {
        // Cannot verify ownership - skip this notification
        return;
      }

      if (recipientId != _currentUserId) {
        // Notification is not for this user - ignore it
        return;
      }

      final now = DateTime.now();
      NotificationType notifType;
      try {
        notifType = NotificationType.fromString(
          (json['type']?.toString() ?? '').toUpperCase(),
        );
      } catch (_) {
        notifType = NotificationType.systemAlert;
      }

      final notification = NotificationEntity.fromRepository(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        recipientId: recipientId,
        type: notifType,
        title: json['message']?.toString() ?? 'Notification',
        message: json['message']?.toString(),
        payload: json['data'] is Map
            ? Map<String, dynamic>.from(json['data'] as Map)
            : null,
        read: false,
        createdAt:
            DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? now,
        updatedAt: now,
      );

      _onRealtimeNotification(notification);
    } catch (e) {
      // Silently ignore parse errors for socket data
    }
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    _repository.disconnectWebSocket();
    super.dispose();
  }
}
