import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/chat_models.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatRoomModel>> getChats();
  Future<ChatRoomModel> createChat(String targetUserId);
  Future<List<MessageModel>> getMessages(String chatId, {int page, int limit});
  Future<MessageModel> sendMessage(
    String chatId,
    String? content, {
    String? filePath,
  });
  Future<MessageModel> editMessage(String messageId, String content);
  Future<MessageModel> deleteMessage(String messageId);
  Future<void> markAsRead(String chatId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;
  ChatRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ChatRoomModel>> getChats() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.chats);

      if (response.statusCode == 200) {
        final chatsJson = response.data['chats'] as List? ?? [];
        return chatsJson
            .map((c) => ChatRoomModel.fromJson(c as Map<String, dynamic>))
            .toList();
      }
      throw ServerException('Failed to fetch chats');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to fetch chats',
      );
    }
  }

  @override
  Future<ChatRoomModel> createChat(String targetUserId) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.chats,
        data: {'targetId': targetUserId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ChatRoomModel.fromJson(response.data['chat']);
      }
      throw ServerException('Failed to create chat');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to create chat',
      );
    }
  }

  @override
  Future<List<MessageModel>> getMessages(
    String chatId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.chatMessages(chatId),
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final messagesJson = response.data['messages'] as List? ?? [];
        return messagesJson
            .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
            .toList();
      }
      throw ServerException('Failed to fetch messages');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to fetch messages',
      );
    }
  }

  @override
  Future<MessageModel> sendMessage(
    String chatId,
    String? content, {
    String? filePath,
  }) async {
    try {
      dynamic data;
      if (filePath != null) {
        data = FormData.fromMap({
          if ((content ?? '').trim().isNotEmpty) 'content': content!.trim(),
          'file': await MultipartFile.fromFile(filePath),
        });
      } else {
        data = {'content': (content ?? '').trim()};
      }

      final response = await apiClient.dio.post(
        ApiEndpoints.sendMessage(chatId),
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return MessageModel.fromJson(response.data['message']);
      }
      throw ServerException('Failed to send message');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to send message',
      );
    }
  }

  @override
  Future<MessageModel> editMessage(String messageId, String content) async {
    try {
      final response = await apiClient.dio.patch(
        ApiEndpoints.editMessage(messageId),
        data: {'content': content},
      );

      if (response.statusCode == 200) {
        return MessageModel.fromJson(response.data['message']);
      }
      throw ServerException('Failed to edit message');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to edit message',
      );
    }
  }

  @override
  Future<MessageModel> deleteMessage(String messageId) async {
    try {
      final response = await apiClient.dio.delete(
        ApiEndpoints.deleteMessage(messageId),
      );

      if (response.statusCode == 200) {
        return MessageModel.fromJson(response.data['message']);
      }
      throw ServerException('Failed to delete message');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to delete message',
      );
    }
  }

  @override
  Future<void> markAsRead(String chatId) async {
    try {
      await apiClient.dio.post(ApiEndpoints.markRead(chatId));
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to mark as read',
      );
    }
  }
}
