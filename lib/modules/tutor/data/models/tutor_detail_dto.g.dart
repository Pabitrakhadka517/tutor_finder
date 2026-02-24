// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TutorDetailDto _$TutorDetailDtoFromJson(Map<String, dynamic> json) =>
    TutorDetailDto(
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
      availabilitySlots: (json['availability_slots'] as List<dynamic>)
          .map((e) => AvailabilitySlotDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      location: json['location'] as String?,
      specialization: json['specialization'] as String?,
      education: json['education'] as String?,
      recentReviews: (json['recent_reviews'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      certifications: (json['certifications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$TutorDetailDtoToJson(TutorDetailDto instance) =>
    <String, dynamic>{
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
      'availability_slots': instance.availabilitySlots,
      'location': instance.location,
      'specialization': instance.specialization,
      'education': instance.education,
      'recent_reviews': instance.recentReviews,
      'certifications': instance.certifications,
    };
