import 'package:dartz/dartz.dart';

import '../entities/chat_room_entity.dart';
import '../failures/chat_failures.dart';
import '../repositories/chat_room_repository.dart';
import '../repositories/message_repository.dart';

/// Use case for getting user's chat rooms.
/// Handles chat room listing with pagination and unread counts.
class GetChatRoomsUseCase {
  final ChatRoomRepository _chatRoomRepository;
  final MessageRepository _messageRepository;

  GetChatRoomsUseCase(this._chatRoomRepository, this._messageRepository);

  /// Get chat rooms for a user with optional filtering and pagination.
  Future<Either<ChatFailure, GetChatRoomsResult>> call(
    GetChatRoomsParams params,
  ) async {
    // Validate pagination parameters
    if (params.limit != null && (params.limit! < 1 || params.limit! > 100)) {
      return Left(ChatFailure.invalidInput('Limit must be between 1 and 100'));
    }

    if (params.offset != null && params.offset! < 0) {
      return Left(
        ChatFailure.invalidInput('Offset must be greater than or equal to 0'),
      );
    }

    // Get chat rooms from repository
    final chatRoomsResult = await _chatRoomRepository.getChatRoomsForUser(
      params.userId,
      activeOnly: params.activeOnly,
      limit: params.limit,
      offset: params.offset,
    );

    if (chatRoomsResult.isLeft()) {
      return chatRoomsResult.map(
        (_) => GetChatRoomsResult(
          chatRooms: [],
          totalUnreadCount: 0,
          hasMore: false,
        ),
      );
    }

    final chatRooms = chatRoomsResult.getOrElse(() => []);

    // Get total unread count for user if requested
    int totalUnreadCount = 0;
    if (params.includeUnreadCount) {
      final unreadResult = await _messageRepository.getTotalUnreadMessageCount(
        params.userId,
      );
      totalUnreadCount = unreadResult.getOrElse(() => 0);
    }

    // Get individual unread counts for each chat if requested
    List<ChatRoomWithUnreadCount> chatRoomsWithUnread = [];

    if (params.includeUnreadCount) {
      for (final chatRoom in chatRooms) {
        final unreadResult = await _messageRepository.getUnreadMessageCount(
          chatRoom.id,
          params.userId,
        );
        final unreadCount = unreadResult.getOrElse(() => 0);

        chatRoomsWithUnread.add(
          ChatRoomWithUnreadCount(chatRoom: chatRoom, unreadCount: unreadCount),
        );
      }
    } else {
      chatRoomsWithUnread = chatRooms
          .map(
            (chatRoom) =>
                ChatRoomWithUnreadCount(chatRoom: chatRoom, unreadCount: 0),
          )
          .toList();
    }

    return Right(
      GetChatRoomsResult(
        chatRoomsWithUnread: chatRoomsWithUnread,
        chatRooms: chatRooms,
        totalUnreadCount: totalUnreadCount,
        hasMore: params.limit != null && chatRooms.length == params.limit!,
      ),
    );
  }
}

/// Parameters for getting chat rooms
class GetChatRoomsParams {
  final String userId;
  final bool? activeOnly;
  final int? limit;
  final int? offset;
  final bool includeUnreadCount;

  GetChatRoomsParams({
    required this.userId,
    this.activeOnly,
    this.limit,
    this.offset,
    this.includeUnreadCount = true,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetChatRoomsParams &&
        other.userId == userId &&
        other.activeOnly == activeOnly &&
        other.limit == limit &&
        other.offset == offset &&
        other.includeUnreadCount == includeUnreadCount;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        (activeOnly?.hashCode ?? 0) ^
        (limit?.hashCode ?? 0) ^
        (offset?.hashCode ?? 0) ^
        includeUnreadCount.hashCode;
  }

  @override
  String toString() {
    return 'GetChatRoomsParams(userId: $userId, activeOnly: $activeOnly, limit: $limit, offset: $offset, includeUnreadCount: $includeUnreadCount)';
  }
}

/// Chat room with unread count information
class ChatRoomWithUnreadCount {
  final ChatRoomEntity chatRoom;
  final int unreadCount;

  ChatRoomWithUnreadCount({required this.chatRoom, required this.unreadCount});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatRoomWithUnreadCount &&
        other.chatRoom == chatRoom &&
        other.unreadCount == unreadCount;
  }

  @override
  int get hashCode => chatRoom.hashCode ^ unreadCount.hashCode;

  @override
  String toString() {
    return 'ChatRoomWithUnreadCount(chatRoom: ${chatRoom.id}, unreadCount: $unreadCount)';
  }
}

/// Result from getting chat rooms
class GetChatRoomsResult {
  final List<ChatRoomWithUnreadCount> chatRoomsWithUnread;
  final List<ChatRoomEntity> chatRooms;
  final int totalUnreadCount;
  final bool hasMore;

  GetChatRoomsResult({
    List<ChatRoomWithUnreadCount>? chatRoomsWithUnread,
    required this.chatRooms,
    required this.totalUnreadCount,
    required this.hasMore,
  }) : chatRoomsWithUnread = chatRoomsWithUnread ?? [];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetChatRoomsResult &&
        _listEquals(other.chatRoomsWithUnread, chatRoomsWithUnread) &&
        _listEquals(other.chatRooms, chatRooms) &&
        other.totalUnreadCount == totalUnreadCount &&
        other.hasMore == hasMore;
  }

  @override
  int get hashCode {
    return chatRoomsWithUnread.hashCode ^
        chatRooms.hashCode ^
        totalUnreadCount.hashCode ^
        hasMore.hashCode;
  }

  @override
  String toString() {
    return 'GetChatRoomsResult(chatRooms: ${chatRooms.length}, totalUnreadCount: $totalUnreadCount, hasMore: $hasMore)';
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
