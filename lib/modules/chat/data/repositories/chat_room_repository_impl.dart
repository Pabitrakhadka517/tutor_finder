import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/auth/auth_manager.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/failures/chat_failures.dart';
import '../../domain/repositories/chat_room_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../datasources/chat_local_datasource.dart';
import '../services/socket_service.dart';
import '../dtos/chat_room_dto.dart';

/// Implementation of chat room repository.
/// Coordinating remote, local, and real-time data sources.
class ChatRoomRepositoryImpl implements ChatRoomRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;
  final SocketService socketService;
  final NetworkInfo networkInfo;
  final AuthManager authManager;

  ChatRoomRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.socketService,
    required this.networkInfo,
    required this.authManager,
  });

  @override
  Future<Either<ChatFailure, ChatRoomEntity>> createChatRoom({
    required String studentId,
    required String tutorId,
    required String bookingId,
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

      // Create chat room via API
      final chatRoomDto = await remoteDataSource.createChatRoom(
        studentId: studentId,
        tutorId: tutorId,
        bookingId: bookingId,
        authToken: authToken,
      );

      final chatRoomEntity = chatRoomDto.toEntity();

      // Cache the created chat room
      try {
        await localDataSource.cacheChatRoom(chatRoomDto);
      } catch (e) {
        // Log cache error but don't fail the operation
      }

      return Right(chatRoomEntity);
    } on UnauthorizedException {
      return Left(ChatFailure.unauthorized('Invalid or expired token'));
    } on ValidationException catch (e) {
      return Left(ChatFailure.invalidInput(e.message));
    } on NotFoundException catch (e) {
      return Left(ChatFailure.notFound(e.message));
    } on ServerException catch (e) {
      return Left(ChatFailure.serverError(e.message));
    } catch (e) {
      return Left(ChatFailure.serverError('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ChatFailure, ChatRoomEntity>> getChatRoomById(
    String chatId,
  ) async {
    try {
      // Try to get from cache first
      try {
        final cachedChatRoom = await localDataSource.getCachedChatRoom(chatId);
        if (cachedChatRoom != null) {
          return Right(cachedChatRoom.toEntity());
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
      final chatRoomDto = await remoteDataSource.getChatRoomById(
        chatId,
        authToken,
      );
      final chatRoomEntity = chatRoomDto.toEntity();

      // Cache the result
      try {
        await localDataSource.cacheChatRoom(chatRoomDto);
      } catch (e) {
        // Log cache error but don't fail the operation
      }

      return Right(chatRoomEntity);
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
  Future<Either<ChatFailure, ChatRoomEntity?>> findChatRoomBetweenUsers(
    String studentId,
    String tutorId,
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

      // Find from remote
      final chatRoomDto = await remoteDataSource.findChatRoomBetweenUsers(
        studentId,
        tutorId,
        authToken,
      );

      if (chatRoomDto == null) {
        return const Right(null);
      }

      final chatRoomEntity = chatRoomDto.toEntity();

      // Cache the result
      try {
        await localDataSource.cacheChatRoom(chatRoomDto);
      } catch (e) {
        // Log cache error but don't fail the operation
      }

      return Right(chatRoomEntity);
    } on UnauthorizedException {
      return Left(ChatFailure.unauthorized('Invalid or expired token'));
    } on ServerException catch (e) {
      return Left(ChatFailure.serverError(e.message));
    } catch (e) {
      return Left(ChatFailure.serverError('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ChatFailure, ChatRoomEntity?>> findChatRoomByBooking(
    String bookingId,
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

      // Find from remote
      final chatRoomDto = await remoteDataSource.findChatRoomByBooking(
        bookingId,
        authToken,
      );

      if (chatRoomDto == null) {
        return const Right(null);
      }

      final chatRoomEntity = chatRoomDto.toEntity();

      // Cache the result
      try {
        await localDataSource.cacheChatRoom(chatRoomDto);
      } catch (e) {
        // Log cache error but don't fail the operation
      }

      return Right(chatRoomEntity);
    } on UnauthorizedException {
      return Left(ChatFailure.unauthorized('Invalid or expired token'));
    } on ServerException catch (e) {
      return Left(ChatFailure.serverError(e.message));
    } catch (e) {
      return Left(ChatFailure.serverError('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ChatFailure, List<ChatRoomEntity>>> getChatRoomsForUser(
    String userId, {
    bool? activeOnly,
    int? limit,
    int? offset,
  }) async {
    try {
      // Try cache first if no network
      if (!await networkInfo.isConnected) {
        try {
          final cachedChatRooms = await localDataSource.getCachedChatRooms(
            userId,
          );
          final entities = cachedChatRooms
              .map((dto) => dto.toEntity())
              .toList();
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
      final chatRoomsDto = await remoteDataSource.getChatRoomsForUser(
        userId,
        authToken,
        activeOnly: activeOnly,
        limit: limit,
        offset: offset,
      );

      final chatRoomsEntities = chatRoomsDto
          .map((dto) => dto.toEntity())
          .toList();

      // Cache the results
      try {
        for (final chatRoomDto in chatRoomsDto) {
          await localDataSource.cacheChatRoom(chatRoomDto);
        }
      } catch (e) {
        // Log cache error but don't fail the operation
      }

      return Right(chatRoomsEntities);
    } on UnauthorizedException {
      return Left(ChatFailure.unauthorized('Invalid or expired token'));
    } on ServerException catch (e) {
      return Left(ChatFailure.serverError(e.message));
    } catch (e) {
      return Left(ChatFailure.serverError('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ChatFailure, ChatRoomEntity>> updateChatRoom(
    ChatRoomEntity chatRoom,
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
      final chatRoomDto = ChatRoomDto.fromEntity(chatRoom);
      final updatedChatRoomDto = await remoteDataSource.updateChatRoom(
        chatRoomDto,
        authToken,
      );

      final updatedChatRoomEntity = updatedChatRoomDto.toEntity();

      // Update cache
      try {
        await localDataSource.cacheChatRoom(updatedChatRoomDto);
      } catch (e) {
        // Log cache error but don't fail the operation
      }

      return Right(updatedChatRoomEntity);
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
  Future<Either<ChatFailure, ChatRoomEntity>> updateLastMessage({
    required String chatId,
    required String lastMessage,
    required DateTime lastMessageAt,
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

      // Update via API
      final updatedChatRoomDto = await remoteDataSource.updateLastMessage(
        chatId: chatId,
        lastMessage: lastMessage,
        lastMessageAt: lastMessageAt,
        authToken: authToken,
      );

      final updatedChatRoomEntity = updatedChatRoomDto.toEntity();

      // Update cache
      try {
        await localDataSource.cacheChatRoom(updatedChatRoomDto);
      } catch (e) {
        // Log cache error but don't fail the operation
      }

      return Right(updatedChatRoomEntity);
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
  Future<Either<ChatFailure, ChatRoomEntity>> deactivateChatRoom(
    String chatId,
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

      // Deactivate via API
      await remoteDataSource.deactivateChatRoom(chatId, authToken);

      // Get updated chat room
      final updatedChatRoomDto = await remoteDataSource.getChatRoomById(
        chatId,
        authToken,
      );

      final updatedChatRoomEntity = updatedChatRoomDto.toEntity();

      // Update cache
      try {
        await localDataSource.cacheChatRoom(updatedChatRoomDto);
      } catch (e) {
        // Log cache error but don't fail the operation
      }

      return Right(updatedChatRoomEntity);
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
  Future<Either<ChatFailure, bool>> canUserAccessChatRoom(
    String userId,
    String chatId,
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

      // Check access via API
      final hasAccess = await remoteDataSource.canUserAccessChatRoom(
        userId,
        chatId,
        authToken,
      );

      return Right(hasAccess);
    } on UnauthorizedException {
      return Left(ChatFailure.unauthorized('Invalid or expired token'));
    } on ServerException catch (e) {
      return Left(ChatFailure.serverError(e.message));
    } catch (e) {
      return Left(ChatFailure.serverError('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ChatFailure, Map<String, dynamic>>> getChatRoomStats(
    String userId,
  ) async {
    try {
      // For now, return basic stats
      // This could be expanded to call a specific API endpoint
      final chatRoomsResult = await getChatRoomsForUser(userId);

      return chatRoomsResult.fold((failure) => Left(failure), (chatRooms) {
        final activeChatRooms = chatRooms.where((room) => room.isActive).length;
        final totalChatRooms = chatRooms.length;

        return Right({
          'total_chat_rooms': totalChatRooms,
          'active_chat_rooms': activeChatRooms,
          'inactive_chat_rooms': totalChatRooms - activeChatRooms,
        });
      });
    } catch (e) {
      return Left(ChatFailure.serverError('Unexpected error: ${e.toString()}'));
    }
  }
}
