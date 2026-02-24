/// Aggregate tutor rating entity containing calculated rating information.
/// Represents the overall rating statistics for a tutor.
class TutorRatingEntity {
  const TutorRatingEntity({
    required this.tutorId,
    required this.averageRating,
    required this.totalReviews,
    required this.lastUpdatedAt,
    this.ratingDistribution,
  });

  final String tutorId;
  final double averageRating;
  final int totalReviews;
  final DateTime lastUpdatedAt;
  final Map<int, int>?
  ratingDistribution; // e.g., {1: 2, 2: 1, 3: 5, 4: 10, 5: 15}

  // ── Business Rules & Calculations ──────────────────────────────────────

  /// Calculate new average rating when adding a new review
  static double calculateNewAverage({
    required double currentAverage,
    required int currentTotal,
    required int newRating,
  }) {
    if (currentTotal < 0) {
      throw ArgumentError('Current total cannot be negative');
    }

    if (newRating < 1 || newRating > 5) {
      throw ArgumentError('New rating must be between 1 and 5');
    }

    if (currentTotal == 0) {
      return newRating.toDouble();
    }

    final totalRatingPoints = currentAverage * currentTotal;
    final newTotalPoints = totalRatingPoints + newRating;
    final newTotal = currentTotal + 1;

    return newTotalPoints / newTotal;
  }

  /// Calculate new average rating when updating an existing review
  static double calculateUpdatedAverage({
    required double currentAverage,
    required int totalReviews,
    required int oldRating,
    required int newRating,
  }) {
    if (totalReviews <= 0) {
      throw ArgumentError('Total reviews must be positive when updating');
    }

    if (oldRating < 1 || oldRating > 5 || newRating < 1 || newRating > 5) {
      throw ArgumentError('Ratings must be between 1 and 5');
    }

    final totalRatingPoints = currentAverage * totalReviews;
    final adjustedTotalPoints = totalRatingPoints - oldRating + newRating;

    return adjustedTotalPoints / totalReviews;
  }

  /// Calculate new average rating when removing a review
  static double? calculateAverageAfterRemoval({
    required double currentAverage,
    required int currentTotal,
    required int removedRating,
  }) {
    if (currentTotal <= 0) {
      throw ArgumentError('Current total must be positive when removing');
    }

    if (removedRating < 1 || removedRating > 5) {
      throw ArgumentError('Removed rating must be between 1 and 5');
    }

    if (currentTotal == 1) {
      return null; // No reviews left
    }

    final totalRatingPoints = currentAverage * currentTotal;
    final newTotalPoints = totalRatingPoints - removedRating;
    final newTotal = currentTotal - 1;

    return newTotalPoints / newTotal;
  }

  /// Get rating quality description
  String get qualityDescription {
    if (averageRating >= 4.5) return 'Excellent';
    if (averageRating >= 4.0) return 'Very Good';
    if (averageRating >= 3.5) return 'Good';
    if (averageRating >= 3.0) return 'Average';
    if (averageRating >= 2.0) return 'Below Average';
    return 'Poor';
  }

  /// Get the most common rating (mode)
  int? get mostCommonRating {
    if (ratingDistribution == null || ratingDistribution!.isEmpty) {
      return null;
    }

    int maxCount = 0;
    int? mostCommon;

    for (final entry in ratingDistribution!.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostCommon = entry.key;
      }
    }

    return mostCommon;
  }

  /// Check if tutor has enough reviews to be considered reliable
  bool get isRatingReliable => totalReviews >= 5;

  /// Get percentage of positive reviews (4-5 stars)
  double get positiveReviewsPercentage {
    if (ratingDistribution == null || totalReviews == 0) {
      return 0.0;
    }

    final positiveCount =
        (ratingDistribution![4] ?? 0) + (ratingDistribution![5] ?? 0);
    return (positiveCount / totalReviews) * 100.0;
  }

  /// Create an updated copy with new rating data
  TutorRatingEntity copyWith({
    String? tutorId,
    double? averageRating,
    int? totalReviews,
    DateTime? lastUpdatedAt,
    Map<int, int>? ratingDistribution,
  }) {
    return TutorRatingEntity(
      tutorId: tutorId ?? this.tutorId,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      ratingDistribution: ratingDistribution ?? this.ratingDistribution,
    );
  }

  /// Create updated rating after adding a new review
  TutorRatingEntity addReview(int newRating) {
    final newAverage = calculateNewAverage(
      currentAverage: averageRating,
      currentTotal: totalReviews,
      newRating: newRating,
    );

    final newDistribution = Map<int, int>.from(ratingDistribution ?? {});
    newDistribution[newRating] = (newDistribution[newRating] ?? 0) + 1;

    return copyWith(
      averageRating: newAverage,
      totalReviews: totalReviews + 1,
      lastUpdatedAt: DateTime.now(),
      ratingDistribution: newDistribution,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TutorRatingEntity &&
        other.tutorId == tutorId &&
        other.averageRating == averageRating &&
        other.totalReviews == totalReviews &&
        other.lastUpdatedAt == lastUpdatedAt;
  }

  @override
  int get hashCode {
    return tutorId.hashCode ^
        averageRating.hashCode ^
        totalReviews.hashCode ^
        lastUpdatedAt.hashCode;
  }

  @override
  String toString() {
    return 'TutorRatingEntity('
        'tutorId: $tutorId, '
        'averageRating: ${averageRating.toStringAsFixed(1)}, '
        'totalReviews: $totalReviews, '
        'quality: $qualityDescription'
        ')';
  }
}
