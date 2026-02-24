// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TutorDto _$TutorDtoFromJson(Map<String, dynamic> json) => TutorDto(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      fullName: json['full_name'] as String,
      profileImage: json['profile_image'] as String?,
      bio: json['bio'] as String,
      experienceYears: (json['experience_years'] as num).toInt(),
      hourlyRate: (json['hourly_rate'] as num).toDouble(),
      languages:
          (json['languages'] as List<dynamic>).map((e) => e as String).toList(),
      subjects:
          (json['subjects'] as List<dynamic>).map((e) => e as String).toList(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['review_count'] as num).toInt(),
      verificationStatus: json['verification_status'] as String,
      isAvailable: json['is_available'] as bool,
      createdAt: json['created_at'] as String,
      nextAvailableSlot: json['next_available_slot'] == null
          ? null
          : AvailabilitySlotDto.fromJson(
              json['next_available_slot'] as Map<String, dynamic>),
      location: json['location'] as String?,
      specialization: json['specialization'] as String?,
      education: json['education'] as String?,
    );

Map<String, dynamic> _$TutorDtoToJson(TutorDto instance) => <String, dynamic>{
      'id': instance.id,
      'profile_id': instance.profileId,
      'full_name': instance.fullName,
      'profile_image': instance.profileImage,
      'bio': instance.bio,
      'experience_years': instance.experienceYears,
      'hourly_rate': instance.hourlyRate,
      'languages': instance.languages,
      'subjects': instance.subjects,
      'rating': instance.rating,
      'review_count': instance.reviewCount,
      'verification_status': instance.verificationStatus,
      'is_available': instance.isAvailable,
      'created_at': instance.createdAt,
      'next_available_slot': instance.nextAvailableSlot,
      'location': instance.location,
      'specialization': instance.specialization,
      'education': instance.education,
    };
