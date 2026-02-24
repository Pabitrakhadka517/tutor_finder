import 'dart:async';
import 'dart:convert';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_endpoints.dart';
import '../dtos/message_dto.dart';

/// Service for real-time Socket.IO communication.
/// Handles all real-time messaging functionality.
class SocketService {
  io.Socket? _socket;
  final AppConfig _appConfig;
  String? _authToken;
  String? _userId;

  // Stream controllers for real-time events
  final StreamController<MessageDto> _messageReceivedController =
      StreamController<MessageDto>.broadcast();
  final StreamController<MessageDto> _messageSentController =
      StreamController<MessageDto>.broadcast();
  final StreamController<Map<String, dynamic>> _messageReadController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _userTypingController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _userOnlineController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _roomUpdatedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  // Public streams
  Stream<MessageDto> get messageReceived => _messageReceivedController.stream;
  Stream<MessageDto> get messageSent => _messageSentController.stream;
  Stream<Map<String, dynamic>> get messageRead => _messageReadController.stream;
  Stream<Map<String, dynamic>> get userTyping => _userTypingController.stream;
  Stream<Map<String, dynamic>> get userOnline => _userOnlineController.stream;
  Stream<Map<String, dynamic>> get roomUpdated => _roomUpdatedController.stream;
  Stream<String> get errors => _errorController.stream;
  Stream<bool> get connectionStatus => _connectionController.stream;

  bool get isConnected => _socket?.connected ?? false;

  SocketService(this._appConfig);

  /// Connect to the Socket.IO server with authentication.
  Future<void> connect(String authToken, String userId) async {
    try {
      _authToken = authToken;
      _userId = userId;

      if (_socket?.connected == true) {
        await disconnect();
      }

      _socket = io.io(
        '${_appConfig.baseUrl}',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({'Authorization': 'Bearer $authToken'})
            .setAuth({'token': authToken, 'userId': userId})
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .build(),
      );

      _setupEventListeners();
      _socket!.connect();
    } catch (e) {
      _errorController.add('Connection failed: ${e.toString()}');
    }
  }

  /// Disconnect from the Socket.IO server.
  Future<void> disconnect() async {
    try {
      _socket?.clearListeners();
      _socket?.disconnect();
      _socket = null;
      _connectionController.add(false);
    } catch (e) {
      _errorController.add('Disconnect failed: ${e.toString()}');
    }
  }

  /// Join a chat room.
  void joinRoom(String chatId) {
    if (!isConnected) {
      _errorController.add('Not connected to server');
      return;
    }

    _socket!.emit(ApiEndpoints.joinRoom, {'chatId': chatId, 'userId': _userId});
  }

  /// Leave a chat room.
  void leaveRoom(String chatId) {
    if (!isConnected) {
      return; // Silently fail if not connected
    }

    _socket!.emit(ApiEndpoints.leaveRoom, {
      'chatId': chatId,
      'userId': _userId,
    });
  }

  /// Send a message through Socket.IO.
  void sendMessage(MessageDto message) {
    if (!isConnected) {
      _errorController.add('Not connected to server');
      return;
    }

    _socket!.emit(ApiEndpoints.sendMessage, message.toJson());
  }

  /// Mark messages as read.
  void markMessagesAsRead(String chatId, List<String> messageIds) {
    if (!isConnected) {
      return; // Silently fail if not connected
    }

    _socket!.emit(ApiEndpoints.messageRead, {
      'chatId': chatId,
      'userId': _userId,
      'messageIds': messageIds,
    });
  }

  /// Send typing indicator.
  void sendTypingIndicator(String chatId, bool isTyping) {
    if (!isConnected) {
      return; // Silently fail if not connected
    }

    final event = isTyping
        ? ApiEndpoints.userTyping
        : ApiEndpoints.userStoppedTyping;
    _socket!.emit(event, {'chatId': chatId, 'userId': _userId});
  }

  /// Update user online status.
  void updateOnlineStatus(bool isOnline) {
    if (!isConnected) {
      return; // Silently fail if not connected
    }

    final event = isOnline ? ApiEndpoints.userOnline : ApiEndpoints.userOffline;
    _socket!.emit(event, {'userId': _userId});
  }

  /// Set up event listeners for Socket.IO events.
  void _setupEventListeners() {
    _socket!.on(ApiEndpoints.connect, (_) {
      _connectionController.add(true);
    });

    _socket!.on(ApiEndpoints.disconnect, (_) {
      _connectionController.add(false);
    });

    _socket!.on(ApiEndpoints.messageReceived, (data) {
      try {
        final messageDto = MessageDto.fromJson(data);
        _messageReceivedController.add(messageDto);
      } catch (e) {
        _errorController.add(
          'Failed to parse received message: ${e.toString()}',
        );
      }
    });

    _socket!.on(ApiEndpoints.messageSent, (data) {
      try {
        final messageDto = MessageDto.fromJson(data);
        _messageSentController.add(messageDto);
      } catch (e) {
        _errorController.add('Failed to parse sent message: ${e.toString()}');
      }
    });

    _socket!.on(ApiEndpoints.messageRead, (data) {
      try {
        _messageReadController.add(Map<String, dynamic>.from(data));
      } catch (e) {
        _errorController.add(
          'Failed to parse message read event: ${e.toString()}',
        );
      }
    });

    _socket!.on(ApiEndpoints.userTyping, (data) {
      try {
        _userTypingController.add(Map<String, dynamic>.from(data));
      } catch (e) {
        _errorController.add('Failed to parse typing event: ${e.toString()}');
      }
    });

    _socket!.on(ApiEndpoints.userStoppedTyping, (data) {
      try {
        final typingData = Map<String, dynamic>.from(data);
        typingData['isTyping'] = false;
        _userTypingController.add(typingData);
      } catch (e) {
        _errorController.add(
          'Failed to parse stopped typing event: ${e.toString()}',
        );
      }
    });

    _socket!.on(ApiEndpoints.userOnline, (data) {
      try {
        final onlineData = Map<String, dynamic>.from(data);
        onlineData['isOnline'] = true;
        _userOnlineController.add(onlineData);
      } catch (e) {
        _errorController.add(
          'Failed to parse user online event: ${e.toString()}',
        );
      }
    });

    _socket!.on(ApiEndpoints.userOffline, (data) {
      try {
        final offlineData = Map<String, dynamic>.from(data);
        offlineData['isOnline'] = false;
        _userOnlineController.add(offlineData);
      } catch (e) {
        _errorController.add(
          'Failed to parse user offline event: ${e.toString()}',
        );
      }
    });

    _socket!.on(ApiEndpoints.roomUpdated, (data) {
      try {
        _roomUpdatedController.add(Map<String, dynamic>.from(data));
      } catch (e) {
        _errorController.add(
          'Failed to parse room updated event: ${e.toString()}',
        );
      }
    });

    _socket!.on(ApiEndpoints.error, (data) {
      try {
        final errorMessage = data is String
            ? data
            : data['message'] ?? 'Unknown error';
        _errorController.add(errorMessage);
      } catch (e) {
        _errorController.add('Socket error: ${e.toString()}');
      }
    });

    // Connection error handling
    _socket!.on('connect_error', (data) {
      _connectionController.add(false);
      _errorController.add('Connection error: ${data.toString()}');
    });

    _socket!.on('reconnect', (data) {
      _connectionController.add(true);
    });

    _socket!.on('reconnect_error', (data) {
      _errorController.add('Reconnection error: ${data.toString()}');
    });
  }

  /// Dispose of resources.
  void dispose() {
    disconnect();
    _messageReceivedController.close();
    _messageSentController.close();
    _messageReadController.close();
    _userTypingController.close();
    _userOnlineController.close();
    _roomUpdatedController.close();
    _errorController.close();
    _connectionController.close();
  }

  /// Check if currently in a specific room.
  bool isInRoom(String chatId) {
    // This would typically be tracked locally or queried from server
    return isConnected;
  }

  /// Get connection statistics.
  Map<String, dynamic> getConnectionStats() {
    return {
      'connected': isConnected,
      'socket_id': _socket?.id,
      'user_id': _userId,
      'last_ping': _socket?.connected == true
          ? DateTime.now().toIso8601String()
          : null,
    };
  }

  /// Reconnect to server.
  Future<void> reconnect() async {
    if (_authToken != null && _userId != null) {
      await disconnect();
      await connect(_authToken!, _userId!);
    } else {
      _errorController.add('Cannot reconnect: Missing authentication data');
    }
  }
}
