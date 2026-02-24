import '../../../../core/utils/either.dart';
import '../../../../core/utils/unit.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../failures/notification_failures.dart';
import '../repositories/notification_repository.dart';

/// Use case for marking all notifications as read for a specific recipient
///
/// This use case handles:
/// 1. Input validation for recipient ID
/// 2. Bulk update of all notifications to read status
/// 3. Proper error handling
@injectable
class MarkAllReadUseCase {
  final NotificationRepository _repository;

  MarkAllReadUseCase(this._repository);

  Future<Either<NotificationFailure, Unit>> call(
    MarkAllReadParams params,
  ) async {
    // Validate recipient ID
    if (params.recipientId.trim().isEmpty) {
      return const Left(
        NotificationFailure.validationError('Recipient ID cannot be empty'),
      );
    }

    return _repository.markAllAsRead(params.recipientId);
  }
}

class MarkAllReadParams {
  final String recipientId;

  const MarkAllReadParams({required this.recipientId});

  @override
  String toString() {
    return 'MarkAllReadParams(recipientId: $recipientId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MarkAllReadParams && other.recipientId == recipientId;
  }

  @override
  int get hashCode => recipientId.hashCode;
}
