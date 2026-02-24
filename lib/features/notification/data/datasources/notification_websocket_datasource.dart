import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/network/websocket_events.dart';
import '../dtos/notification_dto.dart';

abstract class NotificationWebSocketDataSource {
  // Connection Management
  Future<void> connect(String userId);
  Future<void> disconnect();
  bool get isConnected;

  // Real-time Notification Streams
  Stream<NotificationDto> get notificationStream;
  Stream<String> get notificationReadStream;
  Stream<String> get notificationDeletedStream;
  Stream<int> get unreadCountStream;
  Stream<String> get connectionStatusStream;

  // Subscription Management
  Future<void> subscribeToNotifications(String userId);
  Future<void> unsubscribeFromNotifications();

  // Event Emission
  Future<void> emitMarkAsRead(String notificationId);
  Future<void> emitMarkAllAsRead();
  Future<void> emitDeleteNotification(String notificationId);
}

@LazySingleton(as: NotificationWebSocketDataSource)
class NotificationWebSocketDataSourceImpl
    implements NotificationWebSocketDataSource {
  io.Socket? _socket;
  String? _currentUserId;

  // For streaming events
  final StreamController<NotificationDto> _notificationController =
      StreamController<NotificationDto>.broadcast();
  final StreamController<String> _readController =
      StreamController<String>.broadcast();
  final StreamController<String> _deletedController =
      StreamController<String>.broadcast();
  final StreamController<int> _unreadCountController =
      StreamController<int>.broadcast();
  final StreamController<String> _connectionStatusController =
      StreamController<String>.broadcast();

  @override
  Stream<NotificationDto> get notificationStream =>
      _notificationController.stream;

  @override
  Stream<String> get notificationReadStream => _readController.stream;

  @override
  Stream<String> get notificationDeletedStream => _deletedController.stream;

  @override
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  @override
  Stream<String> get connectionStatusStream =>
      _connectionStatusController.stream;

  @override
  bool get isConnected => _socket?.connected ?? false;

  @override
  Future<void> connect(String userId) async {
    try {
      await disconnect(); // Ensure clean connection

      _currentUserId = userId;

      _socket = io.io(
        'ws://localhost:3000', // Replace with actual server URL
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableForceNew()
            .setQuery({'userId': userId})
            .build(),
      );

      // Set up event listeners
      _setupEventListeners();

      // Wait for connection
      final completer = Completer<void>();
      _socket!.onConnect((_) {
        _connectionStatusController.add('connected');
        completer.complete();
      });

      _socket!.onConnectError((data) {
        _connectionStatusController.add('error');
        if (!completer.isCompleted) {
          completer.completeError('Connection failed: $data');
        }
      });

      _socket!.connect();
      await completer.future;

      // Auto-subscribe to notifications
      await subscribeToNotifications(userId);
    } catch (e) {
      _connectionStatusController.add('error');
      throw Exception('Failed to connect to notification service: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      if (_socket?.connected == true) {
        await unsubscribeFromNotifications();
      }

      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      _currentUserId = null;

      _connectionStatusController.add('disconnected');
    } catch (e) {
      print('Warning: Error during WebSocket disconnect: $e');
    }
  }

  @override
  Future<void> subscribeToNotifications(String userId) async {
    if (!isConnected) {
      throw Exception('Not connected to notification service');
    }

    _socket!.emit(WebSocketEvents.subscribeNotifications, {'userId': userId});
  }

  @override
  Future<void> unsubscribeFromNotifications() async {
    if (!isConnected) return;

    _socket!.emit(WebSocketEvents.unsubscribeNotifications, {
      'userId': _currentUserId,
    });
  }

  @override
  Future<void> emitMarkAsRead(String notificationId) async {
    if (!isConnected) {
      throw Exception('Not connected to notification service');
    }

    _socket!.emit(WebSocketEvents.notificationRead, {
      'notificationId': notificationId,
      'userId': _currentUserId,
    });
  }

  @override
  Future<void> emitMarkAllAsRead() async {
    if (!isConnected) {
      throw Exception('Not connected to notification service');
    }

    _socket!.emit(WebSocketEvents.markAllNotificationsRead, {
      'userId': _currentUserId,
    });
  }

  @override
  Future<void> emitDeleteNotification(String notificationId) async {
    if (!isConnected) {
      throw Exception('Not connected to notification service');
    }

    _socket!.emit(WebSocketEvents.notificationDeleted, {
      'notificationId': notificationId,
      'userId': _currentUserId,
    });
  }

  void _setupEventListeners() {
    if (_socket == null) return;

    // New notification received
    _socket!.on(WebSocketEvents.newNotification, (data) {
      try {
        final notificationData = data as Map<String, dynamic>;
        final notification = NotificationDto.fromJson(notificationData);
        _notificationController.add(notification);
      } catch (e) {
        print('Error parsing new notification: $e');
      }
    });

    // Notification marked as read
    _socket!.on(WebSocketEvents.notificationRead, (data) {
      try {
        final notificationId = data['notificationId'] as String;
        _readController.add(notificationId);
      } catch (e) {
        print('Error parsing notification read event: $e');
      }
    });

    // Notification deleted
    _socket!.on(WebSocketEvents.notificationDeleted, (data) {
      try {
        final notificationId = data['notificationId'] as String;
        _deletedController.add(notificationId);
      } catch (e) {
        print('Error parsing notification deleted event: $e');
      }
    });

    // Unread count updated
    _socket!.on(WebSocketEvents.notificationCountUpdated, (data) {
      try {
        final count = data['count'] as int;
        _unreadCountController.add(count);
      } catch (e) {
        print('Error parsing unread count update: $e');
      }
    });

    // Connection status events
    _socket!.onDisconnect((_) {
      _connectionStatusController.add('disconnected');
    });

    _socket!.onReconnect((_) {
      _connectionStatusController.add('reconnected');
      // Re-subscribe after reconnection
      if (_currentUserId != null) {
        subscribeToNotifications(_currentUserId!);
      }
    });

    _socket!.onError((error) {
      _connectionStatusController.add('error');
      print('WebSocket error: $error');
    });
  }

  @override
  void dispose() {
    disconnect();
    _notificationController.close();
    _readController.close();
    _deletedController.close();
    _unreadCountController.close();
    _connectionStatusController.close();
  }
}
