import 'package:equatable/equatable.dart';

enum ChatMessageType { text, image, file }

ChatMessageType chatMessageTypeFromString(String? value) {
  switch ((value ?? '').toLowerCase()) {
    case 'image':
      return ChatMessageType.image;
    case 'file':
      return ChatMessageType.file;
    default:
      return ChatMessageType.text;
  }
}

class ChatRoomEntity extends Equatable {
  final String id;
  final String studentId;
  final String tutorId;
  final String? studentName;
  final String? tutorName;
  final String? studentImage;
  final String? tutorImage;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool isActive;
  final DateTime createdAt;

  const ChatRoomEntity({
    required this.id,
    required this.studentId,
    required this.tutorId,
    this.studentName,
    this.tutorName,
    this.studentImage,
    this.tutorImage,
    this.lastMessage,
    this.lastMessageAt,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id];
}

class MessageEntity extends Equatable {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String? senderName;
  final String message;
  final ChatMessageType messageType;
  final String? fileUrl;
  final String? fileName;
  final List<String> attachments;
  final bool isRead;
  final bool isEdited;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MessageEntity({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    this.senderName,
    required this.message,
    this.messageType = ChatMessageType.text,
    this.fileUrl,
    this.fileName,
    this.attachments = const [],
    this.isRead = false,
    this.isEdited = false,
    this.isDeleted = false,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    chatRoomId,
    senderId,
    senderName,
    message,
    messageType,
    fileUrl,
    fileName,
    attachments,
    isRead,
    isEdited,
    isDeleted,
    createdAt,
    updatedAt,
  ];
}
