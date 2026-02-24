import 'package:equatable/equatable.dart';

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
  final bool isRead;
  final DateTime createdAt;

  const MessageEntity({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    this.senderName,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, chatRoomId];
}
