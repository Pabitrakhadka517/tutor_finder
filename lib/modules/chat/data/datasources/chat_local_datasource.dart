import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/errors/exceptions.dart';
import '../dtos/chat_room_dto.dart';
import '../dtos/message_dto.dart';

/// Local data source for chat operations.
/// Handles local storage and caching of chat data.
abstract class ChatLocalDataSource {
  // Chat Room Operations
  Future<void> cacheChatRoom(ChatRoomDto chatRoom);
  Future<ChatRoomDto?> getCachedChatRoom(String chatId);
  Future<List<ChatRoomDto>> getCachedChatRooms(String userId);
  Future<void> removeCachedChatRoom(String chatId);
  Future<void> clearChatRoomsCache();

  // Message Operations
  Future<void> cacheMessage(MessageDto message);
  Future<MessageDto?> getCachedMessage(String messageId);
  Future<List<MessageDto>> getCachedMessagesForChat(
    String chatId, {
    int page = 1,
    int limit = 20,
  });
  Future<void> cacheMessages(List<MessageDto> messages);
  Future<void> removeCachedMessage(String messageId);
  Future<void> clearMessagesCache(String? chatId);

  // Offline Message Operations
  Future<void> saveOfflineMessage(MessageDto message);
  Future<List<MessageDto>> getOfflineMessages();
  Future<void> removeOfflineMessage(String messageId);
  Future<void> clearOfflineMessages();

  // Read Status Operations
  Future<void> cacheMessageReadStatus(
    String chatId,
    String messageId,
    String userId,
  );
  Future<List<String>> getCachedReadMessages(String chatId, String userId);
  Future<void> clearReadStatusCache(String chatId);

  // User Preferences
  Future<void> saveChatSettings(Map<String, dynamic> settings);
  Future<Map<String, dynamic>?> getChatSettings();
  Future<void> saveLastSeenTimestamp(String chatId, DateTime timestamp);
  Future<DateTime?> getLastSeenTimestamp(String chatId);
}

/// Implementation of chat local data source.
class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final SharedPreferences sharedPreferences;
  final DatabaseHelper databaseHelper;

  static const String _chatRoomsKey = 'cached_chat_rooms';
  static const String _messagesKey = 'cached_messages';
  static const String _offlineMessagesKey = 'offline_messages';
  static const String _readStatusKey = 'read_status';
  static const String _chatSettingsKey = 'chat_settings';
  static const String _lastSeenKey = 'last_seen';

  // Table names
  static const String _chatRoomsTable = 'chat_rooms';
  static const String _messagesTable = 'messages';
  static const String _offlineMessagesTable = 'offline_messages';
  static const String _readStatusTable = 'read_status';

  ChatLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.databaseHelper,
  });

  @override
  Future<void> cacheChatRoom(ChatRoomDto chatRoom) async {
    try {
      final db = await databaseHelper.database;
      await db.insert(_chatRoomsTable, {
        'id': chatRoom.id,
        'data': jsonEncode(chatRoom.toJson()),
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw CacheException('Failed to cache chat room: ${e.toString()}');
    }
  }

  @override
  Future<ChatRoomDto?> getCachedChatRoom(String chatId) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _chatRoomsTable,
        where: 'id = ?',
        whereArgs: [chatId],
      );

      if (maps.isNotEmpty) {
        final data = jsonDecode(maps.first['data']);
        return ChatRoomDto.fromJson(data);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached chat room: ${e.toString()}');
    }
  }

  @override
  Future<List<ChatRoomDto>> getCachedChatRooms(String userId) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _chatRoomsTable,
        orderBy: 'cached_at DESC',
      );

      final chatRooms = <ChatRoomDto>[];
      for (final map in maps) {
        try {
          final data = jsonDecode(map['data']);
          final chatRoom = ChatRoomDto.fromJson(data);
          // Filter by user participation
          if (chatRoom.studentId == userId || chatRoom.tutorId == userId) {
            chatRooms.add(chatRoom);
          }
        } catch (e) {
          // Skip invalid cached data
          continue;
        }
      }
      return chatRooms;
    } catch (e) {
      throw CacheException('Failed to get cached chat rooms: ${e.toString()}');
    }
  }

  @override
  Future<void> removeCachedChatRoom(String chatId) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(_chatRoomsTable, where: 'id = ?', whereArgs: [chatId]);
    } catch (e) {
      throw CacheException(
        'Failed to remove cached chat room: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearChatRoomsCache() async {
    try {
      final db = await databaseHelper.database;
      await db.delete(_chatRoomsTable);
    } catch (e) {
      throw CacheException('Failed to clear chat rooms cache: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheMessage(MessageDto message) async {
    try {
      final db = await databaseHelper.database;
      await db.insert(_messagesTable, {
        'id': message.id,
        'chat_id': message.chatId,
        'data': jsonEncode(message.toJson()),
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw CacheException('Failed to cache message: ${e.toString()}');
    }
  }

  @override
  Future<MessageDto?> getCachedMessage(String messageId) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _messagesTable,
        where: 'id = ?',
        whereArgs: [messageId],
      );

      if (maps.isNotEmpty) {
        final data = jsonDecode(maps.first['data']);
        return MessageDto.fromJson(data);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached message: ${e.toString()}');
    }
  }

  @override
  Future<List<MessageDto>> getCachedMessagesForChat(
    String chatId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final db = await databaseHelper.database;
      final offset = (page - 1) * limit;

      final List<Map<String, dynamic>> maps = await db.query(
        _messagesTable,
        where: 'chat_id = ?',
        whereArgs: [chatId],
        orderBy: 'cached_at DESC',
        limit: limit,
        offset: offset,
      );

      final messages = <MessageDto>[];
      for (final map in maps) {
        try {
          final data = jsonDecode(map['data']);
          messages.add(MessageDto.fromJson(data));
        } catch (e) {
          // Skip invalid cached data
          continue;
        }
      }
      return messages;
    } catch (e) {
      throw CacheException('Failed to get cached messages: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheMessages(List<MessageDto> messages) async {
    try {
      final db = await databaseHelper.database;
      final batch = db.batch();

      for (final message in messages) {
        batch.insert(_messagesTable, {
          'id': message.id,
          'chat_id': message.chatId,
          'data': jsonEncode(message.toJson()),
          'cached_at': DateTime.now().millisecondsSinceEpoch,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw CacheException('Failed to cache messages: ${e.toString()}');
    }
  }

  @override
  Future<void> removeCachedMessage(String messageId) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(_messagesTable, where: 'id = ?', whereArgs: [messageId]);
    } catch (e) {
      throw CacheException('Failed to remove cached message: ${e.toString()}');
    }
  }

  @override
  Future<void> clearMessagesCache(String? chatId) async {
    try {
      final db = await databaseHelper.database;
      if (chatId != null) {
        await db.delete(
          _messagesTable,
          where: 'chat_id = ?',
          whereArgs: [chatId],
        );
      } else {
        await db.delete(_messagesTable);
      }
    } catch (e) {
      throw CacheException('Failed to clear messages cache: ${e.toString()}');
    }
  }

  @override
  Future<void> saveOfflineMessage(MessageDto message) async {
    try {
      final db = await databaseHelper.database;
      await db.insert(_offlineMessagesTable, {
        'id': message.id,
        'data': jsonEncode(message.toJson()),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw CacheException('Failed to save offline message: ${e.toString()}');
    }
  }

  @override
  Future<List<MessageDto>> getOfflineMessages() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _offlineMessagesTable,
        orderBy: 'created_at ASC',
      );

      final messages = <MessageDto>[];
      for (final map in maps) {
        try {
          final data = jsonDecode(map['data']);
          messages.add(MessageDto.fromJson(data));
        } catch (e) {
          // Skip invalid offline message data
          continue;
        }
      }
      return messages;
    } catch (e) {
      throw CacheException('Failed to get offline messages: ${e.toString()}');
    }
  }

  @override
  Future<void> removeOfflineMessage(String messageId) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        _offlineMessagesTable,
        where: 'id = ?',
        whereArgs: [messageId],
      );
    } catch (e) {
      throw CacheException('Failed to remove offline message: ${e.toString()}');
    }
  }

  @override
  Future<void> clearOfflineMessages() async {
    try {
      final db = await databaseHelper.database;
      await db.delete(_offlineMessagesTable);
    } catch (e) {
      throw CacheException('Failed to clear offline messages: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheMessageReadStatus(
    String chatId,
    String messageId,
    String userId,
  ) async {
    try {
      final db = await databaseHelper.database;
      await db.insert(_readStatusTable, {
        'chat_id': chatId,
        'message_id': messageId,
        'user_id': userId,
        'read_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw CacheException('Failed to cache read status: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getCachedReadMessages(
    String chatId,
    String userId,
  ) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _readStatusTable,
        columns: ['message_id'],
        where: 'chat_id = ? AND user_id = ?',
        whereArgs: [chatId, userId],
      );

      return maps.map((map) => map['message_id'] as String).toList();
    } catch (e) {
      throw CacheException(
        'Failed to get cached read messages: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearReadStatusCache(String chatId) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        _readStatusTable,
        where: 'chat_id = ?',
        whereArgs: [chatId],
      );
    } catch (e) {
      throw CacheException(
        'Failed to clear read status cache: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveChatSettings(Map<String, dynamic> settings) async {
    try {
      await sharedPreferences.setString(_chatSettingsKey, jsonEncode(settings));
    } catch (e) {
      throw CacheException('Failed to save chat settings: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>?> getChatSettings() async {
    try {
      final settingsString = sharedPreferences.getString(_chatSettingsKey);
      if (settingsString != null) {
        return Map<String, dynamic>.from(jsonDecode(settingsString));
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get chat settings: ${e.toString()}');
    }
  }

  @override
  Future<void> saveLastSeenTimestamp(String chatId, DateTime timestamp) async {
    try {
      final key = '${_lastSeenKey}_$chatId';
      await sharedPreferences.setString(key, timestamp.toIso8601String());
    } catch (e) {
      throw CacheException(
        'Failed to save last seen timestamp: ${e.toString()}',
      );
    }
  }

  @override
  Future<DateTime?> getLastSeenTimestamp(String chatId) async {
    try {
      final key = '${_lastSeenKey}_$chatId';
      final timestampString = sharedPreferences.getString(key);
      if (timestampString != null) {
        return DateTime.parse(timestampString);
      }
      return null;
    } catch (e) {
      throw CacheException(
        'Failed to get last seen timestamp: ${e.toString()}',
      );
    }
  }
}
