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
      studentName: json['student_name'] as String?,
      studentImage: json['student_image'] as String?,
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
      'student_name': instance.studentName,
      'student_image': instance.studentImage,
      'rating': instance.rating,
      'comment': instance.comment,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
