import 'package:dartz/dartz.dart';

import '../entities/tutor_rating_entity.dart';
import '../failures/review_failures.dart';

/// Repository interface for tutor rating aggregate operations.
/// Handles the aggregate rating data that summarizes all reviews for a tutor.
abstract class TutorRatingRepository {
  /// Get current aggregate rating for a tutor.
  /// Returns current average rating, total reviews, and rating distribution.
  Future<Either<ReviewFailure, TutorRatingEntity?>> findByTutorId(
    String tutorId,
  );

  /// Update tutor's aggregate rating data.
  /// Called when a new review is added, updated, or deleted.
  Future<Either<ReviewFailure, TutorRatingEntity>> updateRating(
    TutorRatingEntity tutorRating,
  );

  /// Create initial rating record for a new tutor.
  /// Called when a tutor receives their first review.
  Future<Either<ReviewFailure, TutorRatingEntity>> createInitialRating(
    String tutorId,
    int firstRating,
  );

  /// Increment review count and update average rating.
  /// Atomic operation for adding a new review.
  Future<Either<ReviewFailure, TutorRatingEntity>> addReviewRating(
    String tutorId,
    int newRating,
  );

  /// Update rating when an existing review is modified.
  /// Atomic operation for updating a review's rating.
  Future<Either<ReviewFailure, TutorRatingEntity>> updateReviewRating(
    String tutorId,
    int oldRating,
    int newRating,
  );

  /// Remove a review's rating from the aggregate.
  /// Atomic operation for deleting a review.
  Future<Either<ReviewFailure, TutorRatingEntity?>> removeReviewRating(
    String tutorId,
    int removedRating,
  );

  /// Recalculate aggregate rating from all reviews.
  /// Used for data consistency checks and corrections.
  Future<Either<ReviewFailure, TutorRatingEntity>> recalculateRating(
    String tutorId,
  );

  /// Get tutors with highest ratings.
  /// Used for featured/top-rated tutor listings.
  Future<Either<ReviewFailure, List<TutorRatingEntity>>> getTopRatedTutors({
    int limit = 10,
    double minRating = 4.0,
    int minReviews = 5,
  });

  /// Get tutors with most reviews.
  /// Used for popular tutor listings.
  Future<Either<ReviewFailure, List<TutorRatingEntity>>> getMostReviewedTutors({
    int limit = 10,
    int minReviews = 10,
  });

  /// Update rating distribution for a tutor.
  /// Updates the count of reviews for each rating level (1-5 stars).
  Future<Either<ReviewFailure, TutorRatingEntity>> updateRatingDistribution(
    String tutorId,
    Map<int, int> distribution,
  );

  /// Get aggregate statistics across all tutors.
  /// Used for platform analytics and reporting.
  Future<Either<ReviewFailure, PlatformRatingStats>> getPlatformStats();

  /// Check if tutor has any ratings.
  /// Used to determine if tutor profile should show rating section.
  Future<Either<ReviewFailure, bool>> hasRatings(String tutorId);

  /// Delete all rating data for a tutor.
  /// Used when a tutor account is deleted.
  Future<Either<ReviewFailure, void>> deleteRatingData(String tutorId);

  /// Get tutors needing rating recalculation.
  /// Used for maintenance and data integrity tasks.
  Future<Either<ReviewFailure, List<String>>> getTutorsNeedingRecalculation();

  /// Mark tutor's rating as verified/calculated.
  /// Used to track which ratings have been recently verified.
  Future<Either<ReviewFailure, void>> markAsCalculated(
    String tutorId,
    DateTime calculatedAt,
  );
}

/// Platform-wide rating statistics.
class PlatformRatingStats {
  const PlatformRatingStats({
    required this.totalTutors,
    required this.tutorsWithRatings,
    required this.totalReviews,
    required this.averagePlatformRating,
    required this.ratingDistribution,
    required this.topRatedTutorsCount,
  });

  final int totalTutors;
  final int tutorsWithRatings;
  final int totalReviews;
  final double averagePlatformRating;
  final Map<int, int> ratingDistribution;
  final int topRatedTutorsCount; // Tutors with 4.5+ rating

  /// Get percentage of tutors with ratings.
  double get tutorsWithRatingsPercentage {
    if (totalTutors == 0) return 0.0;
    return (tutorsWithRatings / totalTutors) * 100.0;
  }

  /// Get percentage of highly rated tutors.
  double get topRatedPercentage {
    if (tutorsWithRatings == 0) return 0.0;
    return (topRatedTutorsCount / tutorsWithRatings) * 100.0;
  }

  /// Get average reviews per rated tutor.
  double get averageReviewsPerTutor {
    if (tutorsWithRatings == 0) return 0.0;
    return totalReviews / tutorsWithRatings;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlatformRatingStats &&
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
    return 'PlatformRatingStats('
        'tutors: $totalTutors, '
        'withRatings: $tutorsWithRatings, '
        'avgRating: ${averagePlatformRating.toStringAsFixed(1)}'
        ')';
  }
}
