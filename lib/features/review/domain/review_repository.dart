import '../../../core/utils/either.dart';
import '../../../core/error/failures.dart';
import 'entities/review_entity.dart';

class TutorReviewsResult {
  final double averageRating;
  final int totalReviews;
  final List<ReviewEntity> reviews;

  const TutorReviewsResult({
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
  });
}

abstract class ReviewRepository {
  Future<Either<Failure, ReviewEntity>> createReview({
    required String bookingId,
    required int rating,
    String? comment,
  });

  Future<Either<Failure, TutorReviewsResult>> getTutorReviews(String tutorId);
}
