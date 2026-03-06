import '../value_objects/notification_type.dart';

/// Core domain entity representing an in-app notification
///
/// This entity encapsulates all business rules and behavior for notifications
/// including read/unread state management, ownership validation, and
/// notification type constraints. The entity ensures data integrity and
/// enforces domain rules.
class NotificationEntity {
  final String id;
  final String recipientId;
  final NotificationType type;
  final String title;
  final String? message;
  final Map<String, dynamic>? payload;
  final bool read;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationEntity._({
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

  /// Create a new notification entity with validation
  factory NotificationEntity.create({
    required String recipientId,
    required NotificationType type,
    required String title,
    String? message,
    Map<String, dynamic>? payload,
  }) {
    // Validate recipient ID
    if (recipientId.trim().isEmpty) {
      throw ArgumentError('Recipient ID cannot be empty');
    }

    // Validate title
    if (title.trim().isEmpty) {
      throw ArgumentError('Notification title cannot be empty');
    }

    if (title.length > 200) {
      throw ArgumentError('Notification title cannot exceed 200 characters');
    }

    // Validate message length if provided
    if (message != null && message.length > 1000) {
      throw ArgumentError('Notification message cannot exceed 1000 characters');
    }

    // Validate payload size if provided
    if (payload != null) {
      _validatePayload(payload);
    }

    final now = DateTime.now();

    return NotificationEntity._(
      id: '', // Will be set by repository
      recipientId: recipientId,
      type: type,
      title: title.trim(),
      message: message?.trim(),
      payload: payload,
      read: false, // New notifications are always unread
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create notification entity from repository data
  factory NotificationEntity.fromRepository({
    required String id,
    required String recipientId,
    required NotificationType type,
    required String title,
    String? message,
    Map<String, dynamic>? payload,
    required bool read,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return NotificationEntity._(
      id: id,
      recipientId: recipientId,
      type: type,
      title: title,
      message: message,
      payload: payload,
      read: read,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Mark this notification as read
  NotificationEntity markAsRead() {
    if (read) {
      return this; // Already read, no change needed
    }

    return NotificationEntity._(
      id: id,
      recipientId: recipientId,
      type: type,
      title: title,
      message: message,
      payload: payload,
      read: true,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  NotificationEntity copyWith({
    String? id,
    String? recipientId,
    NotificationType? type,
    String? title,
    String? message,
    Map<String, dynamic>? payload,
    bool? read,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationEntity._(
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

  /// Validate if a user can access this notification
  bool canBeAccessedBy(String userId) {
    return recipientId == userId;
  }

  /// Check if this notification is unread
  bool get isUnread => !read;

  /// Check if this notification is urgent
  bool get isUrgent => type.isUrgent;

  /// Check if this notification should trigger a push notification
  bool get shouldPush => type.shouldPush;

  /// Get the age of this notification in days
  int get ageInDays {
    final now = DateTime.now();
    return now.difference(createdAt).inDays;
  }

  /// Check if this notification is considered fresh (less than 24 hours old)
  bool get isFresh => ageInDays == 0;

  /// Get payload value safely with type checking
  T? getPayloadValue<T>(String key) {
    if (payload == null || !payload!.containsKey(key)) {
      return null;
    }

    final value = payload![key];
    if (value is T) {
      return value;
    }

    return null;
  }

  /// Get a formatted summary for display
  String get summary {
    if (message != null && message!.isNotEmpty) {
      return message!.length > 100
          ? '${message!.substring(0, 100)}...'
          : message!;
    }
    return title;
  }

  /// Validate payload constraints
  static void _validatePayload(Map<String, dynamic> payload) {
    // Check payload size (approximate)
    final jsonString = payload.toString();
    if (jsonString.length > 5000) {
      throw ArgumentError('Notification payload is too large (max 5KB)');
    }

    // Validate payload keys and values
    for (final entry in payload.entries) {
      if (entry.key.isEmpty) {
        throw ArgumentError('Payload keys cannot be empty');
      }

      if (entry.key.length > 100) {
        throw ArgumentError('Payload keys cannot exceed 100 characters');
      }

      // Ensure payload values are serializable JSON types
      if (!_isSerializable(entry.value)) {
        throw ArgumentError(
          'Payload contains non-serializable value for key: ${entry.key}',
        );
      }
    }
  }

  /// Check if a value is JSON serializable
  static bool _isSerializable(dynamic value) {
    if (value == null) return true;
    if (value is String || value is num || value is bool) return true;
    if (value is List) {
      return value.every((item) => _isSerializable(item));
    }
    if (value is Map) {
      return value.values.every((item) => _isSerializable(item));
    }
    return false;
  }

  @override
  String toString() {
    return 'NotificationEntity('
        'id: $id, '
        'recipientId: $recipientId, '
        'type: $type, '
        'title: $title, '
        'read: $read, '
        'createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationEntity &&
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
