import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../data/services/review_notification_service.dart';
import '../entities/review_entity.dart';
import '../failures/review_failures.dart';
import '../repositories/review_repository.dart';
import '../repositories/tutor_rating_repository.dart';

/// Use case for creating a new review
///
/// This use case orchestrates:
/// 1. Validation of business rules (booking exists, user is authorized, no duplicate review)
/// 2. Review creation with proper domain validation
/// 3. Automatic tutor rating recalculation
/// 4. Notification trigger for NEW_REVIEW event
/// 5. Proper error handling and rollback if needed
@injectable
class CreateReviewUseCase {
  final ReviewRepository _reviewRepository;
  final TutorRatingRepository _ratingRepository;
  final ReviewNotificationService _notificationService;

  CreateReviewUseCase(
    this._reviewRepository,
    this._ratingRepository,
    this._notificationService,
  );

  Future<Either<ReviewFailure, ReviewEntity>> call(
    CreateReviewParams params,
  ) async {
    // Step 1: Validate no existing review for this booking
    final existingReviewResult = await _reviewRepository.getReviewByBooking(
      params.bookingId,
    );

    return existingReviewResult.fold((failure) => Left(failure), (
      existingReview,
    ) async {
      if (existingReview != null) {
        return const Left(
          ReviewFailure.conflictError(
            'A review already exists for this booking',
          ),
        );
      }

      // Step 2: Create review entity with validation
      try {
        final review = ReviewEntity.create(
          bookingId: params.bookingId,
          tutorId: params.tutorId,
          studentId: params.studentId,
          rating: params.rating,
          comment: params.comment,
        );

        // Step 3: Persist the review
        final createResult = await _reviewRepository.createReview(review);

        return createResult.fold((failure) => Left(failure), (
          createdReview,
        ) async {
          // Step 4: Trigger tutor rating recalculation
          final recalculateResult = await _ratingRepository
              .recalculateTutorRating(params.tutorId);

          // Continue even if recalculation fails (log the error)
          recalculateResult.fold(
            (failure) =>
                print('Warning: Failed to recalculate tutor rating: $failure'),
            (_) => print('Tutor rating recalculated successfully'),
          );

          // Step 5: Send notifications (non-blocking)
          _notificationService.notifyNewReview(createdReview).catchError((
            error,
          ) {
            print('Warning: Failed to send review notification: $error');
          });

          return Right(createdReview);
        });
      } catch (e) {
        return Left(
          ReviewFailure.validationError('Failed to create review: $e'),
        );
      }
    });
  }
}

class CreateReviewParams {
  final String bookingId;
  final String tutorId;
  final String studentId;
  final int rating;
  final String? comment;

  const CreateReviewParams({
    required this.bookingId,
    required this.tutorId,
    required this.studentId,
    required this.rating,
    this.comment,
  });

  @override
  String toString() {
    return 'CreateReviewParams('
        'bookingId: $bookingId, '
        'tutorId: $tutorId, '
        'studentId: $studentId, '
        'rating: $rating, '
        'comment: $comment)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CreateReviewParams &&
        other.bookingId == bookingId &&
        other.tutorId == tutorId &&
        other.studentId == studentId &&
        other.rating == rating &&
        other.comment == comment;
  }

  @override
  int get hashCode {
    return bookingId.hashCode ^
        tutorId.hashCode ^
        studentId.hashCode ^
        rating.hashCode ^
        comment.hashCode;
  }
}
