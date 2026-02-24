import 'package:dartz/dartz.dart';

import '../entities/review_entity.dart';
import '../entities/tutor_rating_entity.dart';
import '../failures/review_failures.dart';
import '../repositories/review_repository.dart';
import '../repositories/tutor_rating_repository.dart';

/// Use case for getting tutor reviews with aggregate rating information.
/// Handles fetching reviews with student information and calculating statistics.
class GetTutorReviewsUseCase {
  final ReviewRepository reviewRepository;
  final TutorRatingRepository tutorRatingRepository;

  GetTutorReviewsUseCase({
    required this.reviewRepository,
    required this.tutorRatingRepository,
  });

  /// Get reviews for a tutor with aggregate rating information.
  ///
  /// Returns:
  /// - Paginated list of reviews with student information
  /// - Aggregate rating statistics
  /// - Review count and distribution
  Future<Either<ReviewFailure, GetTutorReviewsResult>> call(
    GetTutorReviewsParams params,
  ) async {
    try {
      // ── Step 1: Validate Input ──────────────────────────────────────────────

      if (params.tutorId.trim().isEmpty) {
        return Left(ReviewFailure.invalidInput('Tutor ID is required'));
      }

      if (params.page < 1) {
        return Left(ReviewFailure.invalidInput('Page must be greater than 0'));
      }

      if (params.limit < 1 || params.limit > 100) {
        return Left(
          ReviewFailure.invalidInput('Limit must be between 1 and 100'),
        );
      }

      // ── Step 2: Get Reviews with Student Information ─────────────────────────

      final reviewsResult = await reviewRepository.getReviewsWithStudentInfo(
        params.tutorId,
        page: params.page,
        limit: params.limit,
        includeComment: params.includeComments,
      );

      if (reviewsResult.isLeft()) {
        return reviewsResult.map(
          (reviews) => GetTutorReviewsResult(
            reviews: reviews,
            totalReviews: 0,
            averageRating: 0.0,
            ratingDistribution: {},
            hasMore: false,
          ),
        );
      }

      final reviewsWithStudentInfo = reviewsResult.getOrElse(() => []);

      // ── Step 3: Get Aggregate Rating Information ─────────────────────────────

      final ratingResult = await tutorRatingRepository.findByTutorId(
        params.tutorId,
      );

      late final TutorRatingEntity? tutorRating;
      if (ratingResult.isLeft()) {
        tutorRating = null; // No ratings yet
      } else {
        tutorRating = ratingResult.fold((_) => null, (r) => r);
      }

      // ── Step 4: Get Additional Statistics ──────────────────────────────────────

      final statisticsResult = await reviewRepository.getReviewStatistics(
        params.tutorId,
      );

      late final ReviewStatistics? statistics;
      if (statisticsResult.isLeft()) {
        statistics = null;
      } else {
        statistics = statisticsResult.fold((_) => null, (r) => r);
      }

      // ── Step 5: Build Result ──────────────────────────────────────────────────

      final result = GetTutorReviewsResult(
        reviews: reviewsWithStudentInfo,
        totalReviews: tutorRating?.totalReviews ?? 0,
        averageRating: tutorRating?.averageRating ?? 0.0,
        ratingDistribution: tutorRating?.ratingDistribution ?? {},
        hasMore: reviewsWithStudentInfo.length == params.limit,
        tutorRating: tutorRating,
        statistics: statistics,
        qualityDescription: tutorRating?.qualityDescription ?? 'No ratings yet',
        positiveReviewsPercentage: statistics?.positiveReviewsPercentage ?? 0.0,
        recentReviewsCount: statistics?.recentReviewsCount ?? 0,
      );

      return Right(result);
    } catch (e) {
      return Left(
        ReviewFailure.serverError('Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// Get simple review summary without full review details.
  /// Lighter operation for displaying basic tutor rating info.
  Future<Either<ReviewFailure, ReviewSummary>> getReviewSummary(
    String tutorId,
  ) async {
    try {
      final ratingResult = await tutorRatingRepository.findByTutorId(tutorId);

      if (ratingResult.isLeft()) {
        return Right(
          ReviewSummary(
            tutorId: tutorId,
            averageRating: 0.0,
            totalReviews: 0,
            qualityDescription: 'No ratings yet',
            isRatingReliable: false,
          ),
        );
      }

      final tutorRating = ratingResult.getOrElse(() => null);

      if (tutorRating == null) {
        return Right(
          ReviewSummary(
            tutorId: tutorId,
            averageRating: 0.0,
            totalReviews: 0,
            qualityDescription: 'No ratings yet',
            isRatingReliable: false,
          ),
        );
      }

      return Right(
        ReviewSummary(
          tutorId: tutorId,
          averageRating: tutorRating.averageRating,
          totalReviews: tutorRating.totalReviews,
          qualityDescription: tutorRating.qualityDescription,
          isRatingReliable: tutorRating.isRatingReliable,
          mostCommonRating: tutorRating.mostCommonRating,
          positiveReviewsPercentage: tutorRating.positiveReviewsPercentage,
        ),
      );
    } catch (e) {
      return Left(
        ReviewFailure.serverError('Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// Search reviews for a tutor.
  Future<Either<ReviewFailure, List<ReviewEntity>>> searchTutorReviews({
    required String tutorId,
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    if (query.trim().length < 2) {
      return Left(
        ReviewFailure.invalidInput(
          'Search query must be at least 2 characters',
        ),
      );
    }

    return await reviewRepository.searchReviews(
      query.trim(),
      tutorId: tutorId,
      page: page,
      limit: limit,
    );
  }
}

/// Parameters for getting tutor reviews
class GetTutorReviewsParams {
  final String tutorId;
  final int page;
  final int limit;
  final bool includeComments;
  final String? searchQuery;

  GetTutorReviewsParams({
    required this.tutorId,
    this.page = 1,
    this.limit = 20,
    this.includeComments = true,
    this.searchQuery,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetTutorReviewsParams &&
        other.tutorId == tutorId &&
        other.page == page &&
        other.limit == limit &&
        other.includeComments == includeComments &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    return tutorId.hashCode ^
        page.hashCode ^
        limit.hashCode ^
        includeComments.hashCode ^
        (searchQuery?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'GetTutorReviewsParams('
        'tutorId: $tutorId, '
        'page: $page, '
        'limit: $limit, '
        'includeComments: $includeComments'
        ')';
  }
}

/// Result from getting tutor reviews
class GetTutorReviewsResult {
  final List<ReviewWithStudentInfo> reviews;
  final int totalReviews;
  final double averageRating;
  final Map<int, int> ratingDistribution;
  final bool hasMore;
  final TutorRatingEntity? tutorRating;
  final ReviewStatistics? statistics;
  final String qualityDescription;
  final double positiveReviewsPercentage;
  final int recentReviewsCount;

  GetTutorReviewsResult({
    required this.reviews,
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
    required this.hasMore,
    this.tutorRating,
    this.statistics,
    this.qualityDescription = 'No ratings yet',
    this.positiveReviewsPercentage = 0.0,
    this.recentReviewsCount = 0,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetTutorReviewsResult &&
        _listEquals(other.reviews, reviews) &&
        other.totalReviews == totalReviews &&
        other.averageRating == averageRating &&
        _mapEquals(other.ratingDistribution, ratingDistribution) &&
        other.hasMore == hasMore;
  }

  @override
  int get hashCode {
    return reviews.hashCode ^
        totalReviews.hashCode ^
        averageRating.hashCode ^
        ratingDistribution.hashCode ^
        hasMore.hashCode;
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
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
    return 'GetTutorReviewsResult('
        'reviews: ${reviews.length}, '
        'total: $totalReviews, '
        'average: ${averageRating.toStringAsFixed(1)}, '
        'quality: $qualityDescription'
        ')';
  }
}

/// Simple review summary for display purposes
class ReviewSummary {
  final String tutorId;
  final double averageRating;
  final int totalReviews;
  final String qualityDescription;
  final bool isRatingReliable;
  final int? mostCommonRating;
  final double positiveReviewsPercentage;

  ReviewSummary({
    required this.tutorId,
    required this.averageRating,
    required this.totalReviews,
    required this.qualityDescription,
    required this.isRatingReliable,
    this.mostCommonRating,
    this.positiveReviewsPercentage = 0.0,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewSummary &&
        other.tutorId == tutorId &&
        other.averageRating == averageRating &&
        other.totalReviews == totalReviews &&
        other.qualityDescription == qualityDescription &&
        other.isRatingReliable == isRatingReliable &&
        other.mostCommonRating == mostCommonRating &&
        other.positiveReviewsPercentage == positiveReviewsPercentage;
  }

  @override
  int get hashCode {
    return tutorId.hashCode ^
        averageRating.hashCode ^
        totalReviews.hashCode ^
        qualityDescription.hashCode ^
        isRatingReliable.hashCode ^
        (mostCommonRating?.hashCode ?? 0) ^
        positiveReviewsPercentage.hashCode;
  }

  @override
  String toString() {
    return 'ReviewSummary('
        'tutorId: $tutorId, '
        'rating: ${averageRating.toStringAsFixed(1)}, '
        'total: $totalReviews, '
        'quality: $qualityDescription'
        ')';
  }
}
