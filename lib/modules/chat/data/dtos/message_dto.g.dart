// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageDto _$MessageDtoFromJson(Map<String, dynamic> json) => MessageDto(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      replyToId: json['reply_to_id'] as String?,
      status: json['status'] as String,
      isEdited: json['is_edited'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      readBy: (json['read_by'] as List<dynamic>?)
          ?.map((e) => MessageReadStatusDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MessageDtoToJson(MessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chat_id': instance.chatId,
      'sender_id': instance.senderId,
      'content': instance.content,
      'attachments': instance.attachments,
      'reply_to_id': instance.replyToId,
      'status': instance.status,
      'is_edited': instance.isEdited,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'read_by': instance.readBy,
    };

MessageReadStatusDto _$MessageReadStatusDtoFromJson(
        Map<String, dynamic> json) =>
    MessageReadStatusDto(
      userId: json['user_id'] as String,
      readAt: json['read_at'] as String,
    );

Map<String, dynamic> _$MessageReadStatusDtoToJson(
        MessageReadStatusDto instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'read_at': instance.readAt,
    };
