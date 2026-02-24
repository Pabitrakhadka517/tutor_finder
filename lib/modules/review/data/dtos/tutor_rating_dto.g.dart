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
      lastUpdatedAt: json['last_updated_at'] as String,
      ratingDistribution:
          (json['rating_distribution'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
    );

Map<String, dynamic> _$TutorRatingDtoToJson(TutorRatingDto instance) =>
    <String, dynamic>{
      'tutor_id': instance.tutorId,
      'average_rating': instance.averageRating,
      'total_reviews': instance.totalReviews,
      'last_updated_at': instance.lastUpdatedAt,
      'rating_distribution': instance.ratingDistribution,
    };

PlatformRatingStatsDto _$PlatformRatingStatsDtoFromJson(
        Map<String, dynamic> json) =>
    PlatformRatingStatsDto(
      totalTutors: (json['total_tutors'] as num).toInt(),
      tutorsWithRatings: (json['tutors_with_ratings'] as num).toInt(),
      totalReviews: (json['total_reviews'] as num).toInt(),
      averagePlatformRating:
          (json['average_platform_rating'] as num).toDouble(),
      ratingDistribution:
          Map<String, int>.from(json['rating_distribution'] as Map),
      topRatedTutorsCount: (json['top_rated_tutors_count'] as num).toInt(),
    );

Map<String, dynamic> _$PlatformRatingStatsDtoToJson(
        PlatformRatingStatsDto instance) =>
    <String, dynamic>{
      'total_tutors': instance.totalTutors,
      'tutors_with_ratings': instance.tutorsWithRatings,
      'total_reviews': instance.totalReviews,
      'average_platform_rating': instance.averagePlatformRating,
      'rating_distribution': instance.ratingDistribution,
      'top_rated_tutors_count': instance.topRatedTutorsCount,
    };
