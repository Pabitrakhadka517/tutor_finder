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
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (chats) => state = state.copyWith(isLoading: false, chats: chats),
    );
  }

  Future<String?> createChat(String targetUserId) async {
    final result = await _repository.createChat(targetUserId);
    return result.fold((failure) => null, (chat) {
      fetchChats(); // Refresh list
      return chat.id;
    });
  }
}

class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  final ChatRepository _repository;
  ChatMessagesNotifier(this._repository) : super(const ChatMessagesState());

  Future<void> fetchMessages(String chatId) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getMessages(chatId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (messages) => state = state.copyWith(
        isLoading: false,
        messages: _sortNewestFirst(messages),
      ),
    );

    // Mark as read
    await _repository.markAsRead(chatId);
  }

  Future<void> sendMessage(
    String chatId, {
    String? content,
    String? filePath,
  }) async {
    final hasText = (content ?? '').trim().isNotEmpty;
    if (!hasText && filePath == null) return;

    state = state.copyWith(isSending: true);
    final result = await _repository.sendMessage(
      chatId,
      content?.trim(),
      filePath: filePath,
    );

    result.fold((failure) => state = state.copyWith(isSending: false), (
      message,
    ) {
      _upsertMessage(message, isSending: false);
    });
  }

  Future<bool> editMessage(String messageId, String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return false;

    final result = await _repository.editMessage(messageId, trimmed);
    return result.fold((failure) => false, (message) {
      _upsertMessage(message);
      return true;
    });
  }

  Future<bool> deleteMessage(String messageId) async {
    final result = await _repository.deleteMessage(messageId);
    return result.fold((failure) => false, (message) {
      _upsertMessage(message);
      return true;
    });
  }

  void addIncomingMessage(Map<String, dynamic> messageJson) {
    final msg = _parseMessageFromSocket(messageJson);
    if (msg != null) {
      _upsertMessage(msg);
    }
  }

  void applyEditedMessage(Map<String, dynamic> data) {
    final messageId = data['messageId']?.toString();
    if (messageId == null || messageId.isEmpty) return;
    final content = data['newContent']?.toString() ?? '';

    state = state.copyWith(
      messages: state.messages.map((message) {
        if (message.id != messageId) return message;
        return MessageEntity(
          id: message.id,
          chatRoomId: message.chatRoomId,
          senderId: message.senderId,
          senderName: message.senderName,
          message: content,
          messageType: message.messageType,
          fileUrl: message.fileUrl,
          fileName: message.fileName,
          attachments: message.attachments,
          isRead: message.isRead,
          isEdited: true,
          isDeleted: message.isDeleted,
          createdAt: message.createdAt,
          updatedAt: DateTime.tryParse(
            data['updatedAt']?.toString() ?? '',
          )?.toUtc(),
        );
      }).toList(),
    );
  }

  void applyDeletedMessage(Map<String, dynamic> data) {
    final messageId = data['messageId']?.toString();
    if (messageId == null || messageId.isEmpty) return;

    state = state.copyWith(
      messages: state.messages.map((message) {
        if (message.id != messageId) return message;
        return MessageEntity(
          id: message.id,
          chatRoomId: message.chatRoomId,
          senderId: message.senderId,
          senderName: message.senderName,
          message: data['content']?.toString() ?? 'This message was deleted',
          messageType: ChatMessageType.text,
          fileUrl: null,
          fileName: null,
          attachments: const [],
          isRead: message.isRead,
          isEdited: message.isEdited,
          isDeleted: true,
          createdAt: message.createdAt,
          updatedAt: DateTime.tryParse(
            data['updatedAt']?.toString() ?? '',
          )?.toUtc(),
        );
      }).toList(),
    );
  }

  void _upsertMessage(MessageEntity updatedMessage, {bool? isSending}) {
    final index = state.messages.indexWhere((m) => m.id == updatedMessage.id);
    final nextMessages = List<MessageEntity>.from(state.messages);

    if (index == -1) {
      nextMessages.add(updatedMessage);
    } else {
      nextMessages[index] = updatedMessage;
    }

    state = state.copyWith(
      isSending: isSending ?? state.isSending,
      messages: _sortNewestFirst(nextMessages),
    );
  }

  List<MessageEntity> _sortNewestFirst(List<MessageEntity> messages) {
    final sorted = List<MessageEntity>.from(messages);
    sorted.sort((a, b) {
      final byTime = b.createdAt.compareTo(a.createdAt);
      if (byTime != 0) return byTime;
      return b.id.compareTo(a.id);
    });
    return sorted;
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
        messageType: chatMessageTypeFromString(json['messageType']?.toString()),
        fileUrl: json['fileUrl']?.toString(),
        fileName: json['fileName']?.toString(),
        attachments:
            (json['attachments'] as List?)
                ?.map((item) => item.toString())
                .toList() ??
            const [],
        isRead: json['isRead'] ?? false,
        isEdited: json['isEdited'] ?? false,
        isDeleted: json['isDeleted'] ?? false,
        createdAt:
            DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toUtc() ??
            DateTime.now().toUtc(),
        updatedAt: DateTime.tryParse(
          json['updatedAt']?.toString() ?? '',
        )?.toUtc(),
      );
    } catch (_) {
      return null;
    }
  }
}
