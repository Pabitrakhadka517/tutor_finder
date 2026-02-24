import 'package:dartz/dartz.dart';

import '../entities/message_entity.dart';
import '../entities/chat_room_entity.dart';
import '../failures/chat_failures.dart';
import '../repositories/chat_room_repository.dart';
import '../repositories/message_repository.dart';

/// Use case for sending messages in a chat room.
/// Handles all business logic for message creation and validation.
class SendMessageUseCase {
  final MessageRepository _messageRepository;
  final ChatRoomRepository _chatRoomRepository;

  SendMessageUseCase(this._messageRepository, this._chatRoomRepository);

  /// Send a message in a chat room.
  /// Validates user access, creates message, and updates chat room.
  Future<Either<ChatFailure, MessageEntity>> call(
    SendMessageParams params,
  ) async {
    // Validate message content
    if (params.content.trim().isEmpty) {
      return Left(ChatFailure.invalidInput('Message content cannot be empty'));
    }

    if (params.content.length > 5000) {
      return Left(
        ChatFailure.invalidInput(
          'Message content too long (max 5000 characters)',
        ),
      );
    }

    // Get chat room and validate user access
    final chatRoomResult = await _chatRoomRepository.getChatRoomById(
      params.chatId,
    );
    if (chatRoomResult.isLeft()) {
      return Left(
        chatRoomResult.fold(
          (failure) => failure,
          (_) => ChatFailure.serverError('Unexpected error'),
        ),
      );
    }

    final chatRoom = chatRoomResult.getOrElse(
      () => throw Exception('Should not happen'),
    );

    // Check if user can access this chat room (business rule)
    if (!chatRoom.canUserAccess(params.senderId)) {
      return Left(
        ChatFailure.accessDenied('User does not have access to this chat room'),
      );
    }

    // Check if chat room is active
    if (!chatRoom.isActive) {
      return Left(
        ChatFailure.invalidOperation(
          'Cannot send message to inactive chat room',
        ),
      );
    }

    // Validate reply-to message if specified
    if (params.replyToId != null) {
      final replyToResult = await _messageRepository.getMessageById(
        params.replyToId!,
      );
      if (replyToResult.isLeft()) {
        return Left(ChatFailure.invalidInput('Referenced message not found'));
      }

      final replyToMessage = replyToResult.getOrElse(
        () => throw Exception('Should not happen'),
      );
      if (replyToMessage.chatId != params.chatId) {
        return Left(
          ChatFailure.invalidInput(
            'Cannot reply to message from different chat',
          ),
        );
      }
    }

    // Create the message
    final messageResult = await _messageRepository.createMessage(
      chatId: params.chatId,
      senderId: params.senderId,
      content: params.content,
      attachments: params.attachments,
      replyToId: params.replyToId,
    );

    if (messageResult.isLeft()) {
      return messageResult;
    }

    final message = messageResult.getOrElse(
      () => throw Exception('Should not happen'),
    );

    // Update chat room's last message information
    await _chatRoomRepository.updateLastMessage(
      chatId: params.chatId,
      lastMessage: params.content.length > 50
          ? '${params.content.substring(0, 50)}...'
          : params.content,
      lastMessageAt: message.createdAt,
    );

    return Right(message);
  }
}

/// Parameters for sending a message
class SendMessageParams {
  final String chatId;
  final String senderId;
  final String content;
  final List<String>? attachments;
  final String? replyToId;

  SendMessageParams({
    required this.chatId,
    required this.senderId,
    required this.content,
    this.attachments,
    this.replyToId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SendMessageParams &&
        other.chatId == chatId &&
        other.senderId == senderId &&
        other.content == content &&
        _listEquals(other.attachments, attachments) &&
        other.replyToId == replyToId;
  }

  @override
  int get hashCode {
    return chatId.hashCode ^
        senderId.hashCode ^
        content.hashCode ^
        (attachments?.hashCode ?? 0) ^
        (replyToId?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'SendMessageParams(chatId: $chatId, senderId: $senderId, content: ${content.length} chars, attachments: ${attachments?.length ?? 0}, replyToId: $replyToId)';
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
