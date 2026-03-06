import '../../domain/entities/chat_entities.dart';

class ChatListState {
  final bool isLoading;
  final List<ChatRoomEntity> chats;
  final String? errorMessage;

  const ChatListState({
    this.isLoading = false,
    this.chats = const [],
    this.errorMessage,
  });

  ChatListState copyWith({
    bool? isLoading,
    List<ChatRoomEntity>? chats,
    String? errorMessage,
  }) {
    return ChatListState(
      isLoading: isLoading ?? this.isLoading,
      chats: chats ?? this.chats,
      errorMessage: errorMessage,
    );
  }
}

class ChatMessagesState {
  final bool isLoading;
  final bool isSending;
  final List<MessageEntity> messages;
  final String? errorMessage;

  const ChatMessagesState({
    this.isLoading = false,
    this.isSending = false,
    this.messages = const [],
    this.errorMessage,
  });

  ChatMessagesState copyWith({
    bool? isLoading,
    bool? isSending,
    List<MessageEntity>? messages,
    String? errorMessage,
  }) {
    return ChatMessagesState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }
}
