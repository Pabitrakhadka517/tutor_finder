import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/exceptions/network_exception.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/unit.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/failures/notification_failures.dart';
import '../../domain/notification_repository.dart';
import '../../domain/repositories/notification_repository.dart' show NotificationStats;
import '../../domain/value_objects/notification_type.dart';
import '../datasources/notification_local_datasource.dart';
import '../datasources/notification_remote_datasource.dart';
import '../datasources/notification_websocket_datasource.dart';
import '../dtos/notification_dto.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final NotificationLocalDataSource _localDataSource;
  final NotificationWebSocketDataSource _webSocketDataSource;

  late final StreamController<NotificationEntity> _notificationController;
  late final StreamController<String> _readController;
  late final StreamController<String> _deletedController;
  late final StreamController<int> _unreadCountController;

  NotificationRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._webSocketDataSource,
  ) {
    _notificationController = StreamController<NotificationEntity>.broadcast();
    _readController = StreamController<String>.broadcast();
    _deletedController = StreamController<String>.broadcast();
    _unreadCountController = StreamController<int>.broadcast();

    _webSocketDataSource.notificationStream.listen((dto) {
      _notificationController.add(dto.toEntity());
    });
    _webSocketDataSource.notificationReadStream.listen(_readController.add);
    _webSocketDataSource.notificationDeletedStream.listen(_deletedController.add);
    _webSocketDataSource.unreadCountStream.listen(_unreadCountController.add);
  }

  @override
  Stream<Either<NotificationFailure, NotificationEntity>> subscribeToNotifications(
    String userId,
  ) {
    return _notificationController.stream.map((e) => Right(e));
  }

  @override
  Future<bool> isConnected(String userId) async {
    try {
      return _webSocketDataSource.isConnected;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> reconnect(String userId) async {
    try {
      await _webSocketDataSource.connect(userId);
      return const Right(unit);
    } catch (e) {
      return Left(NotificationFailure.connectionError('Failed to reconnect: $e'));
    }
  }

  @override
  Future<Either<NotificationFailure, NotificationEntity>> createNotification(
    NotificationEntity notification,
  ) async {
    try {
      final dto = NotificationDto.fromEntity(notification);
      final createdDto = await _remoteDataSource.createNotification(dto);
      try { await _localDataSource.cacheNotification(createdDto); } catch (_) {}
      return Right(createdDto.toEntity());
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(NotificationFailure.serverError('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> updateNotification(
    NotificationEntity notification,
  ) async {
    // Stub: update via remote if supported
    return const Right(unit);
  }

  @override
  Future<Either<NotificationFailure, Unit>> deleteNotification(
    String notificationId,
    String userId,
  ) async {
    try {
      await _remoteDataSource.deleteNotification(notificationId, userId);
      try {
        await _localDataSource.removeCachedNotification(notificationId);
        await _localDataSource.removeCachedUnreadCount(userId);
      } catch (_) {}
      try { await _webSocketDataSource.emitDeleteNotification(notificationId); } catch (_) {}
      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(NotificationFailure.serverError('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<NotificationFailure, NotificationEntity>> getNotification(
    String notificationId,
    String userId,
  ) async {
    try {
      try {
        final cached = await _localDataSource.getCachedNotification(notificationId);
        if (cached != null) return Right(cached.toEntity());
      } catch (_) {}
      final dto = await _remoteDataSource.getNotification(notificationId, userId);
      try { await _localDataSource.cacheNotification(dto); } catch (_) {}
      return Right(dto.toEntity());
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(NotificationFailure.serverError('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<NotificationFailure, List<NotificationEntity>>> getNotifications(
    String recipientId, {
    int page = 1,
    int limit = 20,
    bool? readStatus,
    List<String>? types,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final cacheKey = _buildCacheKey(recipientId, page, limit, readStatus, types, fromDate, toDate);
      try {
        final cached = await _localDataSource.getCachedNotifications(cacheKey);
        if (cached != null) return Right(cached.map((d) => d.toEntity()).toList());
      } catch (_) {}
      final pageDto = await _remoteDataSource.getNotifications(
        recipientId,
        page: page,
        limit: limit,
        readStatus: readStatus,
        types: types,
        fromDate: fromDate,
        toDate: toDate,
      );
      try { await _localDataSource.cacheNotifications(pageDto.notifications, cacheKey); } catch (_) {}
      return Right(pageDto.notifications.map((d) => d.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(NotificationFailure.serverError('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<NotificationFailure, int>> getUnreadCount(String recipientId) async {
    try {
      try {
        final cached = await _localDataSource.getCachedUnreadCount(recipientId);
        if (cached != null) return Right(cached);
      } catch (_) {}
      final count = await _remoteDataSource.getUnreadCount(recipientId);
      try { await _localDataSource.cacheUnreadCount(recipientId, count); } catch (_) {}
      return Right(count);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(NotificationFailure.serverError('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<NotificationFailure, List<NotificationEntity>>> getRecentNotifications(
    String recipientId, {int limit = 10}
  ) async {
    try {
      final dtos = await _remoteDataSource.getRecentNotifications(recipientId, limit: limit);
      return Right(dtos.map((d) => d.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(NotificationFailure.serverError('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<NotificationFailure, List<NotificationEntity>>> searchNotifications(
    String recipientId,
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final pageDto = await _remoteDataSource.searchNotifications(recipientId, query, page: page, limit: limit);
      return Right(pageDto.notifications.map((d) => d.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(NotificationFailure.serverError('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> markAsRead(
    String notificationId,
    String userId,
  ) async {
    try {
      await _remoteDataSource.markAsRead(notificationId, userId);
      try {
        await _localDataSource.updateCachedNotificationReadStatus(notificationId, true);
        await _localDataSource.removeCachedUnreadCount(userId);
      } catch (_) {}
      try { await _webSocketDataSource.emitMarkAsRead(notificationId); } catch (_) {}
      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(NotificationFailure.serverError('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> markAllAsRead(String recipientId) async {
    try {
      await _remoteDataSource.markAllAsRead(recipientId);
      try { await _localDataSource.clearUserCache(recipientId); } catch (_) {}
      try { await _webSocketDataSource.emitMarkAllAsRead(); } catch (_) {}
      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(NotificationFailure.serverError('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> markMultipleAsRead(
    List<String> notificationIds,
    String userId,
  ) async {
    try {
      await _remoteDataSource.markMultipleAsRead(notificationIds, userId);
      try {
        for (final id in notificationIds) {
          await _localDataSource.updateCachedNotificationReadStatus(id, true);
        }
        await _localDataSource.removeCachedUnreadCount(userId);
      } catch (_) {}
      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(NotificationFailure.serverError('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> deleteMultiple(
    List<String> notificationIds,
    String userId,
  ) async {
    try {
      await _remoteDataSource.deleteMultiple(notificationIds, userId);
      try {
        for (final id in notificationIds) {
          await _localDataSource.removeCachedNotification(id);
        }
        await _localDataSource.removeCachedUnreadCount(userId);
      } catch (_) {}
      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(NotificationFailure.serverError('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> deleteAllRead(String recipientId) async {
    try {
      await _remoteDataSource.deleteAllRead(recipientId);
      try { await _localDataSource.clearUserCache(recipientId); } catch (_) {}
      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(NotificationFailure.serverError('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<NotificationFailure, int>> deleteOldNotifications(
    String recipientId,
    int daysOld,
  ) async {
    try {
      final count = await _remoteDataSource.deleteOldNotifications(recipientId, daysOld);
      try { await _localDataSource.clearUserCache(recipientId); } catch (_) {}
      return Right(count);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(NotificationFailure.serverError('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<NotificationFailure, NotificationStats>> getNotificationStats(
    String recipientId,
  ) async {
    // Stub implementation
    return Right(NotificationStats(
      totalNotifications: 0,
      unreadNotifications: 0,
      readNotifications: 0,
      notificationsToday: 0,
      notificationsThisWeek: 0,
      notificationsThisMonth: 0,
      typeDistribution: const {},
      averageNotificationsPerDay: 0,
    ));
  }

  @override
  Future<Either<NotificationFailure, Map<String, int>>> getNotificationCountsByType(
    String recipientId,
  ) async {
    return const Right({});
  }

  // Helpers
  String _buildCacheKey(
    String recipientId, int page, int limit,
    bool? readStatus, List<String>? types,
    DateTime? fromDate, DateTime? toDate,
  ) {
    final buffer = StringBuffer('$recipientId-$page-$limit');
    if (readStatus != null) buffer.write('-$readStatus');
    if (types != null) buffer.write('-${types.join(',')}');
    if (fromDate != null) buffer.write('-${fromDate.toIso8601String()}');
    if (toDate != null) buffer.write('-${toDate.toIso8601String()}');
    return buffer.toString();
  }

  NotificationFailure _mapNetworkException(NetworkException exception) {
    return exception.when(
      connectionError: () => const NotificationFailure.connectionError('No internet connection'),
      timeoutError: () => const NotificationFailure.timeoutError('Request timeout'),
      badRequest: (message) => NotificationFailure.validationError(message),
      unauthorizedError: () => const NotificationFailure.unauthorizedError('User not authenticated'),
      forbiddenError: (message) => NotificationFailure.forbiddenError(message),
      notFound: (message) => NotificationFailure.notFoundError(message),
      conflictError: (message) => NotificationFailure.conflictError(message),
      validationError: (message) => NotificationFailure.validationError(message),
      rateLimitError: () => const NotificationFailure.serverError('Too many requests'),
      serverError: (message) => NotificationFailure.serverError(message),
      unknownError: (message) => NotificationFailure.unknownError(message),
    );
  }

  void dispose() {
    _webSocketDataSource.disconnect();
    _notificationController.close();
    _readController.close();
    _deletedController.close();
    _unreadCountController.close();
  }
}