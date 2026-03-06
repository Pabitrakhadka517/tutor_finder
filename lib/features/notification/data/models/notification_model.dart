import '../../domain/entities/notification_entity.dart';
import '../../domain/value_objects/notification_type.dart';

/// Data model for notification — standalone (does not extend domain entity
/// since the entity uses a private constructor).
class NotificationModel {
  final String id;
  final String recipientId;
  final String? senderId;
  final String? senderName;
  final String? senderImage;
  final String type;
  final String message;
  final String? relatedId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.recipientId,
    this.senderId,
    this.senderName,
    this.senderImage,
    required this.type,
    required this.message,
    this.relatedId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    String recipientId = '';
    if (json['recipient'] is Map) {
      recipientId = (json['recipient'] as Map)['_id']?.toString() ?? '';
    } else {
      recipientId = json['recipient']?.toString() ?? '';
    }

    String? senderId;
    String? senderName;
    String? senderImage;
    if (json['sender'] is Map) {
      final s = json['sender'] as Map<String, dynamic>;
      senderId = s['_id']?.toString() ?? s['id']?.toString();
      senderName = s['fullName']?.toString();
      senderImage = s['profileImage']?.toString();
    } else if (json['sender'] != null) {
      senderId = json['sender'].toString();
    }

    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      recipientId: recipientId,
      senderId: senderId,
      senderName: senderName,
      senderImage: senderImage,
      type: json['type']?.toString() ?? 'ADMIN_MESSAGE',
      message: json['message']?.toString() ?? '',
      relatedId: json['relatedId']?.toString(),
      isRead: json['isRead'] ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipient': recipientId,
    'sender': senderId,
    'type': type,
    'message': message,
    'relatedId': relatedId,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Convert to domain entity
  NotificationEntity toEntity() {
    NotificationType notificationType;
    try {
      notificationType = NotificationType.fromString(type.toUpperCase());
    } catch (_) {
      notificationType = NotificationType.adminMessage;
    }
    return NotificationEntity.fromRepository(
      id: id,
      recipientId: recipientId,
      type: notificationType,
      title: message, // use message as title for compatibility
      message: message,
      payload: {
        if (senderId != null) 'senderId': senderId,
        if (senderName != null) 'senderName': senderName,
        if (senderImage != null) 'senderImage': senderImage,
        if (relatedId != null) 'relatedId': relatedId,
      },
      read: isRead,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  /// Create from domain entity
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      recipientId: entity.recipientId,
      senderId: entity.payload?['senderId'] as String?,
      senderName: entity.payload?['senderName'] as String?,
      senderImage: entity.payload?['senderImage'] as String?,
      type: entity.type.value.toUpperCase(),
      message: entity.message ?? entity.title,
      relatedId: entity.payload?['relatedId'] as String?,
      isRead: entity.read,
      createdAt: entity.createdAt,
    );
  }
}
