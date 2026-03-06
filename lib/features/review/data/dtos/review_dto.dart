import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/review_entity.dart';

part 'review_dto.g.dart';

/// Data Transfer Object for review data in the review feature.
@JsonSerializable()
class ReviewDto {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'booking_id')
  final String bookingId;

  @JsonKey(name: 'tutor_id')
  final String tutorId;

  @JsonKey(name: 'student_id')
  final String studentId;

  @JsonKey(name: 'student_name')
  final String? studentName;

  @JsonKey(name: 'student_image')
  final String? studentImage;

  @JsonKey(name: 'rating')
  final int rating;

  @JsonKey(name: 'comment')
  final String? comment;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const ReviewDto({
    required this.id,
    required this.bookingId,
    required this.tutorId,
    required this.studentId,
    this.studentName,
    this.studentImage,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  factory ReviewDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewDtoToJson(this);

  ReviewEntity toEntity() {
    return ReviewEntity(
      id: id,
      bookingId: bookingId,
      tutorId: tutorId,
      studentId: studentId,
      studentName: studentName,
      studentImage: studentImage,
      rating: rating,
      comment: comment,
      createdAt: DateTime.parse(createdAt),
    );
  }

  factory ReviewDto.fromEntity(ReviewEntity entity) {
    return ReviewDto(
      id: entity.id,
      bookingId: entity.bookingId,
      tutorId: entity.tutorId,
      studentId: entity.studentId,
      studentName: entity.studentName,
      studentImage: entity.studentImage,
      rating: entity.rating,
      comment: entity.comment,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}
