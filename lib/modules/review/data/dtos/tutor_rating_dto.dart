import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/tutor_rating_entity.dart';
import '../../domain/repositories/tutor_rating_repository.dart';

part 'tutor_rating_dto.g.dart';

/// Data Transfer Object for tutor rating aggregate data.
/// Used for API communication and JSON serialization.
@JsonSerializable()
class TutorRatingDto {
  @JsonKey(name: 'tutor_id')
  final String tutorId;

  @JsonKey(name: 'average_rating')
  final double averageRating;

  @JsonKey(name: 'total_reviews')
  final int totalReviews;

  @JsonKey(name: 'last_updated_at')
  final String lastUpdatedAt;

  @JsonKey(name: 'rating_distribution')
  final Map<String, int>? ratingDistribution;

  TutorRatingDto({
    required this.tutorId,
    required this.averageRating,
    required this.totalReviews,
    required this.lastUpdatedAt,
    this.ratingDistribution,
  });

  /// Create from JSON
  factory TutorRatingDto.fromJson(Map<String, dynamic> json) =>
      _$TutorRatingDtoFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$TutorRatingDtoToJson(this);

  /// Convert to domain entity
  TutorRatingEntity toEntity() {
    // Convert string keys to integers for rating distribution
    Map<int, int>? intDistribution;
    if (ratingDistribution != null) {
      intDistribution = {};
      for (final entry in ratingDistribution!.entries) {
        final key = int.tryParse(entry.key);
        if (key != null && key >= 1 && key <= 5) {
          intDistribution[key] = entry.value;
        }
      }
    }

    return TutorRatingEntity(
      tutorId: tutorId,
      averageRating: averageRating,
      totalReviews: totalReviews,
      lastUpdatedAt: DateTime.parse(lastUpdatedAt),
      ratingDistribution: intDistribution,
    );
  }

  /// Create from domain entity
  factory TutorRatingDto.fromEntity(TutorRatingEntity entity) {
    // Convert integer keys to strings for JSON
    Map<String, int>? stringDistribution;
    if (entity.ratingDistribution != null) {
      stringDistribution = {};
      for (final entry in entity.ratingDistribution!.entries) {
        stringDistribution[entry.key.toString()] = entry.value;
      }
    }

    return TutorRatingDto(
      tutorId: entity.tutorId,
      averageRating: entity.averageRating,
      totalReviews: entity.totalReviews,
      lastUpdatedAt: entity.lastUpdatedAt.toIso8601String(),
      ratingDistribution: stringDistribution,
    );
  }

  /// Create DTO for initial tutor rating
  factory TutorRatingDto.initial({
    required String tutorId,
    required int firstRating,
  }) {
    final now = DateTime.now().toIso8601String();
    return TutorRatingDto(
      tutorId: tutorId,
      averageRating: firstRating.toDouble(),
      totalReviews: 1,
      lastUpdatedAt: now,
      ratingDistribution: {firstRating.toString(): 1},
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TutorRatingDto &&
        other.tutorId == tutorId &&
        other.averageRating == averageRating &&
        other.totalReviews == totalReviews &&
        other.lastUpdatedAt == lastUpdatedAt &&
        _mapEquals(other.ratingDistribution, ratingDistribution);
  }

  @override
  int get hashCode {
    return tutorId.hashCode ^
        averageRating.hashCode ^
        totalReviews.hashCode ^
        lastUpdatedAt.hashCode ^
        (ratingDistribution?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'TutorRatingDto('
        'tutorId: $tutorId, '
        'averageRating: ${averageRating.toStringAsFixed(1)}, '
        'totalReviews: $totalReviews'
        ')';
  }

  /// Create a copy with updated fields
  TutorRatingDto copyWith({
    String? tutorId,
    double? averageRating,
    int? totalReviews,
    String? lastUpdatedAt,
    Map<String, int>? ratingDistribution,
  }) {
    return TutorRatingDto(
      tutorId: tutorId ?? this.tutorId,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      ratingDistribution: ratingDistribution ?? this.ratingDistribution,
    );
  }

  bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

/// DTO for platform rating statistics
@JsonSerializable()
class PlatformRatingStatsDto {
  @JsonKey(name: 'total_tutors')
  final int totalTutors;

  @JsonKey(name: 'tutors_with_ratings')
  final int tutorsWithRatings;

  @JsonKey(name: 'total_reviews')
  final int totalReviews;

  @JsonKey(name: 'average_platform_rating')
  final double averagePlatformRating;

  @JsonKey(name: 'rating_distribution')
  final Map<String, int> ratingDistribution;

  @JsonKey(name: 'top_rated_tutors_count')
  final int topRatedTutorsCount;

  PlatformRatingStatsDto({
    required this.totalTutors,
    required this.tutorsWithRatings,
    required this.totalReviews,
    required this.averagePlatformRating,
    required this.ratingDistribution,
    required this.topRatedTutorsCount,
  });

  factory PlatformRatingStatsDto.fromJson(Map<String, dynamic> json) =>
      _$PlatformRatingStatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformRatingStatsDtoToJson(this);

  /// Convert to domain object
  PlatformRatingStats toStats() {
    // Convert string keys to integers
    final intDistribution = <int, int>{};
    for (final entry in ratingDistribution.entries) {
      final key = int.tryParse(entry.key);
      if (key != null && key >= 1 && key <= 5) {
        intDistribution[key] = entry.value;
      }
    }

    return PlatformRatingStats(
      totalTutors: totalTutors,
      tutorsWithRatings: tutorsWithRatings,
      totalReviews: totalReviews,
      averagePlatformRating: averagePlatformRating,
      ratingDistribution: intDistribution,
      topRatedTutorsCount: topRatedTutorsCount,
    );
  }

  /// Create from domain object
  factory PlatformRatingStatsDto.fromStats(PlatformRatingStats stats) {
    // Convert integer keys to strings
    final stringDistribution = <String, int>{};
    for (final entry in stats.ratingDistribution.entries) {
      stringDistribution[entry.key.toString()] = entry.value;
    }

    return PlatformRatingStatsDto(
      totalTutors: stats.totalTutors,
      tutorsWithRatings: stats.tutorsWithRatings,
      totalReviews: stats.totalReviews,
      averagePlatformRating: stats.averagePlatformRating,
      ratingDistribution: stringDistribution,
      topRatedTutorsCount: stats.topRatedTutorsCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlatformRatingStatsDto &&
        other.totalTutors == totalTutors &&
        other.tutorsWithRatings == tutorsWithRatings &&
        other.totalReviews == totalReviews &&
        other.averagePlatformRating == averagePlatformRating &&
        _mapEquals(other.ratingDistribution, ratingDistribution) &&
        other.topRatedTutorsCount == topRatedTutorsCount;
  }

  @override
  int get hashCode {
    return totalTutors.hashCode ^
        tutorsWithRatings.hashCode ^
        totalReviews.hashCode ^
        averagePlatformRating.hashCode ^
        ratingDistribution.hashCode ^
        topRatedTutorsCount.hashCode;
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
    return 'PlatformRatingStatsDto('
        'tutors: $totalTutors, '
        'withRatings: $tutorsWithRatings, '
        'avgRating: ${averagePlatformRating.toStringAsFixed(1)}'
        ')';
  }
}
