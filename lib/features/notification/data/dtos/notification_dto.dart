import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_page.dart';
import '../../domain/value_objects/notification_type.dart';

part 'notification_dto.g.dart';

/// Data Transfer Object for Notification
///
/// This DTO handles JSON serialization/deserialization for API communication
/// and provides conversion methods between domain entities and data layer.
/// It serves as the bridge between external data and internal domain models.
@JsonSerializable(explicitToJson: true)
class NotificationDto {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'recipientId')
  final String recipientId;

  @JsonKey(name: 'type')
  final String type;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'payload')
  final Map<String, dynamic>? payload;

  @JsonKey(name: 'read')
  final bool read;

  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @JsonKey(name: 'updatedAt')
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

  /// Create DTO from JSON
  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);

  /// Convert DTO to JSON
  Map<String, dynamic> toJson() => _$NotificationDtoToJson(this);

  /// Convert DTO to domain entity
  NotificationEntity toEntity() {
    return NotificationEntity.fromRepository(
      id: id,
      recipientId: recipientId,
      type: NotificationType.fromString(type),
      title: title,
      message: message,
      payload: payload,
      read: read,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create DTO for API request (without server-generated fields)
  factory NotificationDto.forCreation({
    required String recipientId,
    required String type,
    required String title,
    String? message,
    Map<String, dynamic>? payload,
  }) {
    final now = DateTime.now();
    return NotificationDto(
      id: '', // Will be set by server
      recipientId: recipientId,
      type: type,
      title: title,
      message: message,
      payload: payload,
      read: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a copy with updated fields
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

  /// Helper for marking as read
  NotificationDto markAsRead() {
    return copyWith(read: true, updatedAt: DateTime.now());
  }

  @override
  String toString() {
    return 'NotificationDto('
        'id: $id, '
        'recipientId: $recipientId, '
        'type: $type, '
        'title: $title, '
        'read: $read)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationDto &&
        other.id == id &&
        other.recipientId == recipientId &&
        other.type == type &&
        other.title == title &&
        other.message == message &&
        _mapEquals(other.payload, payload) &&
        other.read == read &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        recipientId.hashCode ^
        type.hashCode ^
        title.hashCode ^
        message.hashCode ^
        payload.hashCode ^
        read.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
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

/// Paginated response DTO for notifications
@JsonSerializable(explicitToJson: true)
class NotificationPageDto {
  @JsonKey(name: 'notifications')
  final List<NotificationDto> notifications;

  @JsonKey(name: 'totalCount')
  final int totalCount;

  @JsonKey(name: 'page')
  final int page;

  @JsonKey(name: 'limit')
  final int limit;

  @JsonKey(name: 'totalPages')
  final int totalPages;

  @JsonKey(name: 'hasNext')
  final bool hasNext;

  @JsonKey(name: 'hasPrevious')
  final bool hasPrevious;

  const NotificationPageDto({
    required this.notifications,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory NotificationPageDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationPageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPageDtoToJson(this);

  @override
  String toString() {
    return 'NotificationPageDto('
        'notifications: ${notifications.length}, '
        'totalCount: $totalCount, '
        'page: $page, '
        'totalPages: $totalPages)';
  }

  /// Convert DTO to domain entity
  NotificationPage toPage() {
    return NotificationPage(
      notifications: notifications.map((dto) => dto.toEntity()).toList(),
      currentPage: page,
      totalPages: totalPages,
      totalCount: totalCount,
      limit: limit,
    );
  }
}

/// Statistics DTO for notifications
@JsonSerializable(explicitToJson: true)
class NotificationStatsDto {
  @JsonKey(name: 'totalNotifications')
  final int totalNotifications;

  @JsonKey(name: 'unreadNotifications')
  final int unreadNotifications;

  @JsonKey(name: 'readNotifications')
  final int readNotifications;

  @JsonKey(name: 'notificationsToday')
  final int notificationsToday;

  @JsonKey(name: 'notificationsThisWeek')
  final int notificationsThisWeek;

  @JsonKey(name: 'notificationsThisMonth')
  final int notificationsThisMonth;

  @JsonKey(name: 'typeDistribution')
  final Map<String, int> typeDistribution;

  @JsonKey(name: 'lastNotificationDate')
  final DateTime? lastNotificationDate;

  @JsonKey(name: 'averageNotificationsPerDay')
  final double averageNotificationsPerDay;

  const NotificationStatsDto({
    required this.totalNotifications,
    required this.unreadNotifications,
    required this.readNotifications,
    required this.notificationsToday,
    required this.notificationsThisWeek,
    required this.notificationsThisMonth,
    required this.typeDistribution,
    this.lastNotificationDate,
    required this.averageNotificationsPerDay,
  });

  factory NotificationStatsDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationStatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationStatsDtoToJson(this);

  @override
  String toString() {
    return 'NotificationStatsDto('
        'total: $totalNotifications, '
        'unread: $unreadNotifications, '
        'today: $notificationsToday)';
  }
}
