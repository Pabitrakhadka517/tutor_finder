import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../dtos/chat_room_dto.dart';
import '../dtos/message_dto.dart';

/// Remote data source for chat operations.
/// Handles all API communication for chat functionality.
abstract class ChatRemoteDataSource {
  // Chat Room Operations
  Future<ChatRoomDto> createChatRoom({
    required String studentId,
    required String tutorId,
    required String bookingId,
    required String authToken,
  });

  Future<ChatRoomDto> getChatRoomById(String chatId, String authToken);

  Future<ChatRoomDto?> findChatRoomBetweenUsers(
    String studentId,
    String tutorId,
    String authToken,
  );

  Future<ChatRoomDto?> findChatRoomByBooking(
    String bookingId,
    String authToken,
  );

  Future<List<ChatRoomDto>> getChatRoomsForUser(
    String userId,
    String authToken, {
    bool? activeOnly,
    int? limit,
    int? offset,
  });

  Future<ChatRoomDto> updateChatRoom(ChatRoomDto chatRoom, String authToken);

  Future<ChatRoomDto> updateLastMessage({
    required String chatId,
    required String lastMessage,
    required DateTime lastMessageAt,
    required String authToken,
  });

  Future<void> deactivateChatRoom(String chatId, String authToken);

  Future<bool> canUserAccessChatRoom(
    String userId,
    String chatId,
    String authToken,
  );

  // Message Operations
  Future<MessageDto> createMessage({
    required String chatId,
    required String senderId,
    required String content,
    List<String>? attachments,
    String? replyToId,
    required String authToken,
  });

  Future<MessageDto> getMessageById(String messageId, String authToken);

  Future<List<MessageDto>> getMessagesForChat(
    String chatId,
    String authToken, {
    int page = 1,
    int limit = 20,
    DateTime? before,
    DateTime? after,
  });

  Future<void> markMessagesAsRead(
    String chatId,
    String userId,
    String authToken, {
    List<String>? messageIds,
  });

  Future<int> getUnreadMessageCount(
    String chatId,
    String userId,
    String authToken,
  );

  Future<int> getTotalUnreadMessageCount(String userId, String authToken);

  Future<MessageDto> updateMessage(MessageDto message, String authToken);

  Future<void> deleteMessage(String messageId, String userId, String authToken);

  Future<List<MessageDto>> searchMessages(
    String chatId,
    String query,
    String authToken, {
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<Map<String, dynamic>> getMessageStats(String chatId, String authToken);

  Future<List<MessageDto>> getRecentMessages(
    String userId,
    String authToken, {
    int limit = 10,
    Duration? within,
  });
}

/// Implementation of chat remote data source.
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client client;
  final AppConfig appConfig;

  ChatRemoteDataSourceImpl({required this.client, required this.appConfig});

  @override
  Future<ChatRoomDto> createChatRoom({
    required String studentId,
    required String tutorId,
    required String bookingId,
    required String authToken,
  }) async {
    try {
      final createDto = ChatRoomDto.forCreation(
        studentId: studentId,
        tutorId: tutorId,
        bookingId: bookingId,
      );

      final response = await client.post(
        Uri.parse('${appConfig.baseUrl}${ApiEndpoints.createChatRoom}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(createDto.toJson()),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return ChatRoomDto.fromJson(responseData['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        throw ValidationException(responseData['message'] ?? 'Invalid input');
      } else if (response.statusCode == 500) {
        throw ServerException('Internal server error');
      } else {
        throw ServerException(
          'Failed to create chat room: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<ChatRoomDto> getChatRoomById(String chatId, String authToken) async {
    try {
      final response = await client.get(
        Uri.parse(
          '${appConfig.baseUrl}${ApiEndpoints.getChatRoom.replaceAll('{id}', chatId)}',
        ),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ChatRoomDto.fromJson(responseData['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Chat room not found');
      } else {
        throw ServerException(
          'Failed to get chat room: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<ChatRoomDto?> findChatRoomBetweenUsers(
    String studentId,
    String tutorId,
    String authToken,
  ) async {
    try {
      final response = await client.get(
        Uri.parse(
          '${appConfig.baseUrl}${ApiEndpoints.findChatRoom}?student_id=$studentId&tutor_id=$tutorId',
        ),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null) {
          return ChatRoomDto.fromJson(responseData['data']);
        }
        return null;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else {
        throw ServerException(
          'Failed to find chat room: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<ChatRoomDto?> findChatRoomByBooking(
    String bookingId,
    String authToken,
  ) async {
    try {
      final response = await client.get(
        Uri.parse(
          '${appConfig.baseUrl}${ApiEndpoints.findChatRoomByBooking}?booking_id=$bookingId',
        ),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null) {
          return ChatRoomDto.fromJson(responseData['data']);
        }
        return null;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else {
        throw ServerException(
          'Failed to find chat room by booking: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<ChatRoomDto>> getChatRoomsForUser(
    String userId,
    String authToken, {
    bool? activeOnly,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (activeOnly != null)
        queryParams['active_only'] = activeOnly.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final uri = Uri.parse(
        '${appConfig.baseUrl}${ApiEndpoints.getUserChatRooms.replaceAll('{userId}', userId)}',
      ).replace(queryParameters: queryParams);

      final response = await client.get(
        uri,
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> chatRoomsJson = responseData['data'];
        return chatRoomsJson.map((json) => ChatRoomDto.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else {
        throw ServerException(
          'Failed to get chat rooms: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<ChatRoomDto> updateChatRoom(
    ChatRoomDto chatRoom,
    String authToken,
  ) async {
    try {
      final response = await client.put(
        Uri.parse(
          '${appConfig.baseUrl}${ApiEndpoints.updateChatRoom.replaceAll('{id}', chatRoom.id)}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(chatRoom.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ChatRoomDto.fromJson(responseData['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Chat room not found');
      } else {
        throw ServerException(
          'Failed to update chat room: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<ChatRoomDto> updateLastMessage({
    required String chatId,
    required String lastMessage,
    required DateTime lastMessageAt,
    required String authToken,
  }) async {
    try {
      final response = await client.patch(
        Uri.parse(
          '${appConfig.baseUrl}${ApiEndpoints.updateLastMessage.replaceAll('{id}', chatId)}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'last_message': lastMessage,
          'last_message_at': lastMessageAt.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ChatRoomDto.fromJson(responseData['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Chat room not found');
      } else {
        throw ServerException(
          'Failed to update last message: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<void> deactivateChatRoom(String chatId, String authToken) async {
    try {
      final response = await client.delete(
        Uri.parse(
          '${appConfig.baseUrl}${ApiEndpoints.deactivateChatRoom.replaceAll('{id}', chatId)}',
        ),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Chat room not found');
      } else {
        throw ServerException(
          'Failed to deactivate chat room: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<bool> canUserAccessChatRoom(
    String userId,
    String chatId,
    String authToken,
  ) async {
    try {
      final response = await client.get(
        Uri.parse(
          '${appConfig.baseUrl}${ApiEndpoints.checkChatAccess.replaceAll('{id}', chatId)}?user_id=$userId',
        ),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['data']['has_access'] ?? false;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else {
        return false; // Assume no access on other errors
      }
    } catch (e) {
      if (e is AppException) rethrow;
      return false; // Assume no access on network errors
    }
  }

  // Message Operations Implementation
  @override
  Future<MessageDto> createMessage({
    required String chatId,
    required String senderId,
    required String content,
    List<String>? attachments,
    String? replyToId,
    required String authToken,
  }) async {
    try {
      final createDto = MessageDto.forCreation(
        chatId: chatId,
        senderId: senderId,
        content: content,
        attachments: attachments,
        replyToId: replyToId,
      );

      final response = await client.post(
        Uri.parse('${appConfig.baseUrl}${ApiEndpoints.createMessage}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(createDto.toJson()),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return MessageDto.fromJson(responseData['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        throw ValidationException(responseData['message'] ?? 'Invalid input');
      } else if (response.statusCode == 403) {
        throw UnauthorizedException('No access to this chat room');
      } else {
        throw ServerException(
          'Failed to create message: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<MessageDto> getMessageById(String messageId, String authToken) async {
    try {
      final response = await client.get(
        Uri.parse(
          '${appConfig.baseUrl}${ApiEndpoints.getMessage.replaceAll('{id}', messageId)}',
        ),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return MessageDto.fromJson(responseData['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Message not found');
      } else {
        throw ServerException('Failed to get message: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<MessageDto>> getMessagesForChat(
    String chatId,
    String authToken, {
    int page = 1,
    int limit = 20,
    DateTime? before,
    DateTime? after,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (before != null) queryParams['before'] = before.toIso8601String();
      if (after != null) queryParams['after'] = after.toIso8601String();

      final uri = Uri.parse(
        '${appConfig.baseUrl}${ApiEndpoints.getChatMessages.replaceAll('{chatId}', chatId)}',
      ).replace(queryParameters: queryParams);

      final response = await client.get(
        uri,
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> messagesJson = responseData['data'];
        return messagesJson.map((json) => MessageDto.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else if (response.statusCode == 403) {
        throw UnauthorizedException('No access to this chat room');
      } else {
        throw ServerException('Failed to get messages: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<void> markMessagesAsRead(
    String chatId,
    String userId,
    String authToken, {
    List<String>? messageIds,
  }) async {
    try {
      final body = <String, dynamic>{'user_id': userId};
      if (messageIds != null) {
        body['message_ids'] = messageIds;
      }

      final response = await client.patch(
        Uri.parse(
          '${appConfig.baseUrl}${ApiEndpoints.markMessagesRead.replaceAll('{chatId}', chatId)}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else if (response.statusCode == 403) {
        throw UnauthorizedException('No access to this chat room');
      } else {
        throw ServerException(
          'Failed to mark messages as read: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<int> getUnreadMessageCount(
    String chatId,
    String userId,
    String authToken,
  ) async {
    try {
      final response = await client.get(
        Uri.parse(
          '${appConfig.baseUrl}${ApiEndpoints.getChatUnreadCount.replaceAll('{chatId}', chatId)}?user_id=$userId',
        ),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['data']['unread_count'] ?? 0;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else {
        return 0; // Return 0 on other errors
      }
    } catch (e) {
      if (e is AppException) rethrow;
      return 0; // Return 0 on network errors
    }
  }

  @override
  Future<int> getTotalUnreadMessageCount(
    String userId,
    String authToken,
  ) async {
    try {
      final response = await client.get(
        Uri.parse(
          '${appConfig.baseUrl}${ApiEndpoints.getTotalUnreadCount.replaceAll('{userId}', userId)}',
        ),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['data']['total_unread_count'] ?? 0;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else {
        return 0; // Return 0 on other errors
      }
    } catch (e) {
      if (e is AppException) rethrow;
      return 0; // Return 0 on network errors
    }
  }

  @override
  Future<MessageDto> updateMessage(MessageDto message, String authToken) async {
    try {
      final response = await client.put(
        Uri.parse(
          '${appConfig.baseUrl}${ApiEndpoints.updateMessage.replaceAll('{id}', message.id)}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(message.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return MessageDto.fromJson(responseData['data']);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Message not found');
      } else if (response.statusCode == 403) {
        throw UnauthorizedException('Cannot edit this message');
      } else {
        throw ServerException(
          'Failed to update message: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteMessage(
    String messageId,
    String userId,
    String authToken,
  ) async {
    try {
      final response = await client.delete(
        Uri.parse(
          '${appConfig.baseUrl}${ApiEndpoints.deleteMessage.replaceAll('{id}', messageId)}?user_id=$userId',
        ),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Message not found');
      } else if (response.statusCode == 403) {
        throw UnauthorizedException('Cannot delete this message');
      } else {
        throw ServerException(
          'Failed to delete message: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<MessageDto>> searchMessages(
    String chatId,
    String query,
    String authToken, {
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, String>{'q': query};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (fromDate != null)
        queryParams['from_date'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['to_date'] = toDate.toIso8601String();

      final uri = Uri.parse(
        '${appConfig.baseUrl}${ApiEndpoints.searchMessages.replaceAll('{chatId}', chatId)}',
      ).replace(queryParameters: queryParams);

      final response = await client.get(
        uri,
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> messagesJson = responseData['data'];
        return messagesJson.map((json) => MessageDto.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else if (response.statusCode == 403) {
        throw UnauthorizedException('No access to this chat room');
      } else {
        throw ServerException(
          'Failed to search messages: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getMessageStats(
    String chatId,
    String authToken,
  ) async {
    try {
      final response = await client.get(
        Uri.parse(
          '${appConfig.baseUrl}${ApiEndpoints.getMessageStats.replaceAll('{chatId}', chatId)}',
        ),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['data'] ?? {};
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else {
        return {}; // Return empty stats on other errors
      }
    } catch (e) {
      if (e is AppException) rethrow;
      return {}; // Return empty stats on network errors
    }
  }

  @override
  Future<List<MessageDto>> getRecentMessages(
    String userId,
    String authToken, {
    int limit = 10,
    Duration? within,
  }) async {
    try {
      final queryParams = <String, String>{'limit': limit.toString()};
      if (within != null) {
        queryParams['within_hours'] = within.inHours.toString();
      }

      final uri = Uri.parse(
        '${appConfig.baseUrl}${ApiEndpoints.getRecentMessages.replaceAll('{userId}', userId)}',
      ).replace(queryParameters: queryParams);

      final response = await client.get(
        uri,
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> messagesJson = responseData['data'];
        return messagesJson.map((json) => MessageDto.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid or expired token');
      } else {
        return []; // Return empty list on other errors
      }
    } catch (e) {
      if (e is AppException) rethrow;
      return []; // Return empty list on network errors
    }
  }
}
