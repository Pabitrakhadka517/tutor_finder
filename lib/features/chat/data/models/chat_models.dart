import '../../domain/entities/chat_entities.dart';

class ChatRoomModel extends ChatRoomEntity {
  const ChatRoomModel({
    required super.id,
    required super.studentId,
    required super.tutorId,
    super.studentName,
    super.tutorName,
    super.studentImage,
    super.tutorImage,
    super.lastMessage,
    super.lastMessageAt,
    super.isActive,
    required super.createdAt,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    // Parse student
    String studentId = '';
    String? studentName;
    String? studentImage;
    if (json['student'] is Map) {
      final s = json['student'] as Map<String, dynamic>;
      studentId = s['_id']?.toString() ?? s['id']?.toString() ?? '';
      studentName = s['fullName']?.toString();
      studentImage = s['profileImage']?.toString();
    } else {
      studentId = json['student']?.toString() ?? '';
    }

    // Parse tutor
    String tutorId = '';
    String? tutorName;
    String? tutorImage;
    if (json['tutor'] is Map) {
      final t = json['tutor'] as Map<String, dynamic>;
      tutorId = t['_id']?.toString() ?? t['id']?.toString() ?? '';
      tutorName = t['fullName']?.toString();
      tutorImage = t['profileImage']?.toString();
    } else {
      tutorId = json['tutor']?.toString() ?? '';
    }

    return ChatRoomModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      studentId: studentId,
      tutorId: tutorId,
      studentName: studentName,
      tutorName: tutorName,
      studentImage: studentImage,
      tutorImage: tutorImage,
      lastMessage: json['lastMessage']?.toString(),
      lastMessageAt: DateTime.tryParse(
        json['lastMessageAt']?.toString() ?? '',
      )?.toUtc(),
      isActive: json['isActive'] ?? true,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
    );
  }
}

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.chatRoomId,
    required super.senderId,
    super.senderName,
    required super.message,
    super.messageType,
    super.fileUrl,
    super.fileName,
    super.attachments,
    super.isRead,
    super.isEdited,
    super.isDeleted,
    required super.createdAt,
    super.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    String senderId = '';
    String? senderName;
    if (json['sender'] is Map) {
      final s = json['sender'] as Map<String, dynamic>;
      senderId = s['_id']?.toString() ?? s['id']?.toString() ?? '';
      senderName = s['fullName']?.toString();
    } else {
      senderId = json['sender']?.toString() ?? '';
    }

    return MessageModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      chatRoomId: json['chatRoom']?.toString() ?? '',
      senderId: senderId,
      senderName: senderName,
      message: json['message']?.toString() ?? json['content']?.toString() ?? '',
      messageType: chatMessageTypeFromString(json['messageType']?.toString()),
      fileUrl: json['fileUrl']?.toString(),
      fileName: json['fileName']?.toString(),
      attachments:
          (json['attachments'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      isRead: json['isRead'] ?? false,
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
      updatedAt: DateTime.tryParse(
        json['updatedAt']?.toString() ?? '',
      )?.toUtc(),
    );
  }
}
