// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewDto _$ReviewDtoFromJson(Map<String, dynamic> json) => ReviewDto(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      tutorId: json['tutor_id'] as String,
      studentId: json['student_id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$ReviewDtoToJson(ReviewDto instance) => <String, dynamic>{
      'id': instance.id,
      'booking_id': instance.bookingId,
      'tutor_id': instance.tutorId,
      'student_id': instance.studentId,
      'rating': instance.rating,
      'comment': instance.comment,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

ReviewWithStudentDto _$ReviewWithStudentDtoFromJson(
        Map<String, dynamic> json) =>
    ReviewWithStudentDto(
      review: ReviewDto.fromJson(json['review'] as Map<String, dynamic>),
      studentName: json['student_name'] as String,
      studentAvatar: json['student_avatar'] as String?,
    );

Map<String, dynamic> _$ReviewWithStudentDtoToJson(
        ReviewWithStudentDto instance) =>
    <String, dynamic>{
      'review': instance.review,
      'student_name': instance.studentName,
      'student_avatar': instance.studentAvatar,
    };

ReviewStatisticsDto _$ReviewStatisticsDtoFromJson(Map<String, dynamic> json) =>
    ReviewStatisticsDto(
      totalReviews: (json['total_reviews'] as num).toInt(),
      averageRating: (json['average_rating'] as num).toDouble(),
      ratingDistribution:
          Map<String, int>.from(json['rating_distribution'] as Map),
      recentReviewsCount: (json['recent_reviews_count'] as num).toInt(),
      positiveReviewsPercentage:
          (json['positive_reviews_percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$ReviewStatisticsDtoToJson(
        ReviewStatisticsDto instance) =>
    <String, dynamic>{
      'total_reviews': instance.totalReviews,
      'average_rating': instance.averageRating,
      'rating_distribution': instance.ratingDistribution,
      'recent_reviews_count': instance.recentReviewsCount,
      'positive_reviews_percentage': instance.positiveReviewsPercentage,
    };
