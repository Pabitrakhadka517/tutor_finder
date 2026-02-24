import '../enums/message_status.dart';

/// Represents a read receipt for a message
class MessageReadStatus {
  final String userId;
  final DateTime readAt;

  const MessageReadStatus({required this.userId, required this.readAt});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageReadStatus && other.userId == userId;

  @override
  int get hashCode => userId.hashCode;
}

/// Core message entity containing all business rules and logic.
class MessageEntity {
  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.status,
    required this.readBy,
    required this.createdAt,
    required this.updatedAt,
    this.attachments,
    this.replyToId,
    this.editedAt,
    this.isEdited = false,
  });

  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final MessageStatus status;
  final List<MessageReadStatus> readBy;
  final List<String>? attachments;
  final String? replyToId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? editedAt;
  final bool isEdited;

  static const int maxContentLength = 1000;

  bool get isValidContent =>
      content.trim().isNotEmpty || (attachments?.isNotEmpty ?? false);

  bool get isContentTooLong => content.length > maxContentLength;

  bool isUnreadBy(String userId) {
    if (senderId == userId) return false;
    return !readBy.any((r) => r.userId == userId);
  }

  bool isReadBy(String userId) => !isUnreadBy(userId);

  bool isReadByAll(List<String> participantIds) =>
      participantIds.every((id) => !isUnreadBy(id));

  MessageEntity markAsRead(String userId) {
    if (senderId == userId || readBy.any((r) => r.userId == userId)) {
      return this;
    }
    return copyWith(
      readBy: [...readBy, MessageReadStatus(userId: userId, readAt: DateTime.now())],
      status: MessageStatus.read,
    );
  }

  bool get hasAttachments => attachments != null && attachments!.isNotEmpty;
  bool get isReply => replyToId != null;
  int get ageInMinutes => DateTime.now().difference(createdAt).inMinutes;
  bool get isRecent => ageInMinutes <= 5;

  bool canBeEditedBy(String userId, {int timeLimit = 15}) =>
      senderId == userId && !hasAttachments && ageInMinutes <= timeLimit;

  bool canBeDeletedBy(String userId) => senderId == userId;

  bool validateCreation() =>
      isValidContent && !isContentTooLong && senderId.isNotEmpty && chatId.isNotEmpty;

  factory MessageEntity.create({
    required String id,
    required String chatId,
    required String senderId,
    required String content,
    List<String>? attachments,
    String? replyToId,
  }) {
    final now = DateTime.now();
    return MessageEntity(
      id: id,
      chatId: chatId,
      senderId: senderId,
      content: content,
      status: MessageStatus.sent,
      readBy: [],
      attachments: attachments,
      replyToId: replyToId,
      createdAt: now,
      updatedAt: now,
      isEdited: false,
    );
  }

  MessageEntity edit(String newContent) {
    final now = DateTime.now();
    return copyWith(content: newContent, editedAt: now, updatedAt: now, isEdited: true);
  }

  MessageEntity updateStatus(MessageStatus newStatus) =>
      copyWith(status: newStatus);

  String getPreview({int maxLength = 50}) {
    if (hasAttachments && content.isEmpty) {
      return attachments!.length == 1 ? 'Attachment' : 'Attachments';
    }
    final trimmed = content.trim();
    return trimmed.length <= maxLength ? trimmed : trimmed.substring(0, maxLength) + '...';
  }

  MessageEntity copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    MessageStatus? status,
    List<MessageReadStatus>? readBy,
    List<String>? attachments,
    String? replyToId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? editedAt,
    bool? isEdited,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      status: status ?? this.status,
      readBy: readBy ?? this.readBy,
      attachments: attachments ?? this.attachments,
      replyToId: replyToId ?? this.replyToId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      editedAt: editedAt ?? this.editedAt,
      isEdited: isEdited ?? this.isEdited,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MessageEntity && id == other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MessageEntity(id: $id, chat: $chatId, sender: $senderId)';
}