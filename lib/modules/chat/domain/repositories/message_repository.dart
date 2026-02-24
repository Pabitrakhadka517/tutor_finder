import 'package:dartz/dartz.dart';

import '../entities/message_entity.dart';
import '../failures/chat_failures.dart';

/// Repository interface for message operations.
/// Defines contracts for all message data operations.
abstract class MessageRepository {
  /// Create a new message
  Future<Either<ChatFailure, MessageEntity>> createMessage({
    required String chatId,
    required String senderId,
    required String content,
    List<String>? attachments,
    String? replyToId,
  });

  /// Get message by ID
  Future<Either<ChatFailure, MessageEntity>> getMessageById(String messageId);

  /// Get messages for a chat room (paginated)
  Future<Either<ChatFailure, List<MessageEntity>>> getMessagesForChat(
    String chatId, {
    int page = 1,
    int limit = 20,
    DateTime? before,
    DateTime? after,
  });

  /// Mark messages as read by user
  Future<Either<ChatFailure, void>> markMessagesAsRead(
    String chatId,
    String userId, {
    List<String>? messageIds, // If null, marks all unread messages
  });

  /// Get unread message count for user in chat
  Future<Either<ChatFailure, int>> getUnreadMessageCount(
    String chatId,
    String userId,
  );

  /// Get unread message count across all chats for user
  Future<Either<ChatFailure, int>> getTotalUnreadMessageCount(String userId);

  /// Update message content (for editing)
  Future<Either<ChatFailure, MessageEntity>> updateMessage(
    MessageEntity message,
  );

  /// Delete message
  Future<Either<ChatFailure, void>> deleteMessage(
    String messageId,
    String userId, // Only sender can delete
  );

  /// Search messages in chat
  Future<Either<ChatFailure, List<MessageEntity>>> searchMessages(
    String chatId,
    String query, {
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Get message statistics for chat
  Future<Either<ChatFailure, Map<String, dynamic>>> getMessageStats(
    String chatId,
  );

  /// Get recent messages across all user's chats (for notifications)
  Future<Either<ChatFailure, List<MessageEntity>>> getRecentMessages(
    String userId, {
    int limit = 10,
    Duration? within,
  });
}
