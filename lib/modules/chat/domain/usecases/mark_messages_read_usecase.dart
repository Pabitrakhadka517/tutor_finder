import 'package:dartz/dartz.dart';

import '../failures/chat_failures.dart';
import '../repositories/chat_room_repository.dart';
import '../repositories/message_repository.dart';

/// Use case for marking messages as read.
/// Handles access control and read status updates.
class MarkMessagesReadUseCase {
  final MessageRepository _messageRepository;
  final ChatRoomRepository _chatRoomRepository;

  MarkMessagesReadUseCase(this._messageRepository, this._chatRoomRepository);

  /// Mark messages as read for a user in a chat room.
  /// Validates access and updates read status.
  Future<Either<ChatFailure, void>> call(MarkMessagesReadParams params) async {
    // Validate user access to chat room
    final accessResult = await _chatRoomRepository.canUserAccessChatRoom(
      params.userId,
      params.chatId,
    );

    if (accessResult.isLeft()) {
      return Left(
        accessResult.fold(
          (failure) => failure,
          (_) => ChatFailure.serverError('Unexpected error'),
        ),
      );
    }

    final hasAccess = accessResult.getOrElse(() => false);
    if (!hasAccess) {
      return Left(
        ChatFailure.accessDenied('User does not have access to this chat room'),
      );
    }

    // Mark messages as read
    return await _messageRepository.markMessagesAsRead(
      params.chatId,
      params.userId,
      messageIds: params.messageIds,
    );
  }
}

/// Parameters for marking messages as read
class MarkMessagesReadParams {
  final String chatId;
  final String userId;
  final List<String>? messageIds; // If null, marks all unread messages

  MarkMessagesReadParams({
    required this.chatId,
    required this.userId,
    this.messageIds,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MarkMessagesReadParams &&
        other.chatId == chatId &&
        other.userId == userId &&
        _listEquals(other.messageIds, messageIds);
  }

  @override
  int get hashCode {
    return chatId.hashCode ^ userId.hashCode ^ (messageIds?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'MarkMessagesReadParams(chatId: $chatId, userId: $userId, messageIds: ${messageIds?.length ?? "all"})';
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
