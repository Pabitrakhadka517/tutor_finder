import '../../../../core/utils/either.dart';
import '../../../../core/utils/unit.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/notification_entity.dart';
import '../failures/notification_failures.dart';
import '../repositories/notification_repository.dart';

/// Use case for retrieving notifications with pagination and filtering
///
/// This use case handles:
/// 1. Input validation for pagination parameters
/// 2. Fetching notifications for a specific recipient
/// 3. Filtering by read status and notification types
/// 4. Proper error handling and pagination logic
@injectable
class GetNotificationsUseCase {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  Future<Either<NotificationFailure, List<NotificationEntity>>> call(
    GetNotificationsParams params,
  ) async {
    // Validate pagination parameters
    if (params.page < 1) {
      return const Left(
        NotificationFailure.validationError(
          'Page number must be greater than 0',
        ),
      );
    }

    if (params.limit < 1 || params.limit > 100) {
      return const Left(
        NotificationFailure.validationError('Limit must be between 1 and 100'),
      );
    }

    // Validate recipient ID
    if (params.recipientId.trim().isEmpty) {
      return const Left(
        NotificationFailure.validationError('Recipient ID cannot be empty'),
      );
    }

    // Validate date range if provided
    if (params.fromDate != null && params.toDate != null) {
      if (params.fromDate!.isAfter(params.toDate!)) {
        return const Left(
          NotificationFailure.validationError(
            'From date cannot be after to date',
          ),
        );
      }
    }

    return _repository.getNotifications(
      params.recipientId,
      page: params.page,
      limit: params.limit,
      readStatus: params.readStatus,
      types: params.types,
      fromDate: params.fromDate,
      toDate: params.toDate,
    );
  }
}

class GetNotificationsParams {
  final String recipientId;
  final int page;
  final int limit;
  final bool? readStatus; // null = all, true = read only, false = unread only
  final List<String>? types;
  final DateTime? fromDate;
  final DateTime? toDate;

  const GetNotificationsParams({
    required this.recipientId,
    this.page = 1,
    this.limit = 20,
    this.readStatus,
    this.types,
    this.fromDate,
    this.toDate,
  });

  @override
  String toString() {
    return 'GetNotificationsParams('
        'recipientId: $recipientId, '
        'page: $page, '
        'limit: $limit, '
        'readStatus: $readStatus, '
        'types: $types, '
        'fromDate: $fromDate, '
        'toDate: $toDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GetNotificationsParams &&
        other.recipientId == recipientId &&
        other.page == page &&
        other.limit == limit &&
        other.readStatus == readStatus &&
        _listEquals(other.types, types) &&
        other.fromDate == fromDate &&
        other.toDate == toDate;
  }

  @override
  int get hashCode {
    return recipientId.hashCode ^
        page.hashCode ^
        limit.hashCode ^
        readStatus.hashCode ^
        types.hashCode ^
        fromDate.hashCode ^
        toDate.hashCode;
  }

  bool _listEquals(List<String>? list1, List<String>? list2) {
    if (list1 == null && list2 == null) return true;
    if (list1 == null || list2 == null) return false;
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
