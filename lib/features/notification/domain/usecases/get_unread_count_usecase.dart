import '../../../../core/utils/either.dart';
import '../../../../core/utils/unit.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../failures/notification_failures.dart';
import '../repositories/notification_repository.dart';

/// Use case for getting the count of unread notifications
///
/// This use case handles:
/// 1. Input validation for recipient ID
/// 2. Retrieving unread notification count
/// 3. Proper error handling
@injectable
class GetUnreadCountUseCase {
  final NotificationRepository _repository;

  GetUnreadCountUseCase(this._repository);

  Future<Either<NotificationFailure, int>> call(
    GetUnreadCountParams params,
  ) async {
    // Validate recipient ID
    if (params.recipientId.trim().isEmpty) {
      return const Left(
        NotificationFailure.validationError('Recipient ID cannot be empty'),
      );
    }

    return _repository.getUnreadCount(params.recipientId);
  }
}

class GetUnreadCountParams {
  final String recipientId;

  const GetUnreadCountParams({required this.recipientId});

  @override
  String toString() {
    return 'GetUnreadCountParams(recipientId: $recipientId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GetUnreadCountParams && other.recipientId == recipientId;
  }

  @override
  int get hashCode => recipientId.hashCode;
}
