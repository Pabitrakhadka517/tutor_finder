import 'package:dartz/dartz.dart';

import '../entities/message_entity.dart';
import '../failures/chat_failures.dart';
import '../repositories/chat_room_repository.dart';
import '../repositories/message_repository.dart';

/// Use case for getting messages from a chat room.
/// Handles pagination, access control, and message retrieval.
class GetMessagesUseCase {
  final MessageRepository _messageRepository;
  final ChatRoomRepository _chatRoomRepository;

  GetMessagesUseCase(this._messageRepository, this._chatRoomRepository);

  /// Get messages for a specific chat room with pagination.
  /// Validates user access before returning messages.
  Future<Either<ChatFailure, GetMessagesResult>> call(
    GetMessagesParams params,
  ) async {
    // Validate pagination parameters
    if (params.page < 1) {
      return Left(ChatFailure.invalidInput('Page must be greater than 0'));
    }

    if (params.limit < 1 || params.limit > 100) {
      return Left(ChatFailure.invalidInput('Limit must be between 1 and 100'));
    }

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

    // Get messages from repository
    final messagesResult = await _messageRepository.getMessagesForChat(
      params.chatId,
      page: params.page,
      limit: params.limit,
      before: params.before,
      after: params.after,
    );

    if (messagesResult.isLeft()) {
      return messagesResult.map(
        (messages) => GetMessagesResult(
          messages: messages,
          hasMore: messages.length == params.limit,
          page: params.page,
          limit: params.limit,
        ),
      );
    }

    final messages = messagesResult.getOrElse(() => []);

    // Get unread count for the user in this chat
    final unreadCountResult = await _messageRepository.getUnreadMessageCount(
      params.chatId,
      params.userId,
    );

    final unreadCount = unreadCountResult.getOrElse(() => 0);

    // Mark messages as read if auto-mark is enabled and there are unread messages
    if (params.markAsRead && unreadCount > 0) {
      await _messageRepository.markMessagesAsRead(params.chatId, params.userId);
    }

    return Right(
      GetMessagesResult(
        messages: messages,
        hasMore: messages.length == params.limit,
        page: params.page,
        limit: params.limit,
        unreadCount: params.markAsRead ? 0 : unreadCount,
      ),
    );
  }
}

/// Parameters for getting messages
class GetMessagesParams {
  final String chatId;
  final String userId;
  final int page;
  final int limit;
  final DateTime? before;
  final DateTime? after;
  final bool markAsRead;

  GetMessagesParams({
    required this.chatId,
    required this.userId,
    this.page = 1,
    this.limit = 20,
    this.before,
    this.after,
    this.markAsRead = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetMessagesParams &&
        other.chatId == chatId &&
        other.userId == userId &&
        other.page == page &&
        other.limit == limit &&
        other.before == before &&
        other.after == after &&
        other.markAsRead == markAsRead;
  }

  @override
  int get hashCode {
    return chatId.hashCode ^
        userId.hashCode ^
        page.hashCode ^
        limit.hashCode ^
        (before?.hashCode ?? 0) ^
        (after?.hashCode ?? 0) ^
        markAsRead.hashCode;
  }

  @override
  String toString() {
    return 'GetMessagesParams(chatId: $chatId, userId: $userId, page: $page, limit: $limit, before: $before, after: $after, markAsRead: $markAsRead)';
  }
}

/// Result from getting messages
class GetMessagesResult {
  final List<MessageEntity> messages;
  final bool hasMore;
  final int page;
  final int limit;
  final int? unreadCount;

  GetMessagesResult({
    required this.messages,
    required this.hasMore,
    required this.page,
    required this.limit,
    this.unreadCount,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetMessagesResult &&
        _listEquals(other.messages, messages) &&
        other.hasMore == hasMore &&
        other.page == page &&
        other.limit == limit &&
        other.unreadCount == unreadCount;
  }

  @override
  int get hashCode {
    return messages.hashCode ^
        hasMore.hashCode ^
        page.hashCode ^
        limit.hashCode ^
        (unreadCount?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'GetMessagesResult(messages: ${messages.length}, hasMore: $hasMore, page: $page, limit: $limit, unreadCount: $unreadCount)';
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
