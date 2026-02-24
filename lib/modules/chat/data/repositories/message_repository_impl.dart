import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/auth/auth_manager.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/enums/message_status.dart';
import '../../domain/failures/chat_failures.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../datasources/chat_local_datasource.dart';
import '../services/socket_service.dart';
import '../dtos/message_dto.dart';

/// Implementation of message repository.
/// Coordinating remote, local, and real-time data sources.
class MessageRepositoryImpl implements MessageRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;
  final SocketService socketService;
  final NetworkInfo networkInfo;
  final AuthManager authManager;
  final Uuid uuid;

  MessageRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.socketService,
    required this.networkInfo,
    required this.authManager,
    required this.uuid,
  });

  @override
  Future<Either<ChatFailure, MessageEntity>> createMessage({
    required String chatId,
    required String senderId,
    required String content,
    List<String>? attachments,
    String? replyToId,
  }) async {
    try {
      // Create message DTO with temporary ID for offline support
      final tempMessageId = uuid.v4();
      final messageDto = MessageDto.forCreation(
        chatId: chatId,
        senderId: senderId,
        content: content,
        attachments: attachments,
        replyToId: replyToId,
      ).copyWith(id: tempMessageId);

      final messageEntity = messageDto.toEntity();

      // If connected, send via Socket.IO and API
      if (await networkInfo.isConnected) {
        try {
          // Get auth token
          final authToken = await authManager.getToken();
          if (authToken == null) {
            // Save as offline message
            await localDataSource.saveOfflineMessage(messageDto);
            return Left(
              ChatFailure.unauthorized('Authentication token not found'),
            );
          }

          // Send via real-time socket first for immediate feedback
          if (socketService.isConnected) {
            socketService.sendMessage(messageDto);
          }

          // Create via API
          final createdMessageDto = await remoteDataSource.createMessage(
            chatId: chatId,
            senderId: senderId,
            content: content,
            attachments: attachments,
            replyToId: replyToId,
            authToken: authToken,
          );

          final createdMessageEntity = createdMessageDto.toEntity();

          // Cache the created message
          try {
            await localDataSource.cacheMessage(createdMessageDto);
          } catch (e) {
            // Log cache error but don't fail the operation
          }

          return Right(createdMessageEntity);
        } catch (e) {
          // Save as offline message if API fails
          await localDataSource.saveOfflineMessage(messageDto);

          if (e is UnauthorizedException) {
            return Left(ChatFailure.unauthorized('Invalid or expired token'));
          } else if (e is ValidationException) {
            return Left(ChatFailure.invalidInput(e.message));
          } else if (e is ServerException) {
            // Return the temporary message entity for offline use
            return Right(
              messageEntity.copyWith(
                status: MessageStatus
                    .sent, // Will be updated when connection restored
              ),
            );
          }

          rethrow;
        }
      } else {
        // Save offline message
        await localDataSource.saveOfflineMessage(messageDto);
        return Right(messageEntity);
      }
    } catch (e) {
      return Left(ChatFailure.serverError('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ChatFailure, MessageEntity>> getMessageById(
    String messageId,
  ) async {
    try {
      // Try to get from cache first
      try {
        final cachedMessage = await localDataSource.getCachedMessage(messageId);
        if (cachedMessage != null) {
          return Right(cachedMessage.toEntity());
        }
      } catch (e) {
        // Continue to remote if cache fails
      }

      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Left(ChatFailure.noConnection('No internet connection'));
      }

      // Get auth token
      final authToken = await authManager.getToken();
      if (authToken == null) {
        return Left(ChatFailure.unauthorized('Authentication token not found'));
      }

      // Get from remote
      final messageDto = await remoteDataSource.getMessageById(
        messageId,
        authToken,
      );
      final messageEntity = messageDto.toEntity();

      // Cache the result
      try {
        await localDataSource.cacheMessage(messageDto);
      } catch (e) {
        // Log cache error but don't fail the operation
      }

      return Right(messageEntity);
    } on UnauthorizedException {
      return Left(ChatFailure.unauthorized('Invalid or expired token'));
    } on NotFoundException catch (e) {
      return Left(ChatFailure.notFound(e.message));
    } on ServerException catch (e) {
      return Left(ChatFailure.serverError(e.message));
    } catch (e) {
      return Left(ChatFailure.serverError('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ChatFailure, List<MessageEntity>>> getMessagesForChat(
    String chatId, {
    int page = 1,
    int limit = 20,
    DateTime? before,
    DateTime? after,
  }) async {
    try {
      // Try cache first if no network
      if (!await networkInfo.isConnected) {
        try {
          final cachedMessages = await localDataSource.getCachedMessagesForChat(
            chatId,
            page: page,
            limit: limit,
          );
          final entities = cachedMessages.map((dto) => dto.toEntity()).toList();
          return Right(entities);
        } catch (e) {
          return Left(
            ChatFailure.noConnection(
              'No internet connection and cache unavailable',
            ),
          );
        }
      }

      // Get auth token
      final authToken = await authManager.getToken();
      if (authToken == null) {
        return Left(ChatFailure.unauthorized('Authentication token not found'));
      }

      // Get from remote
      final messagesDto = await remoteDataSource.getMessagesForChat(
        chatId,
        authToken,
        page: page,
        limit: limit,
        before: before,
        after: after,
      );

      final messagesEntities = messagesDto
          .map((dto) => dto.toEntity())
          .toList();

      // Cache the results
      try {
        await localDataSource.cacheMessages(messagesDto);
      } catch (e) {
        // Log cache error but don't fail the operation
      }

      return Right(messagesEntities);
    } on UnauthorizedException {
      return Left(ChatFailure.unauthorized('Invalid or expired token'));
    } on ServerException catch (e) {
      return Left(ChatFailure.serverError(e.message));
    } catch (e) {
      return Left(ChatFailure.serverError('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ChatFailure, void>> markMessagesAsRead(
    String chatId,
    String userId, {
    List<String>? messageIds,
  }) async {
    try {
      // Send real-time update via socket if connected
      if (socketService.isConnected && messageIds != null) {
        socketService.markMessagesAsRead(chatId, messageIds);
      }

      // Check network connectivity
      if (!await networkInfo.isConnected) {
        // Cache read status locally
        if (messageIds != null) {
          for (final messageId in messageIds) {
            try {
              await localDataSource.cacheMessageReadStatus(
                chatId,
                messageId,
                userId,
              );
            } catch (e) {
              // Continue with other messages if one fails
            }
          }
        }
        return const Right(null);
      }

      // Get auth token
      final authToken = await authManager.getToken();
      if (authToken == null) {
        return Left(ChatFailure.unauthorized('Authentication token not found'));
      }

      // Mark as read via API
      await remoteDataSource.markMessagesAsRead(
        chatId,
        userId,
        authToken,
        messageIds: messageIds,
      );

      // Cache read status
      if (messageIds != null) {
        for (final messageId in messageIds) {
          try {
            await localDataSource.cacheMessageReadStatus(
              chatId,
              messageId,
              userId,
            );
          } catch (e) {
            // Continue with other messages if one fails
          }
        }
      }

      return const Right(null);
    } on UnauthorizedException {
      return Left(ChatFailure.unauthorized('Invalid or expired token'));
    } on ServerException catch (e) {
      return Left(ChatFailure.serverError(e.message));
    } catch (e) {
      return Left(ChatFailure.serverError('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ChatFailure, int>> getUnreadMessageCount(
    String chatId,
    String userId,
  ) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return const Right(0); // Return 0 if offline
      }

      // Get auth token
      final authToken = await authManager.getToken();
      if (authToken == null) {
        return Left(ChatFailure.unauthorized('Authentication token not found'));
      }

      // Get unread count from remote
      final unreadCount = await remoteDataSource.getUnreadMessageCount(
        chatId,
        userId,
        authToken,
      );

      return Right(unreadCount);
    } on UnauthorizedException {
      return Left(ChatFailure.unauthorized('Invalid or expired token'));
    } on ServerException catch (e) {
      return Left(ChatFailure.serverError(e.message));
    } catch (e) {
      return Left(ChatFailure.serverError('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ChatFailure, int>> getTotalUnreadMessageCount(
    String userId,
  ) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return const Right(0); // Return 0 if offline
      }

      // Get auth token
      final authToken = await authManager.getToken();
      if (authToken == null) {
        return Left(ChatFailure.unauthorized('Authentication token not found'));
      }

      // Get total unread count from remote
      final totalUnreadCount = await remoteDataSource
          .getTotalUnreadMessageCount(userId, authToken);

      return Right(totalUnreadCount);
    } on UnauthorizedException {
      return Left(ChatFailure.unauthorized('Invalid or expired token'));
    } on ServerException catch (e) {
      return Left(ChatFailure.serverError(e.message));
    } catch (e) {
      return Left(ChatFailure.serverError('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ChatFailure, MessageEntity>> updateMessage(
    MessageEntity message,
  ) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Left(ChatFailure.noConnection('No internet connection'));
      }

      // Get auth token
      final authToken = await authManager.getToken();
      if (authToken == null) {
        return Left(ChatFailure.unauthorized('Authentication token not found'));
      }

      // Convert to DTO and update via API
      final messageDto = MessageDto.fromEntity(message);
      final updatedMessageDto = await remoteDataSource.updateMessage(
        messageDto,
        authToken,
      );

      final updatedMessageEntity = updatedMessageDto.toEntity();

      // Update cache
      try {
        await localDataSource.cacheMessage(updatedMessageDto);
      } catch (e) {
        // Log cache error but don't fail the operation
      }

      return Right(updatedMessageEntity);
    } on UnauthorizedException {
      return Left(ChatFailure.unauthorized('Invalid or expired token'));
    } on NotFoundException catch (e) {
      return Left(ChatFailure.notFound(e.message));
    } on ServerException catch (e) {
      return Left(ChatFailure.serverError(e.message));
    } catch (e) {
      return Left(ChatFailure.serverError('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ChatFailure, void>> deleteMessage(
    String messageId,
    String userId,
  ) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Left(ChatFailure.noConnection('No internet connection'));
      }

      // Get auth token
      final authToken = await authManager.getToken();
      if (authToken == null) {
        return Left(ChatFailure.unauthorized('Authentication token not found'));
      }

      // Delete via API
      await remoteDataSource.deleteMessage(messageId, userId, authToken);

      // Remove from cache
      try {
        await localDataSource.removeCachedMessage(messageId);
      } catch (e) {
        // Log cache error but don't fail the operation
      }

      return const Right(null);
    } on UnauthorizedException {
      return Left(ChatFailure.unauthorized('Invalid or expired token'));
    } on NotFoundException catch (e) {
      return Left(ChatFailure.notFound(e.message));
    } on ServerException catch (e) {
      return Left(ChatFailure.serverError(e.message));
    } catch (e) {
      return Left(ChatFailure.serverError('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ChatFailure, List<MessageEntity>>> searchMessages(
    String chatId,
    String query, {
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return Left(ChatFailure.noConnection('No internet connection'));
      }

      // Get auth token
      final authToken = await authManager.getToken();
      if (authToken == null) {
        return Left(ChatFailure.unauthorized('Authentication token not found'));
      }

      // Search via API
      final messagesDto = await remoteDataSource.searchMessages(
        chatId,
        query,
        authToken,
        limit: limit,
        fromDate: fromDate,
        toDate: toDate,
      );

      final messagesEntities = messagesDto
          .map((dto) => dto.toEntity())
          .toList();

      return Right(messagesEntities);
    } on UnauthorizedException {
      return Left(ChatFailure.unauthorized('Invalid or expired token'));
    } on ServerException catch (e) {
      return Left(ChatFailure.serverError(e.message));
    } catch (e) {
      return Left(ChatFailure.serverError('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ChatFailure, Map<String, dynamic>>> getMessageStats(
    String chatId,
  ) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return const Right({});
      }

      // Get auth token
      final authToken = await authManager.getToken();
      if (authToken == null) {
        return Left(ChatFailure.unauthorized('Authentication token not found'));
      }

      // Get stats from remote
      final stats = await remoteDataSource.getMessageStats(chatId, authToken);

      return Right(stats);
    } on UnauthorizedException {
      return Left(ChatFailure.unauthorized('Invalid or expired token'));
    } on ServerException catch (e) {
      return Left(ChatFailure.serverError(e.message));
    } catch (e) {
      return Left(ChatFailure.serverError('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ChatFailure, List<MessageEntity>>> getRecentMessages(
    String userId, {
    int limit = 10,
    Duration? within,
  }) async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return const Right([]);
      }

      // Get auth token
      final authToken = await authManager.getToken();
      if (authToken == null) {
        return Left(ChatFailure.unauthorized('Authentication token not found'));
      }

      // Get recent messages from remote
      final messagesDto = await remoteDataSource.getRecentMessages(
        userId,
        authToken,
        limit: limit,
        within: within,
      );

      final messagesEntities = messagesDto
          .map((dto) => dto.toEntity())
          .toList();

      return Right(messagesEntities);
    } on UnauthorizedException {
      return Left(ChatFailure.unauthorized('Invalid or expired token'));
    } on ServerException catch (e) {
      return Left(ChatFailure.serverError(e.message));
    } catch (e) {
      return Left(ChatFailure.serverError('Unexpected error: ${e.toString()}'));
    }
  }

  /// Sync offline messages when connection is restored.
  Future<void> syncOfflineMessages() async {
    try {
      if (!await networkInfo.isConnected) return;

      final offlineMessages = await localDataSource.getOfflineMessages();

      for (final messageDto in offlineMessages) {
        try {
          final result = await createMessage(
            chatId: messageDto.chatId,
            senderId: messageDto.senderId,
            content: messageDto.content,
            attachments: messageDto.attachments,
            replyToId: messageDto.replyToId,
          );

          // Remove offline message if successfully sent
          result.fold(
            (failure) {
              // Keep offline message if sync failed
            },
            (message) async {
              await localDataSource.removeOfflineMessage(messageDto.id);
            },
          );
        } catch (e) {
          // Continue with next message if one fails
        }
      }
    } catch (e) {
      // Log error but don't throw
    }
  }
}
