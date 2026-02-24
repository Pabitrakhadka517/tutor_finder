import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/exceptions/network_exception.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../dtos/notification_dto.dart';
import '../../domain/repositories/notification_repository.dart';

abstract class NotificationRemoteDataSource {
  // Core CRUD Operations
  Future<NotificationDto> createNotification(NotificationDto notificationDto);
  Future<void> updateNotification(String id, NotificationDto notificationDto);
  Future<void> deleteNotification(String id, String userId);
  Future<NotificationDto> getNotification(String id, String userId);

  // Query Operations
  Future<NotificationPageDto> getNotifications(
    String recipientId, {
    int page = 1,
    int limit = 20,
    bool? readStatus,
    List<String>? types,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<int> getUnreadCount(String recipientId);
  Future<List<NotificationDto>> getRecentNotifications(
    String recipientId, {
    int limit = 10,
  });
  Future<NotificationPageDto> searchNotifications(
    String recipientId,
    String query, {
    int page = 1,
    int limit = 20,
  });

  // Bulk Operations
  Future<void> markAsRead(String notificationId, String userId);
  Future<void> markAllAsRead(String recipientId);
  Future<void> markMultipleAsRead(List<String> notificationIds, String userId);
  Future<void> deleteMultiple(List<String> notificationIds, String userId);
  Future<void> deleteAllRead(String recipientId);
  Future<int> deleteOldNotifications(String recipientId, int daysOld);

  // Statistics
  Future<NotificationStatsDto> getNotificationStats(String recipientId);
  Future<Map<String, int>> getNotificationCountsByType(String recipientId);
}

@LazySingleton(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient _dioClient;

  NotificationRemoteDataSourceImpl(this._dioClient);

  @override
  Future<NotificationDto> createNotification(
    NotificationDto notificationDto,
  ) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.createNotification,
        data: notificationDto.toJson(),
      );

      return NotificationDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to create notification');
    }
  }

  @override
  Future<void> updateNotification(
    String id,
    NotificationDto notificationDto,
  ) async {
    try {
      await _dioClient.put(
        ApiEndpoints.getNotification.replaceFirst('{id}', id),
        data: notificationDto.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to update notification');
    }
  }

  @override
  Future<void> deleteNotification(String id, String userId) async {
    try {
      await _dioClient.delete(
        ApiEndpoints.deleteNotification.replaceFirst('{id}', id),
        queryParameters: {'userId': userId},
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to delete notification');
    }
  }

  @override
  Future<NotificationDto> getNotification(String id, String userId) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.getNotification.replaceFirst('{id}', id),
        queryParameters: {'userId': userId},
      );

      return NotificationDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get notification');
    }
  }

  @override
  Future<NotificationPageDto> getNotifications(
    String recipientId, {
    int page = 1,
    int limit = 20,
    bool? readStatus,
    List<String>? types,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'recipientId': recipientId,
        'page': page,
        'limit': limit,
      };

      if (readStatus != null) queryParams['read'] = readStatus;
      if (types != null && types.isNotEmpty)
        queryParams['types'] = types.join(',');
      if (fromDate != null)
        queryParams['fromDate'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['toDate'] = toDate.toIso8601String();

      final response = await _dioClient.get(
        ApiEndpoints.getNotifications,
        queryParameters: queryParams,
      );

      return NotificationPageDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get notifications');
    }
  }

  @override
  Future<int> getUnreadCount(String recipientId) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.getNotificationsUnreadCount,
        queryParameters: {'recipientId': recipientId},
      );

      return response.data['count'] ?? 0;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get unread count');
    }
  }

  @override
  Future<List<NotificationDto>> getRecentNotifications(
    String recipientId, {
    int limit = 10,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.getRecentNotifications,
        queryParameters: {'recipientId': recipientId, 'limit': limit},
      );

      final List<dynamic> data = response.data['notifications'] ?? [];
      return data.map((json) => NotificationDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get recent notifications');
    }
  }

  @override
  Future<NotificationPageDto> searchNotifications(
    String recipientId,
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.searchNotifications,
        queryParameters: {
          'recipientId': recipientId,
          'q': query,
          'page': page,
          'limit': limit,
        },
      );

      return NotificationPageDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to search notifications');
    }
  }

  @override
  Future<void> markAsRead(String notificationId, String userId) async {
    try {
      await _dioClient.put(
        ApiEndpoints.markAsRead.replaceFirst('{id}', notificationId),
        data: {'userId': userId},
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to mark notification as read');
    }
  }

  @override
  Future<void> markAllAsRead(String recipientId) async {
    try {
      await _dioClient.put(
        ApiEndpoints.markAllRead,
        data: {'recipientId': recipientId},
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to mark all notifications as read');
    }
  }

  @override
  Future<void> markMultipleAsRead(
    List<String> notificationIds,
    String userId,
  ) async {
    try {
      await _dioClient.put(
        ApiEndpoints.markMultipleAsRead,
        data: {'notificationIds': notificationIds, 'userId': userId},
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to mark multiple notifications as read');
    }
  }

  @override
  Future<void> deleteMultiple(
    List<String> notificationIds,
    String userId,
  ) async {
    try {
      await _dioClient.delete(
        ApiEndpoints.deleteMultipleNotifications,
        data: {'notificationIds': notificationIds, 'userId': userId},
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to delete multiple notifications');
    }
  }

  @override
  Future<void> deleteAllRead(String recipientId) async {
    try {
      await _dioClient.delete(
        ApiEndpoints.deleteAllRead,
        queryParameters: {'recipientId': recipientId},
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to delete all read notifications');
    }
  }

  @override
  Future<int> deleteOldNotifications(String recipientId, int daysOld) async {
    try {
      final response = await _dioClient.delete(
        ApiEndpoints.deleteOldNotifications,
        queryParameters: {'recipientId': recipientId, 'daysOld': daysOld},
      );

      return response.data['deletedCount'] ?? 0;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to delete old notifications');
    }
  }

  @override
  Future<NotificationStatsDto> getNotificationStats(String recipientId) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.getNotificationStats,
        queryParameters: {'recipientId': recipientId},
      );

      return NotificationStatsDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get notification stats');
    }
  }

  @override
  Future<Map<String, int>> getNotificationCountsByType(
    String recipientId,
  ) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.getNotificationsByType.replaceFirst('{type}', 'counts'),
        queryParameters: {'recipientId': recipientId},
      );

      final Map<String, dynamic> data = response.data['counts'] ?? {};
      return data.cast<String, int>();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get notification counts by type');
    }
  }

  NetworkException _handleError(DioException e, String defaultMessage) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return const NetworkException.connectionError();
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionTimeout:
        return const NetworkException.timeoutError();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final message = e.response?.data?['message'] ?? defaultMessage;

        switch (statusCode) {
          case 400:
            return NetworkException.badRequest(message);
          case 401:
            return const NetworkException.unauthorizedError();
          case 403:
            return NetworkException.forbiddenError(message);
          case 404:
            return NetworkException.notFound(message);
          case 409:
            return NetworkException.conflictError(message);
          case 422:
            return NetworkException.validationError(message);
          case 429:
            return const NetworkException.rateLimitError();
          case 500:
            return NetworkException.serverError(message);
          default:
            return NetworkException.unknownError(message);
        }
      default:
        return NetworkException.unknownError(defaultMessage);
    }
  }
}
