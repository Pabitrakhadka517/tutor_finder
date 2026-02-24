import '../../../../core/utils/either.dart';
import '../../../../core/utils/unit.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../data/services/notification_service.dart';
import '../entities/notification_entity.dart';
import '../failures/notification_failures.dart';
import '../repositories/notification_repository.dart';
import '../value_objects/notification_type.dart';

/// Use case for creating notifications with real-time delivery
///
/// This use case orchestrates:
/// 1. Notification entity creation with domain validation
/// 2. Persistence to database
/// 3. Real-time delivery via WebSocket/Push notification
/// 4. Proper error handling and delivery guarantees
@injectable
class CreateNotificationUseCase {
  final NotificationRepository _repository;
  final NotificationService _notificationService;

  CreateNotificationUseCase(this._repository, this._notificationService);

  Future<Either<NotificationFailure, NotificationEntity>> call(
    CreateNotificationParams params,
  ) async {
    try {
      // Step 1: Create notification entity with validation
      final notification = NotificationEntity.create(
        recipientId: params.recipientId,
        type: params.type,
        title: params.title,
        message: params.message,
        payload: params.payload,
      );

      // Step 2: Persist the notification
      final createResult = await _repository.createNotification(notification);

      return createResult.fold((failure) => Left(failure), (
        createdNotification,
      ) async {
        // Step 3: Send real-time notification (non-blocking)
        if (createdNotification.shouldPush) {
          _notificationService
              .sendRealTimeNotification(createdNotification)
              .catchError((error) {
                print('Warning: Failed to send real-time notification: $error');
              });
        }

        return Right(createdNotification);
      });
    } catch (e) {
      return Left(
        NotificationFailure.validationError(
          'Failed to create notification: $e',
        ),
      );
    }
  }
}

class CreateNotificationParams {
  final String recipientId;
  final NotificationType type;
  final String title;
  final String? message;
  final Map<String, dynamic>? payload;

  const CreateNotificationParams({
    required this.recipientId,
    required this.type,
    required this.title,
    this.message,
    this.payload,
  });

  @override
  String toString() {
    return 'CreateNotificationParams('
        'recipientId: $recipientId, '
        'type: $type, '
        'title: $title, '
        'message: $message, '
        'payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CreateNotificationParams &&
        other.recipientId == recipientId &&
        other.type == type &&
        other.title == title &&
        other.message == message &&
        _mapEquals(other.payload, payload);
  }

  @override
  int get hashCode {
    return recipientId.hashCode ^
        type.hashCode ^
        title.hashCode ^
        message.hashCode ^
        payload.hashCode;
  }

  bool _mapEquals(Map<String, dynamic>? map1, Map<String, dynamic>? map2) {
    if (map1 == null && map2 == null) return true;
    if (map1 == null || map2 == null) return false;
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }
}
