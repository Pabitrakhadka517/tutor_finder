import 'notification_entity.dart';

/// Represents a page of notifications with pagination metadata
class NotificationPage {
  final List<NotificationEntity> notifications;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int limit;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const NotificationPage({
    required this.notifications,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.limit,
  }) : hasNextPage = currentPage < totalPages,
       hasPreviousPage = currentPage > 1;

  /// Creates an empty notification page
  const NotificationPage.empty()
    : notifications = const [],
      currentPage = 1,
      totalPages = 0,
      totalCount = 0,
      limit = 0,
      hasNextPage = false,
      hasPreviousPage = false;

  @override
  String toString() {
    return 'NotificationPage('
        'notifications: ${notifications.length}, '
        'currentPage: $currentPage, '
        'totalPages: $totalPages, '
        'totalCount: $totalCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationPage &&
        _listEquals(other.notifications, notifications) &&
        other.currentPage == currentPage &&
        other.totalPages == totalPages &&
        other.totalCount == totalCount &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    return notifications.hashCode ^
        currentPage.hashCode ^
        totalPages.hashCode ^
        totalCount.hashCode ^
        limit.hashCode;
  }

  bool _listEquals<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
