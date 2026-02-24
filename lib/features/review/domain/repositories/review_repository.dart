import 'package:dartz/dartz.dart';

import '../entities/review_entity.dart';
import '../failures/review_failures.dart';

abstract class ReviewRepository {
  Future<Either<ReviewFailure, ReviewEntity>> createReview(ReviewEntity review);

  Future<Either<ReviewFailure, Unit>> updateReview(ReviewEntity review);

  Future<Either<ReviewFailure, Unit>> deleteReview(String id);

  Future<Either<ReviewFailure, ReviewEntity>> getReview(String id);

  Future<Either<ReviewFailure, ReviewEntity?>> getReviewByBooking(
    String bookingId,
  );

  Future<Either<ReviewFailure, List<ReviewEntity>>> getTutorReviews(
    String tutorId, {
    int? page,
    int? limit,
  });

  Future<Either<ReviewFailure, List<ReviewEntity>>> getStudentReviews(
    String studentId, {
    int? page,
    int? limit,
  });

  Future<Either<ReviewFailure, List<ReviewEntity>>> searchReviews({
    String? tutorId,
    String? studentId,
    String? bookingId,
    int? rating,
    int? minRating,
    int? maxRating,
    String? query,
    String? subject,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    String? sortOrder,
    int? page,
    int? limit,
  });

  Future<Either<ReviewFailure, bool>> checkReviewExists(String bookingId);
}
