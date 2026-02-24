import '../../../core/utils/either.dart';
import '../../../core/error/failures.dart';
import 'entities/chat_entities.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatRoomEntity>>> getChats();

  Future<Either<Failure, ChatRoomEntity>> createChat(String targetUserId);

  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String chatId, {
    int page,
    int limit,
  });

  Future<Either<Failure, MessageEntity>> sendMessage(
    String chatId,
    String content,
  );

  Future<Either<Failure, void>> markAsRead(String chatId);
}
