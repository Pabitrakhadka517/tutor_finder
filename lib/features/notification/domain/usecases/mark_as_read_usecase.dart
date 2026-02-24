import '../../../../core/utils/either.dart';
import '../../../../core/utils/unit.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../failures/notification_failures.dart';
import '../repositories/notification_repository.dart';

/// Use case for marking a notification as read
///
/// This use case handles:
/// 1. Input validation for notification ID and user ownership
/// 2. Marking notification as read
/// 3. Ownership validation
/// 4. Proper error handling
@injectable
class MarkAsReadUseCase {
  final NotificationRepository _repository;

  MarkAsReadUseCase(this._repository);

  Future<Either<NotificationFailure, Unit>> call(
    MarkAsReadParams params,
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

    return _repository.markAsRead(params.notificationId, params.userId);
  }
}

class MarkAsReadParams {
  final String notificationId;
  final String userId;

  const MarkAsReadParams({required this.notificationId, required this.userId});

  @override
  String toString() {
    return 'MarkAsReadParams(notificationId: $notificationId, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MarkAsReadParams &&
        other.notificationId == notificationId &&
        other.userId == userId;
  }

  @override
  int get hashCode => notificationId.hashCode ^ userId.hashCode;
}
