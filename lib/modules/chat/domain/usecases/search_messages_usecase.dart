import 'package:dartz/dartz.dart';

import '../entities/message_entity.dart';
import '../failures/chat_failures.dart';
import '../repositories/chat_room_repository.dart';
import '../repositories/message_repository.dart';

/// Use case for searching messages in a chat room.
/// Handles access control and message search functionality.
class SearchMessagesUseCase {
  final MessageRepository _messageRepository;
  final ChatRoomRepository _chatRoomRepository;

  SearchMessagesUseCase(this._messageRepository, this._chatRoomRepository);

  /// Search for messages in a chat room.
  /// Validates access and performs text search.
  Future<Either<ChatFailure, List<MessageEntity>>> call(
    SearchMessagesParams params,
  ) async {
    // Validate search query
    if (params.query.trim().isEmpty) {
      return Left(ChatFailure.invalidInput('Search query cannot be empty'));
    }

    if (params.query.trim().length < 2) {
      return Left(
        ChatFailure.invalidInput(
          'Search query must be at least 2 characters long',
        ),
      );
    }

    // Validate limit
    if (params.limit != null && (params.limit! < 1 || params.limit! > 100)) {
      return Left(ChatFailure.invalidInput('Limit must be between 1 and 100'));
    }

    // Validate date range
    if (params.fromDate != null &&
        params.toDate != null &&
        params.fromDate!.isAfter(params.toDate!)) {
      return Left(ChatFailure.invalidInput('From date must be before to date'));
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

    // Perform search
    return await _messageRepository.searchMessages(
      params.chatId,
      params.query.trim(),
      limit: params.limit,
      fromDate: params.fromDate,
      toDate: params.toDate,
    );
  }
}

/// Parameters for searching messages
class SearchMessagesParams {
  final String chatId;
  final String userId;
  final String query;
  final int? limit;
  final DateTime? fromDate;
  final DateTime? toDate;

  SearchMessagesParams({
    required this.chatId,
    required this.userId,
    required this.query,
    this.limit,
    this.fromDate,
    this.toDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchMessagesParams &&
        other.chatId == chatId &&
        other.userId == userId &&
        other.query == query &&
        other.limit == limit &&
        other.fromDate == fromDate &&
        other.toDate == toDate;
  }

  @override
  int get hashCode {
    return chatId.hashCode ^
        userId.hashCode ^
        query.hashCode ^
        (limit?.hashCode ?? 0) ^
        (fromDate?.hashCode ?? 0) ^
        (toDate?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'SearchMessagesParams(chatId: $chatId, userId: $userId, query: "$query", limit: $limit, fromDate: $fromDate, toDate: $toDate)';
  }
}
