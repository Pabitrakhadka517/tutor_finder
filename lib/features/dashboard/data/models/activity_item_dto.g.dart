// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityItemDto _$ActivityItemDtoFromJson(Map<String, dynamic> json) =>
    ActivityItemDto(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ActivityItemDtoToJson(ActivityItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'timestamp': instance.timestamp.toIso8601String(),
      'metadata': instance.metadata,
    };
