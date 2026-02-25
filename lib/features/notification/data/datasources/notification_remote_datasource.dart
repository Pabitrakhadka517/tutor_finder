import 'package:dio/dio.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/exceptions/network_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../dtos/notification_dto.dart';

/// Remote data source interface for notifications.
///
/// Maps directly to the 5 backend endpoints:
///   GET    /api/notifications           -> getNotifications
///   GET    /api/notifications/unread-count -> getUnreadCount
///   PATCH  /api/notifications/:id/read  -> markAsRead
///   PATCH  /api/notifications/read-all  -> markAllAsRead
///   DELETE /api/notifications/:id       -> deleteNotification
///
/// All endpoints are JWT-authenticated; the backend extracts the userId
/// from the token. No recipientId or userId query params are needed.
abstract class NotificationRemoteDataSource {
  Future<NotificationPageDto> getNotifications({int page, int limit});
  Future<int> getUnreadCount();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient _dioClient;

  NotificationRemoteDataSourceImpl(this._dioClient);

  /// GET /api/notifications?page=1&limit=20
  ///
  /// Backend response: { notifications: [...], total, page, unreadCount }
  @override
  Future<NotificationPageDto> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.notifications,
        queryParameters: {'page': page, 'limit': limit},
      );

      return NotificationPageDto.fromJson(
        response.data as Map<String, dynamic>,
        requestedLimit: limit,
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get notifications');
    }
  }

  /// GET /api/notifications/unread-count
  ///
  /// Backend response: { count: 3 }
  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.unreadCount);
      return (response.data['count'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get unread count');
    }
  }

  /// PATCH /api/notifications/:id/read
  ///
  /// Backend response: { success: true, notification: {...} }
  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _dioClient.patch(
        ApiEndpoints.markNotificationRead(notificationId),
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to mark notification as read');
    }
  }

  /// PATCH /api/notifications/read-all
  ///
  /// Backend response: { success: true, message: "All notifications marked as read" }
  @override
  Future<void> markAllAsRead() async {
    try {
      await _dioClient.patch(ApiEndpoints.markAllRead);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to mark all notifications as read');
    }
  }

  /// DELETE /api/notifications/:id
  ///
  /// Backend response: { success: true, message: "Notification deleted" }
  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _dioClient.delete(
        ApiEndpoints.deleteNotification(notificationId),
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to delete notification');
    }
  }

  // --------------- Error Handling ---------------

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
        final message =
            e.response?.data?['message']?.toString() ?? defaultMessage;
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
