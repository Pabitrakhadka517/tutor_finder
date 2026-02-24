// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileDto _$ProfileDtoFromJson(Map<String, dynamic> json) => ProfileDto(
      id: json['id'] as String?,
      mongoId: json['_id'] as String?,
      email: json['email'] as String,
      name: json['name'] as String?,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      speciality: json['speciality'] as String?,
      address: json['address'] as String?,
      profileImage: json['profileImage'] as String?,
      theme: json['theme'] as String?,
      verificationStatus: json['verificationStatus'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      bio: json['bio'] as String?,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      experienceYears: (json['experienceYears'] as num?)?.toInt(),
      subjects: (json['subjects'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ProfileDtoToJson(ProfileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      '_id': instance.mongoId,
      'email': instance.email,
      'name': instance.name,
      'role': instance.role,
      'phone': instance.phone,
      'speciality': instance.speciality,
      'address': instance.address,
      'profileImage': instance.profileImage,
      'theme': instance.theme,
      'verificationStatus': instance.verificationStatus,
      'createdAt': instance.createdAt?.toIso8601String(),
      'bio': instance.bio,
      'hourlyRate': instance.hourlyRate,
      'experienceYears': instance.experienceYears,
      'subjects': instance.subjects,
      'languages': instance.languages,
    };
