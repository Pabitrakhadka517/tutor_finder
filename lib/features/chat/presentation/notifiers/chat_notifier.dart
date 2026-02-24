import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/chat_repository.dart';
import '../state/chat_state.dart';

class ChatListNotifier extends StateNotifier<ChatListState> {
  final ChatRepository _repository;
  ChatListNotifier(this._repository) : super(const ChatListState());

  Future<void> fetchChats() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getChats();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (chats) => state = state.copyWith(isLoading: false, chats: chats),
    );
  }

  Future<String?> createChat(String targetUserId) async {
    final result = await _repository.createChat(targetUserId);
    return result.fold(
      (failure) => null,
      (chat) {
        fetchChats(); // Refresh list
        return chat.id;
      },
    );
  }
}

class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  final ChatRepository _repository;
  ChatMessagesNotifier(this._repository) : super(const ChatMessagesState());

  Future<void> fetchMessages(String chatId) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getMessages(chatId);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (messages) =>
          state = state.copyWith(isLoading: false, messages: messages),
    );

    // Mark as read
    await _repository.markAsRead(chatId);
  }

  Future<void> sendMessage(String chatId, String content) async {
    state = state.copyWith(isSending: true);
    final result = await _repository.sendMessage(chatId, content);

    result.fold(
      (failure) => state = state.copyWith(isSending: false),
      (message) {
        state = state.copyWith(
          isSending: false,
          messages: [message, ...state.messages],
        );
      },
    );
  }

  void addIncomingMessage(Map<String, dynamic> messageJson) {
    // Called from socket listener
    final msg = _parseMessageFromSocket(messageJson);
    if (msg != null) {
      state = state.copyWith(
        messages: [msg, ...state.messages],
      );
    }
  }

  MessageEntity? _parseMessageFromSocket(Map<String, dynamic> json) {
    try {
      String senderId = '';
      String? senderName;
      if (json['sender'] is Map) {
        senderId = (json['sender'] as Map)['_id']?.toString() ?? '';
        senderName = (json['sender'] as Map)['fullName']?.toString();
      } else {
        senderId = json['sender']?.toString() ?? '';
      }

      return MessageEntity(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        chatRoomId: json['chatRoom']?.toString() ?? '',
        senderId: senderId,
        senderName: senderName,
        message:
            json['message']?.toString() ?? json['content']?.toString() ?? '',
        isRead: json['isRead'] ?? false,
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }
}
