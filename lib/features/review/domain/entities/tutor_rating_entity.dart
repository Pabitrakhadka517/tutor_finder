import 'package:equatable/equatable.dart';

/// Entity representing the aggregated rating data for a tutor
class TutorRatingEntity extends Equatable {
  final String tutorId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final DateTime lastUpdated;

  const TutorRatingEntity({
    required this.tutorId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.lastUpdated,
  });

  bool get hasReviews => totalReviews > 0;

  String get formattedRating => averageRating.toStringAsFixed(1);

  @override
  List<Object?> get props => [
    tutorId,
    averageRating,
    totalReviews,
    lastUpdated,
  ];

  @override
  String toString() =>
      'TutorRatingEntity(tutorId: $tutorId, avg: $averageRating, total: $totalReviews)';
}
