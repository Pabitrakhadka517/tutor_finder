import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_page.dart';
import '../../domain/value_objects/notification_type.dart';

/// Data Transfer Object for Notification
///
/// Manually handles JSON serialization/deserialization to match the
/// backend response format from web-backend-learnmentor exactly.
///
/// Backend notification object shape:
/// ```json
/// {
///   "_id": "...",
///   "recipient": "userId" | { "_id": "...", ... },
///   "sender": { "fullName": "...", "profileImage": "..." },
///   "type": "BOOKING_CREATED",
///   "message": "Your booking has been confirmed",
///   "relatedId": "...",
///   "isRead": false,
///   "createdAt": "2024-...",
///   "updatedAt": "2024-..."
/// }
/// ```
class NotificationDto {
  final String id;
  final String recipientId;
  final String type;
  final String title;
  final String? message;
  final Map<String, dynamic>? payload;
  final bool read;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationDto({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    this.message,
    this.payload,
    required this.read,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse from backend JSON response.
  ///
  /// Backend fields -> Flutter DTO fields:
  /// - `_id` / `id` -> [id]
  /// - `recipient` (string or object with `_id`) -> [recipientId]
  /// - `type` -> [type]
  /// - `message` -> [title] AND [message] (backend has no separate title)
  /// - `sender` (populated object) -> stored in [payload]
  /// - `relatedId` -> stored in [payload]
  /// - `isRead` / `read` -> [read]
  /// - `createdAt` -> [createdAt]
  /// - `updatedAt` -> [updatedAt]
  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    // Extract ID: backend uses _id, sometimes id
    final id = (json['_id'] ?? json['id'] ?? '').toString();

    // Extract recipient: can be a string or populated object
    String recipientId;
    final recipient = json['recipient'];
    if (recipient is Map) {
      recipientId = (recipient['_id'] ?? recipient['id'] ?? '').toString();
    } else {
      recipientId = (recipient ?? '').toString();
    }

    // Type
    final type = (json['type'] ?? 'SYSTEM_ALERT').toString();

    // Message: backend only has `message`, no separate `title`
    final message = json['message']?.toString() ?? 'Notification';

    // Read status: backend uses `isRead`, fallback to `read`
    final isRead = json['isRead'] as bool? ?? json['read'] as bool? ?? false;

    // Build payload from sender and relatedId
    final payloadMap = <String, dynamic>{};
    if (json['sender'] != null) {
      payloadMap['sender'] = json['sender'];
    }
    if (json['relatedId'] != null) {
      payloadMap['relatedId'] = json['relatedId'].toString();
    }
    // Include any 'data' field if present (from socket events)
    if (json['data'] is Map) {
      payloadMap['data'] = json['data'];
    }

    // Timestamps
    final createdAt = _parseDate(json['createdAt']);
    final updatedAt = _parseDate(json['updatedAt']) ?? createdAt;

    return NotificationDto(
      id: id,
      recipientId: recipientId,
      type: type,
      title: message, // Backend message serves as the title
      message: message,
      payload: payloadMap.isNotEmpty ? payloadMap : null,
      read: isRead,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Create DTO from domain entity
  factory NotificationDto.fromEntity(NotificationEntity entity) {
    return NotificationDto(
      id: entity.id,
      recipientId: entity.recipientId,
      type: entity.type.value,
      title: entity.title,
      message: entity.message,
      payload: entity.payload,
      read: entity.read,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipientId': recipientId,
    'type': type,
    'title': title,
    'message': message,
    'payload': payload,
    'read': read,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Convert DTO to domain entity
  NotificationEntity toEntity() {
    NotificationType notifType;
    try {
      notifType = NotificationType.fromString(type);
    } catch (_) {
      notifType = NotificationType.systemAlert;
    }

    return NotificationEntity.fromRepository(
      id: id,
      recipientId: recipientId,
      type: notifType,
      title: title,
      message: message,
      payload: payload,
      read: read,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  NotificationDto copyWith({
    String? id,
    String? recipientId,
    String? type,
    String? title,
    String? message,
    Map<String, dynamic>? payload,
    bool? read,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationDto(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      payload: payload ?? this.payload,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  NotificationDto markAsRead() {
    return copyWith(read: true, updatedAt: DateTime.now());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  String toString() =>
      'NotificationDto(id: $id, type: $type, title: $title, read: $read)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationDto && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Paginated response DTO for notifications.
///
/// Backend returns:
/// ```json
/// {
///   "notifications": [...],
///   "total": 25,
///   "page": 1,
///   "unreadCount": 3
/// }
/// ```
class NotificationPageDto {
  final List<NotificationDto> notifications;
  final int totalCount;
  final int page;
  final int limit;
  final int totalPages;
  final int unreadCount;

  const NotificationPageDto({
    required this.notifications,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.unreadCount,
  });

  bool get hasNext => page < totalPages;
  bool get hasPrevious => page > 1;

  factory NotificationPageDto.fromJson(
    Map<String, dynamic> json, {
    int requestedLimit = 20,
  }) {
    final notificationsList = <NotificationDto>[];
    final rawNotifications = json['notifications'];
    if (rawNotifications is List) {
      for (final item in rawNotifications) {
        if (item is Map<String, dynamic>) {
          notificationsList.add(NotificationDto.fromJson(item));
        }
      }
    }

    final total = (json['total'] as num?)?.toInt() ?? notificationsList.length;
    final page = (json['page'] as num?)?.toInt() ?? 1;
    final limit = (json['limit'] as num?)?.toInt() ?? requestedLimit;
    final unreadCount = (json['unreadCount'] as num?)?.toInt() ?? 0;
    final totalPages = limit > 0 ? (total / limit).ceil() : 1;

    return NotificationPageDto(
      notifications: notificationsList,
      totalCount: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
      unreadCount: unreadCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'notifications': notifications.map((n) => n.toJson()).toList(),
    'total': totalCount,
    'page': page,
    'limit': limit,
    'unreadCount': unreadCount,
  };

  NotificationPage toPage() {
    return NotificationPage(
      notifications: notifications.map((dto) => dto.toEntity()).toList(),
      currentPage: page,
      totalPages: totalPages,
      totalCount: totalCount,
      limit: limit,
    );
  }

  @override
  String toString() =>
      'NotificationPageDto(count: ${notifications.length}, total: $totalCount, '
      'page: $page, unread: $unreadCount)';
}
