import 'package:dartz/dartz.dart';

import '../entities/chat_room_entity.dart';
import '../failures/chat_failures.dart';

/// Repository interface for chat room operations.
/// Defines contracts for all chat room data operations.
abstract class ChatRoomRepository {
  /// Create a new chat room
  Future<Either<ChatFailure, ChatRoomEntity>> createChatRoom({
    required String studentId,
    required String tutorId,
    required String bookingId,
  });

  /// Get chat room by ID
  Future<Either<ChatFailure, ChatRoomEntity>> getChatRoomById(String chatId);

  /// Find existing chat room between two users
  Future<Either<ChatFailure, ChatRoomEntity?>> findChatRoomBetweenUsers(
    String studentId,
    String tutorId,
  );

  /// Find chat room by booking ID
  Future<Either<ChatFailure, ChatRoomEntity?>> findChatRoomByBooking(
    String bookingId,
  );

  /// Get all chat rooms for a user
  Future<Either<ChatFailure, List<ChatRoomEntity>>> getChatRoomsForUser(
    String userId, {
    bool? activeOnly,
    int? limit,
    int? offset,
  });

  /// Update chat room
  Future<Either<ChatFailure, ChatRoomEntity>> updateChatRoom(
    ChatRoomEntity chatRoom,
  );

  /// Update last message information
  Future<Either<ChatFailure, ChatRoomEntity>> updateLastMessage({
    required String chatId,
    required String lastMessage,
    required DateTime lastMessageAt,
  });

  /// Deactivate chat room
  Future<Either<ChatFailure, ChatRoomEntity>> deactivateChatRoom(String chatId);

  /// Check if user has access to chat room
  Future<Either<ChatFailure, bool>> canUserAccessChatRoom(
    String userId,
    String chatId,
  );

  /// Get chat room statistics for user
  Future<Either<ChatFailure, Map<String, dynamic>>> getChatRoomStats(
    String userId,
  );
}
