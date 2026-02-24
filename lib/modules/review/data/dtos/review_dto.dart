import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/review_entity.dart';
import '../../domain/entities/review_statistics.dart';
import '../../domain/value_objects/rating_vo.dart';

part 'review_dto.g.dart';

/// Data Transfer Object for review data.
/// Used for API communication and JSON serialization.
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

  @JsonKey(name: 'rating')
  final int rating;

  @JsonKey(name: 'comment')
  final String? comment;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  ReviewDto({
    required this.id,
    required this.bookingId,
    required this.tutorId,
    required this.studentId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory ReviewDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewDtoFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$ReviewDtoToJson(this);

  /// Convert to domain entity
  ReviewEntity toEntity() {
    return ReviewEntity(
      id: id,
      bookingId: bookingId,
      tutorId: tutorId,
      studentId: studentId,
      rating: Rating.trusted(rating), // Already validated in DTO
      comment: comment,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }

  /// Create from domain entity
  factory ReviewDto.fromEntity(ReviewEntity entity) {
    return ReviewDto(
      id: entity.id,
      bookingId: entity.bookingId,
      tutorId: entity.tutorId,
      studentId: entity.studentId,
      rating: entity.rating.value,
      comment: entity.comment,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }

  /// Create DTO for API creation request
  factory ReviewDto.forCreation({
    required String bookingId,
    required String tutorId,
    required String studentId,
    required int rating,
    String? comment,
  }) {
    final now = DateTime.now().toIso8601String();
    return ReviewDto(
      id: '', // Will be set by server
      bookingId: bookingId,
      tutorId: tutorId,
      studentId: studentId,
      rating: rating,
      comment: comment,
      createdAt: now,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewDto &&
        other.id == id &&
        other.bookingId == bookingId &&
        other.tutorId == tutorId &&
        other.studentId == studentId &&
        other.rating == rating &&
        other.comment == comment &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        bookingId.hashCode ^
        tutorId.hashCode ^
        studentId.hashCode ^
        rating.hashCode ^
        (comment?.hashCode ?? 0) ^
        createdAt.hashCode ^
        (updatedAt?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'ReviewDto('
        'id: $id, '
        'bookingId: $bookingId, '
        'tutorId: $tutorId, '
        'rating: $rating'
        ')';
  }

  /// Create a copy with updated fields
  ReviewDto copyWith({
    String? id,
    String? bookingId,
    String? tutorId,
    String? studentId,
    int? rating,
    String? comment,
    String? createdAt,
    String? updatedAt,
  }) {
    return ReviewDto(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      tutorId: tutorId ?? this.tutorId,
      studentId: studentId ?? this.studentId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// DTO for review with student information
@JsonSerializable()
class ReviewWithStudentDto {
  @JsonKey(name: 'review')
  final ReviewDto review;

  @JsonKey(name: 'student_name')
  final String studentName;

  @JsonKey(name: 'student_avatar')
  final String? studentAvatar;

  ReviewWithStudentDto({
    required this.review,
    required this.studentName,
    this.studentAvatar,
  });

  factory ReviewWithStudentDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewWithStudentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewWithStudentDtoToJson(this);

  /// Convert to domain object
  ReviewWithStudentInfo toStudentInfo() {
    return ReviewWithStudentInfo(
      review: review.toEntity(),
      studentName: studentName,
      studentAvatar: studentAvatar,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewWithStudentDto &&
        other.review == review &&
        other.studentName == studentName &&
        other.studentAvatar == studentAvatar;
  }

  @override
  int get hashCode {
    return review.hashCode ^
        studentName.hashCode ^
        (studentAvatar?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'ReviewWithStudentDto('
        'reviewId: ${review.id}, '
        'student: $studentName'
        ')';
  }
}

/// DTO for review statistics
@JsonSerializable()
class ReviewStatisticsDto {
  @JsonKey(name: 'total_reviews')
  final int totalReviews;

  @JsonKey(name: 'average_rating')
  final double averageRating;

  @JsonKey(name: 'rating_distribution')
  final Map<String, int> ratingDistribution;

  @JsonKey(name: 'recent_reviews_count')
  final int recentReviewsCount;

  @JsonKey(name: 'positive_reviews_percentage')
  final double positiveReviewsPercentage;

  ReviewStatisticsDto({
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
    required this.recentReviewsCount,
    required this.positiveReviewsPercentage,
  });

  factory ReviewStatisticsDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewStatisticsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewStatisticsDtoToJson(this);

  /// Convert to domain object
  ReviewStatistics toStatistics() {
    // Convert string keys to integers
    final intDistribution = <int, int>{};
    for (final entry in ratingDistribution.entries) {
      final key = int.tryParse(entry.key);
      if (key != null && key >= 1 && key <= 5) {
        intDistribution[key] = entry.value;
      }
    }

    return ReviewStatistics(
      totalReviews: totalReviews,
      averageRating: averageRating,
      ratingDistribution: intDistribution,
      recentReviewsCount: recentReviewsCount,
      positiveReviewsPercentage: positiveReviewsPercentage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewStatisticsDto &&
        other.totalReviews == totalReviews &&
        other.averageRating == averageRating &&
        _mapEquals(other.ratingDistribution, ratingDistribution) &&
        other.recentReviewsCount == recentReviewsCount &&
        other.positiveReviewsPercentage == positiveReviewsPercentage;
  }

  @override
  int get hashCode {
    return totalReviews.hashCode ^
        averageRating.hashCode ^
        ratingDistribution.hashCode ^
        recentReviewsCount.hashCode ^
        positiveReviewsPercentage.hashCode;
  }

  bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'ReviewStatisticsDto('
        'total: $totalReviews, '
        'average: ${averageRating.toStringAsFixed(1)}'
        ')';
  }
}
