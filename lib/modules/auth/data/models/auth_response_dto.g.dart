// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponseDto _$AuthResponseDtoFromJson(Map<String, dynamic> json) =>
    AuthResponseDto(
      message: json['message'] as String?,
      token: json['token'] as String?,
      accessToken: json['accessToken'] as String?,
      accessTokenSnake: json['access_token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      refreshTokenSnake: json['refresh_token'] as String?,
      userId: json['userId'] as String?,
      id: json['id'] as String?,
      mongoId: json['_id'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      user: json['user'] == null
          ? null
          : UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseDtoToJson(AuthResponseDto instance) =>
    <String, dynamic>{
      'message': instance.message,
      'token': instance.token,
      'accessToken': instance.accessToken,
      'access_token': instance.accessTokenSnake,
      'refreshToken': instance.refreshToken,
      'refresh_token': instance.refreshTokenSnake,
      'userId': instance.userId,
      'id': instance.id,
      '_id': instance.mongoId,
      'email': instance.email,
      'name': instance.name,
      'role': instance.role,
      'createdAt': instance.createdAt?.toIso8601String(),
      'user': instance.user,
    };
