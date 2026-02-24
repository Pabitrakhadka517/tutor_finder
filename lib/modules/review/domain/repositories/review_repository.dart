import 'package:dartz/dartz.dart';

import '../entities/review_entity.dart';
import '../failures/review_failures.dart';

/// Repository interface for review operations.
/// Defines contracts for all review data operations following Clean Architecture.
abstract class ReviewRepository {
  /// Create a new review for a completed booking.
  /// Business rule: Only one review per booking is allowed.
  Future<Either<ReviewFailure, ReviewEntity>> createReview(ReviewEntity review);

  /// Find review by booking ID.
  /// Returns null if no review exists for the booking.
  Future<Either<ReviewFailure, ReviewEntity?>> findByBooking(String bookingId);

  /// Get all reviews for a specific tutor.
  /// Results are paginated and sorted by creation date (newest first).
  Future<Either<ReviewFailure, List<ReviewEntity>>> findByTutor(
    String tutorId, {
    int page = 1,
    int limit = 20,
    String? searchQuery,
  });

  /// Get all reviews created by a specific student.
  /// Useful for displaying student's review history.
  Future<Either<ReviewFailure, List<ReviewEntity>>> findByStudent(
    String studentId, {
    int page = 1,
    int limit = 20,
  });

  /// Get a specific review by ID.
  Future<Either<ReviewFailure, ReviewEntity>> getReviewById(String reviewId);

  /// Update an existing review.
  /// Business rule: Only the review author can update within 24 hours.
  Future<Either<ReviewFailure, ReviewEntity>> updateReview(ReviewEntity review);

  /// Delete a review (soft delete).
  /// Business rule: Only the review author or admin can delete.
  Future<Either<ReviewFailure, void>> deleteReview(
    String reviewId,
    String userId,
  );

  /// Check if a review exists for a specific booking.
  /// Used to enforce one-review-per-booking rule.
  Future<Either<ReviewFailure, bool>> existsByBooking(String bookingId);

  /// Get reviews with student information joined.
  /// Returns reviews with populated student name and avatar for display.
  Future<Either<ReviewFailure, List<ReviewWithStudentInfo>>>
  getReviewsWithStudentInfo(
    String tutorId, {
    int page = 1,
    int limit = 20,
    bool includeComment = true,
  });

  /// Search reviews by content.
  /// Searches in review comments using text search.
  Future<Either<ReviewFailure, List<ReviewEntity>>> searchReviews(
    String query, {
    String? tutorId,
    int page = 1,
    int limit = 20,
  });

  /// Get recent reviews across the platform.
  /// Used for analytics and moderation purposes.
  Future<Either<ReviewFailure, List<ReviewEntity>>> getRecentReviews({
    int limit = 50,
    DateTime? since,
  });

  /// Get review statistics for a tutor.
  /// Returns count by rating, average, etc.
  Future<Either<ReviewFailure, ReviewStatistics>> getReviewStatistics(
    String tutorId,
  );

  /// Check if user can access/view a specific review.
  /// Business rule: Students can view their own reviews, tutors can view reviews about them.
  Future<Either<ReviewFailure, bool>> canUserAccessReview(
    String reviewId,
    String userId,
  );
}

/// Review with student information for display purposes.
class ReviewWithStudentInfo {
  const ReviewWithStudentInfo({
    required this.review,
    required this.studentName,
    this.studentAvatar,
  });

  final ReviewEntity review;
  final String studentName;
  final String? studentAvatar;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewWithStudentInfo &&
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
    return 'ReviewWithStudentInfo('
        'review: ${review.id}, '
        'student: $studentName'
        ')';
  }
}

/// Review statistics for a tutor.
class ReviewStatistics {
  const ReviewStatistics({
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
    required this.recentReviewsCount,
    required this.positiveReviewsPercentage,
  });

  final int totalReviews;
  final double averageRating;
  final Map<int, int> ratingDistribution; // {1: count, 2: count, etc.}
  final int recentReviewsCount; // Reviews in last 30 days
  final double positiveReviewsPercentage; // 4-5 star reviews

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewStatistics &&
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
    return 'ReviewStatistics('
        'total: $totalReviews, '
        'average: ${averageRating.toStringAsFixed(1)}, '
        'positive: ${positiveReviewsPercentage.toStringAsFixed(1)}%'
        ')';
  }
}
