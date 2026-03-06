// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor_rating_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TutorRatingDto _$TutorRatingDtoFromJson(Map<String, dynamic> json) =>
    TutorRatingDto(
      tutorId: json['tutor_id'] as String,
      averageRating: (json['average_rating'] as num).toDouble(),
      totalReviews: (json['total_reviews'] as num).toInt(),
      ratingDistribution:
          Map<String, int>.from(json['rating_distribution'] as Map),
      lastUpdated: json['last_updated'] as String,
    );

Map<String, dynamic> _$TutorRatingDtoToJson(TutorRatingDto instance) =>
    <String, dynamic>{
      'tutor_id': instance.tutorId,
      'average_rating': instance.averageRating,
      'total_reviews': instance.totalReviews,
      'rating_distribution': instance.ratingDistribution,
      'last_updated': instance.lastUpdated,
    };

PlatformStatsDto _$PlatformStatsDtoFromJson(Map<String, dynamic> json) =>
    PlatformStatsDto(
      averageRating: (json['average_rating'] as num).toDouble(),
      totalReviews: (json['total_reviews'] as num).toInt(),
      totalTutors: (json['total_tutors'] as num).toInt(),
      ratingDistribution:
          Map<String, int>.from(json['rating_distribution'] as Map),
      lastUpdated: json['last_updated'] as String,
    );

Map<String, dynamic> _$PlatformStatsDtoToJson(PlatformStatsDto instance) =>
    <String, dynamic>{
      'average_rating': instance.averageRating,
      'total_reviews': instance.totalReviews,
      'total_tutors': instance.totalTutors,
      'rating_distribution': instance.ratingDistribution,
      'last_updated': instance.lastUpdated,
    };
