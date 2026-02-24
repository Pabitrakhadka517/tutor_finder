// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
      id: json['id'] as String?,
      mongoId: json['_id'] as String?,
      email: json['email'] as String,
      name: json['name'] as String?,
      role: json['role'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
      'id': instance.id,
      '_id': instance.mongoId,
      'email': instance.email,
      'name': instance.name,
      'role': instance.role,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
