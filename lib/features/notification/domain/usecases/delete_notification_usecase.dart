import '../../../../core/utils/either.dart';
import '../../../../core/utils/unit.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../failures/notification_failures.dart';
import '../repositories/notification_repository.dart';

/// Use case for deleting a notification
///
/// This use case handles:
/// 1. Input validation for notification ID and user ownership
/// 2. Notification deletion
/// 3. Ownership validation
/// 4. Proper error handling
@injectable
class DeleteNotificationUseCase {
  final NotificationRepository _repository;

  DeleteNotificationUseCase(this._repository);

  Future<Either<NotificationFailure, Unit>> call(
    DeleteNotificationParams params,
  ) async {
    // Validate notification ID
    if (params.notificationId.trim().isEmpty) {
      return const Left(
        NotificationFailure.validationError('Notification ID cannot be empty'),
      );
    }

    // Validate user ID
    if (params.userId.trim().isEmpty) {
      return const Left(
        NotificationFailure.validationError('User ID cannot be empty'),
      );
    }

    return _repository.deleteNotification(params.notificationId, params.userId);
  }
}

class DeleteNotificationParams {
  final String notificationId;
  final String userId;

  const DeleteNotificationParams({
    required this.notificationId,
    required this.userId,
  });

  @override
  String toString() {
    return 'DeleteNotificationParams(notificationId: $notificationId, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeleteNotificationParams &&
        other.notificationId == notificationId &&
        other.userId == userId;
  }

  @override
  int get hashCode => notificationId.hashCode ^ userId.hashCode;
}
