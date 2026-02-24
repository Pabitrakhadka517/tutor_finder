import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/notification_repository.dart';
import '../../domain/value_objects/notification_type.dart';
import '../state/notification_state.dart';

class NotificationNotifier extends StateNotifier<NotificationListState> {
  final NotificationRepository _repository;
  String? _currentUserId;

  NotificationNotifier(this._repository) : super(const NotificationListState());

  void setCurrentUser(String userId) {
    _currentUserId = userId;
  }

  Future<void> fetchNotifications() async {
    if (_currentUserId == null) return;
    state = state.copyWith(isLoading: true);
    final result = await _repository.getNotifications(_currentUserId!);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.toString(),
      ),
      (notifications) => state = state.copyWith(
        isLoading: false,
        notifications: notifications,
      ),
    );
  }

  Future<void> fetchUnreadCount() async {
    if (_currentUserId == null) return;
    final result = await _repository.getUnreadCount(_currentUserId!);
    result.fold((_) {}, (count) => state = state.copyWith(unreadCount: count));
  }

  Future<void> markAsRead(String notificationId) async {
    if (_currentUserId == null) return;
    final result = await _repository.markAsRead(
      notificationId,
      _currentUserId!,
    );
    result.fold((_) {}, (_) {
      final updated = state.notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(read: true);
        }
        return n;
      }).toList();
      state = state.copyWith(
        notifications: updated,
        unreadCount: (state.unreadCount - 1).clamp(0, 999),
      );
    });
  }

  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;
    final result = await _repository.markAllAsRead(_currentUserId!);
    result.fold((_) {}, (_) {
      final updated = state.notifications
          .map((n) => n.copyWith(read: true))
          .toList();
      state = state.copyWith(notifications: updated, unreadCount: 0);
    });
  }

  Future<void> deleteNotification(String notificationId) async {
    if (_currentUserId == null) return;
    final result = await _repository.deleteNotification(
      notificationId,
      _currentUserId!,
    );
    result.fold((_) {}, (_) {
      final updated = state.notifications
          .where((n) => n.id != notificationId)
          .toList();
      state = state.copyWith(notifications: updated);
    });
  }

  /// Handle incoming real-time notification from Socket.io
  void addIncomingNotification(Map<String, dynamic> json) {
    try {
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
        recipientId: json['recipient']?.toString() ?? '',
        type: notifType,
        title:
            json['title']?.toString() ??
            json['message']?.toString() ??
            'Notification',
        message: json['message']?.toString(),
        payload: json['data'] is Map
            ? Map<String, dynamic>.from(json['data'] as Map)
            : null,
        read: false,
        createdAt:
            DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? now,
        updatedAt: now,
      );

      state = state.copyWith(
        notifications: [notification, ...state.notifications],
        unreadCount: state.unreadCount + 1,
      );
    } catch (e) {
      // Silently ignore parse errors for socket data
    }
  }
}
