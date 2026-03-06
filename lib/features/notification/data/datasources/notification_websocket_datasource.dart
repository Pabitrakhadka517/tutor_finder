import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/websocket_events.dart';
import '../dtos/notification_dto.dart';

/// WebSocket data source for real-time notification updates.
///
/// Connects to the backend Socket.IO server using JWT authentication
/// (same as the backend auth middleware). Listens for `new_notification`
/// events and exposes them as streams.
abstract class NotificationWebSocketDataSource {
  Future<void> connect(String userId);
  Future<void> disconnect();
  bool get isConnected;

  /// Stream of incoming real-time notifications
  Stream<NotificationDto> get notificationStream;

  /// Stream of notification IDs that were marked as read
  Stream<String> get notificationReadStream;

  /// Stream of notification IDs that were deleted
  Stream<String> get notificationDeletedStream;

  /// Stream of updated unread counts
  Stream<int> get unreadCountStream;
}

class NotificationWebSocketDataSourceImpl
    implements NotificationWebSocketDataSource {
  io.Socket? _socket;
  final FlutterSecureStorage _secureStorage;

  final _notificationController = StreamController<NotificationDto>.broadcast();
  final _readController = StreamController<String>.broadcast();
  final _deletedController = StreamController<String>.broadcast();
  final _unreadCountController = StreamController<int>.broadcast();

  NotificationWebSocketDataSourceImpl({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

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
  bool get isConnected => _socket?.connected ?? false;

  @override
  Future<void> connect(String userId) async {
    try {
      await disconnect();

      // Read JWT token for socket authentication
      final token = await _secureStorage.read(key: 'access_token');

      // Use the same base URL as the REST API
      final socketUrl = ApiEndpoints.baseUrl;

      _socket = io.io(
        socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableForceNew()
            .setAuth({'token': token ?? ''}) // JWT token for auth middleware
            .build(),
      );

      _setupEventListeners();

      // Wait for connection with timeout
      final completer = Completer<void>();

      _socket!.onConnect((_) {
        if (!completer.isCompleted) completer.complete();
      });

      _socket!.onConnectError((data) {
        if (!completer.isCompleted) {
          completer.completeError('Socket connection failed: $data');
        }
      });

      _socket!.connect();

      await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          // Don't throw - just log. WebSocket is supplementary.
          print('WebSocket connection timed out (non-fatal)');
        },
      );
    } catch (e) {
      // WebSocket failures should not break the app
      print('WebSocket connect error (non-fatal): $e');
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
    } catch (e) {
      print('WebSocket disconnect warning: $e');
    }
  }

  void _setupEventListeners() {
    if (_socket == null) return;

    // The backend emits 'new_notification' with the notification document
    _socket!.on(WebSocketEvents.newNotification, (data) {
      try {
        if (data is Map<String, dynamic>) {
          final notification = NotificationDto.fromJson(data);
          _notificationController.add(notification);
        }
      } catch (e) {
        print('Error parsing realtime notification: $e');
      }
    });

    // Listen for read status updates
    _socket!.on(WebSocketEvents.notificationRead, (data) {
      try {
        if (data is Map) {
          final id = (data['notificationId'] ?? data['_id'] ?? '').toString();
          if (id.isNotEmpty) _readController.add(id);
        }
      } catch (e) {
        print('Error parsing notification read event: $e');
      }
    });

    // Listen for deletion events
    _socket!.on(WebSocketEvents.notificationDeleted, (data) {
      try {
        if (data is Map) {
          final id = (data['notificationId'] ?? data['_id'] ?? '').toString();
          if (id.isNotEmpty) _deletedController.add(id);
        }
      } catch (e) {
        print('Error parsing notification deleted event: $e');
      }
    });

    // Listen for unread count updates
    _socket!.on(WebSocketEvents.notificationCountUpdated, (data) {
      try {
        if (data is Map) {
          final count = (data['count'] as num?)?.toInt();
          if (count != null) _unreadCountController.add(count);
        } else if (data is num) {
          _unreadCountController.add(data.toInt());
        }
      } catch (e) {
        print('Error parsing unread count update: $e');
      }
    });

    // Handle reconnection: backend auto-joins user to their room on connect
    _socket!.onReconnect((_) {
      print('WebSocket reconnected');
    });

    _socket!.onDisconnect((_) {
      print('WebSocket disconnected');
    });

    _socket!.onError((error) {
      print('WebSocket error: $error');
    });
  }

  void dispose() {
    disconnect();
    _notificationController.close();
    _readController.close();
    _deletedController.close();
    _unreadCountController.close();
  }
}
