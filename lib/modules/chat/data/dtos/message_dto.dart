import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/message_entity.dart';
import '../../domain/enums/message_status.dart';

part 'message_dto.g.dart';

/// Data Transfer Object for message data.
/// Used for API communication and JSON serialization.
@JsonSerializable()
class MessageDto {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'chat_id')
  final String chatId;

  @JsonKey(name: 'sender_id')
  final String senderId;

  @JsonKey(name: 'content')
  final String content;

  @JsonKey(name: 'attachments')
  final List<String>? attachments;

  @JsonKey(name: 'reply_to_id')
  final String? replyToId;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'is_edited')
  final bool isEdited;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'updated_at')
  final String updatedAt;

  @JsonKey(name: 'read_by')
  final List<MessageReadStatusDto>? readBy;

  MessageDto({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.attachments,
    this.replyToId,
    required this.status,
    required this.isEdited,
    required this.createdAt,
    required this.updatedAt,
    this.readBy,
  });

  /// Create from JSON
  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);

  /// Creates a copy with modified fields
  MessageDto copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    List<String>? attachments,
    String? replyToId,
    String? status,
    bool? isEdited,
    String? createdAt,
    String? updatedAt,
    List<MessageReadStatusDto>? readBy,
  }) {
    return MessageDto(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
      replyToId: replyToId ?? this.replyToId,
      status: status ?? this.status,
      isEdited: isEdited ?? this.isEdited,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      readBy: readBy ?? this.readBy,
    );
  }

  /// Convert to domain entity
  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      chatId: chatId,
      senderId: senderId,
      content: content,
      attachments: attachments ?? [],
      replyToId: replyToId,
      status: MessageStatus.fromString(status),
      isEdited: isEdited,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      readBy: readBy?.map((readDto) => readDto.toReadStatus()).toList() ?? [],
    );
  }

  /// Create from domain entity
  factory MessageDto.fromEntity(MessageEntity entity) {
    return MessageDto(
      id: entity.id,
      chatId: entity.chatId,
      senderId: entity.senderId,
      content: entity.content,
      attachments: entity.attachments?.isEmpty ?? true
          ? null
          : entity.attachments,
      replyToId: entity.replyToId,
      status: entity.status.value,
      isEdited: entity.isEdited,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      readBy: entity.readBy.isEmpty
          ? null
          : entity.readBy
                .map(
                  (readStatus) =>
                      MessageReadStatusDto.fromReadStatus(readStatus),
                )
                .toList(),
    );
  }

  /// Create DTO for API creation request
  factory MessageDto.forCreation({
    required String chatId,
    required String senderId,
    required String content,
    List<String>? attachments,
    String? replyToId,
  }) {
    final now = DateTime.now().toIso8601String();
    return MessageDto(
      id: '', // Will be set by server
      chatId: chatId,
      senderId: senderId,
      content: content,
      attachments: attachments,
      replyToId: replyToId,
      status: MessageStatus.sent.value,
      isEdited: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageDto &&
        other.id == id &&
        other.chatId == chatId &&
        other.senderId == senderId &&
        other.content == content &&
        _listEquals(other.attachments, attachments) &&
        other.replyToId == replyToId &&
        other.status == status &&
        other.isEdited == isEdited &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        _listEquals(other.readBy, readBy);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        chatId.hashCode ^
        senderId.hashCode ^
        content.hashCode ^
        (attachments?.hashCode ?? 0) ^
        (replyToId?.hashCode ?? 0) ^
        status.hashCode ^
        isEdited.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        (readBy?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'MessageDto(id: $id, chatId: $chatId, senderId: $senderId, content: ${content.length} chars, status: $status)';
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

/// DTO for message read status
@JsonSerializable()
class MessageReadStatusDto {
  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'read_at')
  final String readAt;

  MessageReadStatusDto({required this.userId, required this.readAt});

  factory MessageReadStatusDto.fromJson(Map<String, dynamic> json) =>
      _$MessageReadStatusDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageReadStatusDtoToJson(this);

  /// Convert to domain read status
  MessageReadStatus toReadStatus() {
    return MessageReadStatus(userId: userId, readAt: DateTime.parse(readAt));
  }

  /// Create from domain read status
  factory MessageReadStatusDto.fromReadStatus(MessageReadStatus readStatus) {
    return MessageReadStatusDto(
      userId: readStatus.userId,
      readAt: readStatus.readAt.toIso8601String(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageReadStatusDto &&
        other.userId == userId &&
        other.readAt == readAt;
  }

  @override
  int get hashCode => userId.hashCode ^ readAt.hashCode;

  @override
  String toString() {
    return 'MessageReadStatusDto(userId: $userId, readAt: $readAt)';
  }
}
