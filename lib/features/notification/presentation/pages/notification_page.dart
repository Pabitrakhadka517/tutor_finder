import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/notification_providers.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = ref.read(authNotifierProvider).user?.id;
      final notifier = ref.read(notificationNotifierProvider.notifier);
      if (userId != null) {
        notifier.setCurrentUser(userId);
      }
      notifier.fetchNotifications();
    });
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'BOOKING_CREATED':
        return Icons.calendar_today;
      case 'BOOKING_UPDATED':
        return Icons.update;
      case 'PAYMENT_SUCCESS':
        return Icons.payment;
      case 'NEW_REVIEW':
        return Icons.star;
      case 'ADMIN_MESSAGE':
        return Icons.admin_panel_settings;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'BOOKING_CREATED':
        return Colors.blue;
      case 'BOOKING_UPDATED':
        return Colors.orange;
      case 'PAYMENT_SUCCESS':
        return Colors.green;
      case 'NEW_REVIEW':
        return Colors.amber;
      case 'ADMIN_MESSAGE':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (state.notifications.any((n) => !n.read))
            TextButton(
              onPressed: () => ref
                  .read(notificationNotifierProvider.notifier)
                  .markAllAsRead(),
              child: const Text(
                'Read All',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(child: Text(state.errorMessage!))
          : state.notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(notificationNotifierProvider.notifier)
                  .fetchNotifications(),
              child: ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return Dismissible(
                    key: Key(notification.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      ref
                          .read(notificationNotifierProvider.notifier)
                          .deleteNotification(notification.id);
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _colorForType(
                          notification.type.value,
                        ).withOpacity(0.1),
                        child: Icon(
                          _iconForType(notification.type.value),
                          color: _colorForType(notification.type.value),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        notification.message ?? notification.title,
                        style: TextStyle(
                          fontWeight: notification.read
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            _formatTime(notification.createdAt),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: !notification.read
                          ? Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                      onTap: () {
                        if (!notification.read) {
                          ref
                              .read(notificationNotifierProvider.notifier)
                              .markAsRead(notification.id);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dateTime);
  }
}
