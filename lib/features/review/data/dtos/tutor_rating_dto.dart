import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/platform_stats_entity.dart';
import '../../domain/entities/tutor_rating_entity.dart';

part 'tutor_rating_dto.g.dart';

/// Data Transfer Object for tutor rating aggregation data.
@JsonSerializable()
class TutorRatingDto {
  @JsonKey(name: 'tutor_id')
  final String tutorId;

  @JsonKey(name: 'average_rating')
  final double averageRating;

  @JsonKey(name: 'total_reviews')
  final int totalReviews;

  @JsonKey(name: 'rating_distribution')
  final Map<String, int> ratingDistribution;

  @JsonKey(name: 'last_updated')
  final String lastUpdated;

  const TutorRatingDto({
    required this.tutorId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.lastUpdated,
  });

  factory TutorRatingDto.fromJson(Map<String, dynamic> json) =>
      _$TutorRatingDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TutorRatingDtoToJson(this);

  TutorRatingEntity toEntity() {
    return TutorRatingEntity(
      tutorId: tutorId,
      averageRating: averageRating,
      totalReviews: totalReviews,
      ratingDistribution: ratingDistribution.map(
        (key, value) => MapEntry(int.parse(key), value),
      ),
      lastUpdated: DateTime.parse(lastUpdated),
    );
  }

  factory TutorRatingDto.fromEntity(TutorRatingEntity entity) {
    return TutorRatingDto(
      tutorId: entity.tutorId,
      averageRating: entity.averageRating,
      totalReviews: entity.totalReviews,
      ratingDistribution: entity.ratingDistribution.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      lastUpdated: entity.lastUpdated.toIso8601String(),
    );
  }
}

/// DTO for platform-wide rating statistics
@JsonSerializable()
class PlatformStatsDto {
  @JsonKey(name: 'average_rating')
  final double averageRating;

  @JsonKey(name: 'total_reviews')
  final int totalReviews;

  @JsonKey(name: 'total_tutors')
  final int totalTutors;

  @JsonKey(name: 'rating_distribution')
  final Map<String, int> ratingDistribution;

  @JsonKey(name: 'last_updated')
  final String lastUpdated;

  const PlatformStatsDto({
    required this.averageRating,
    required this.totalReviews,
    required this.totalTutors,
    required this.ratingDistribution,
    required this.lastUpdated,
  });

  factory PlatformStatsDto.fromJson(Map<String, dynamic> json) =>
      _$PlatformStatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformStatsDtoToJson(this);

  PlatformStatsEntity toEntity() {
    return PlatformStatsEntity(
      averageRating: averageRating,
      totalReviews: totalReviews,
      totalTutors: totalTutors,
      ratingDistribution: ratingDistribution.map(
        (key, value) => MapEntry(int.tryParse(key) ?? 0, value),
      ),
      lastUpdated: DateTime.parse(lastUpdated),
    );
  }
}
