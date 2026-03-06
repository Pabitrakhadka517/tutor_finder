import 'dart:async';

import '../../../../core/exceptions/network_exception.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/unit.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/failures/notification_failures.dart';
import '../../domain/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';
import '../datasources/notification_remote_datasource.dart';
import '../datasources/notification_websocket_datasource.dart';

/// Repository implementation bridging remote API, local cache, and WebSocket.
///
/// - Remote datasource: 5 REST endpoints (JWT-authenticated)
/// - Local datasource: SharedPreferences cache (optional, errors swallowed)
/// - WebSocket datasource: Real-time notification stream
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final NotificationLocalDataSource _localDataSource;
  final NotificationWebSocketDataSource _webSocketDataSource;

  late final StreamController<NotificationEntity> _realtimeController;

  NotificationRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._webSocketDataSource,
  ) {
    _realtimeController = StreamController<NotificationEntity>.broadcast();

    // Forward WebSocket notifications to the realtime stream
    _webSocketDataSource.notificationStream.listen((dto) {
      _realtimeController.add(dto.toEntity());
    });
  }

  @override
  Stream<NotificationEntity> get realtimeNotifications =>
      _realtimeController.stream;

  @override
  Future<void> connectWebSocket(String userId) async {
    await _webSocketDataSource.connect(userId);
  }

  @override
  Future<void> disconnectWebSocket() async {
    await _webSocketDataSource.disconnect();
  }

  // --------------- REST API Operations ---------------

  @override
  Future<Either<NotificationFailure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Try cache first
      final cacheKey = 'notifications-$page-$limit';
      try {
        final cached = await _localDataSource.getCachedNotifications(cacheKey);
        if (cached != null) {
          return Right(cached.map((d) => d.toEntity()).toList());
        }
      } catch (_) {
        // Cache miss or error - continue to network
      }

      // Fetch from network
      final pageDto = await _remoteDataSource.getNotifications(
        page: page,
        limit: limit,
      );

      // Cache the result (fire-and-forget)
      try {
        await _localDataSource.cacheNotifications(
          pageDto.notifications,
          cacheKey,
        );
      } catch (_) {}

      return Right(pageDto.notifications.map((d) => d.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(NotificationFailure.serverError('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<NotificationFailure, int>> getUnreadCount() async {
    try {
      final count = await _remoteDataSource.getUnreadCount();
      return Right(count);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(NotificationFailure.serverError('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> markAsRead(
    String notificationId,
  ) async {
    try {
      await _remoteDataSource.markAsRead(notificationId);

      // Update cache
      try {
        await _localDataSource.updateCachedNotificationReadStatus(
          notificationId,
          true,
        );
      } catch (_) {}

      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(NotificationFailure.serverError('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> markAllAsRead() async {
    try {
      await _remoteDataSource.markAllAsRead();

      // Clear cache since all statuses changed
      try {
        await _localDataSource.clearAllCache();
      } catch (_) {}

      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(NotificationFailure.serverError('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> deleteNotification(
    String notificationId,
  ) async {
    try {
      await _remoteDataSource.deleteNotification(notificationId);

      // Remove from cache
      try {
        await _localDataSource.removeCachedNotification(notificationId);
      } catch (_) {}

      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(NotificationFailure.serverError('Unexpected error: $e'));
    }
  }

  // --------------- Helpers ---------------

  NotificationFailure _mapNetworkException(NetworkException exception) {
    return exception.when(
      connectionError: () =>
          const NotificationFailure.connectionError('No internet connection'),
      timeoutError: () =>
          const NotificationFailure.timeoutError('Request timeout'),
      badRequest: (message) => NotificationFailure.validationError(message),
      unauthorizedError: () =>
          const NotificationFailure.unauthorizedError('User not authenticated'),
      forbiddenError: (message) => NotificationFailure.forbiddenError(message),
      notFound: (message) => NotificationFailure.notFoundError(message),
      conflictError: (message) => NotificationFailure.conflictError(message),
      validationError: (message) =>
          NotificationFailure.validationError(message),
      rateLimitError: () =>
          const NotificationFailure.serverError('Too many requests'),
      serverError: (message) => NotificationFailure.serverError(message),
      unknownError: (message) => NotificationFailure.unknownError(message),
    );
  }

  void dispose() {
    _webSocketDataSource.disconnect();
    _realtimeController.close();
  }
}
