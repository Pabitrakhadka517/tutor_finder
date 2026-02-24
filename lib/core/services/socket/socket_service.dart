import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../api/api_endpoints.dart';
import '../../constants/app_constants.dart';

/// Provider for the SocketService singleton
final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});

/// Real-time socket service using Socket.io
/// Handles chat messages, notifications, and read receipts
class SocketService {
  io.Socket? _socket;
  final _storage = const FlutterSecureStorage();
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  io.Socket? get socket => _socket;

  /// Initialize and connect to Socket.io server
  Future<void> connect() async {
    if (_isConnected && _socket != null) return;

    final token = await _storage.read(key: AppConstants.accessTokenKey);
    if (token == null) {
      debugPrint('SocketService: No auth token, cannot connect');
      return;
    }

    final baseUrl = ApiEndpoints.baseUrl;
    debugPrint('SocketService: Connecting to $baseUrl');

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('SocketService: Connected');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('SocketService: Disconnected');
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      debugPrint('SocketService: Connection error: $error');
    });

    _socket!.onError((error) {
      debugPrint('SocketService: Error: $error');
    });

    _socket!.connect();
  }

  /// Disconnect from socket server
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    debugPrint('SocketService: Manually disconnected');
  }

  /// Join a specific chat room
  void joinRoom(String chatId) {
    if (!_isConnected) {
      debugPrint('SocketService: Not connected, cannot join room');
      return;
    }
    _socket?.emit('join_room', {'chatId': chatId});
    debugPrint('SocketService: Joining room $chatId');
  }

  /// Send a message to a chat room
  void sendMessage(String chatId, String content, {List<String>? attachments}) {
    if (!_isConnected) {
      debugPrint('SocketService: Not connected, cannot send message');
      return;
    }
    final data = {
      'chatId': chatId,
      'content': content,
      if (attachments != null && attachments.isNotEmpty)
        'attachments': attachments,
    };
    _socket?.emit('send_message', data);
  }

  /// Mark messages as read in a chat
  void markRead(String chatId) {
    if (!_isConnected) return;
    _socket?.emit('mark_read', {'chatId': chatId});
  }

  /// Listen for incoming messages
  void onReceiveMessage(void Function(dynamic data) callback) {
    _socket?.on('receive_message', callback);
  }

  /// Listen for message sent confirmation
  void onMessageSent(void Function(dynamic data) callback) {
    _socket?.on('message_sent', callback);
  }

  /// Listen for read receipts
  void onMessagesRead(void Function(dynamic data) callback) {
    _socket?.on('messages_read', callback);
  }

  /// Listen for room join confirmation
  void onJoinedRoom(void Function(dynamic data) callback) {
    _socket?.on('joined_room', callback);
  }

  /// Listen for new notifications
  void onNewNotification(void Function(dynamic data) callback) {
    _socket?.on('new_notification', callback);
  }

  /// Listen for socket errors
  void onSocketError(void Function(dynamic data) callback) {
    _socket?.on('error', callback);
  }

  /// Remove a specific event listener
  void off(String event) {
    _socket?.off(event);
  }

  /// Remove all listeners for an event
  void offAll() {
    _socket?.clearListeners();
  }
}
