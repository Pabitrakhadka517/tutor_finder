import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../data/services/review_notification_service.dart';
import '../failures/review_failures.dart';
import '../repositories/review_repository.dart';
import '../repositories/tutor_rating_repository.dart';
import '../value_objects/rating.dart';

/// Use case for updating an existing review
///
/// This use case handles:
/// 1. Validation of review ownership and existence
/// 2. Review update with domain validation
/// 3. Automatic tutor rating recalculation if rating changed
/// 4. Notification trigger for review update
/// 5. Proper error handling and state management
@injectable
class UpdateReviewUseCase {
  final ReviewRepository _reviewRepository;
  final TutorRatingRepository _ratingRepository;
  final ReviewNotificationService _notificationService;

  UpdateReviewUseCase(
    this._reviewRepository,
    this._ratingRepository,
    this._notificationService,
  );

  Future<Either<ReviewFailure, Unit>> call(UpdateReviewParams params) async {
    // Step 1: Get existing review to validate ownership and existence
    final existingReviewResult = await _reviewRepository.getReview(
      params.reviewId,
    );

    return existingReviewResult.fold((failure) => Left(failure), (
      existingReview,
    ) async {
      // Step 2: Validate ownership
      if (existingReview.studentId != params.currentUserId) {
        return const Left(
          ReviewFailure.forbiddenError('You can only update your own reviews'),
        );
      }

      // Step 3: Create updated review entity with validation
      try {
        final updatedReview = existingReview.copyWith(
          rating: params.rating.value,
          comment: params.comment,
          updatedAt: DateTime.now(),
        );

        // Step 4: Persist the updated review
        final updateResult = await _reviewRepository.updateReview(
          updatedReview,
        );

        return updateResult.fold((failure) => Left(failure), (_) async {
          // Step 5: Recalculate tutor rating if rating changed
          final ratingChanged = existingReview.rating != params.rating.value;
          if (ratingChanged) {
            final recalculateResult = await _ratingRepository
                .recalculateTutorRating(existingReview.tutorId);

            // Log warning if recalculation fails but continue
            recalculateResult.fold(
              (failure) => print(
                'Warning: Failed to recalculate tutor rating: $failure',
              ),
              (_) => print('Tutor rating recalculated successfully'),
            );
          }

          // Step 6: Send update notifications (non-blocking)
          _notificationService.notifyReviewUpdate(updatedReview).catchError((
            error,
          ) {
            print('Warning: Failed to send review update notification: $error');
          });

          return const Right(unit);
        });
      } catch (e) {
        return Left(
          ReviewFailure.validationError('Failed to update review: $e'),
        );
      }
    });
  }
}

class UpdateReviewParams {
  final String reviewId;
  final String currentUserId;
  final Rating rating;
  final String? comment;

  const UpdateReviewParams({
    required this.reviewId,
    required this.currentUserId,
    required this.rating,
    this.comment,
  });

  @override
  String toString() {
    return 'UpdateReviewParams('
        'reviewId: $reviewId, '
        'currentUserId: $currentUserId, '
        'rating: $rating, '
        'comment: $comment)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UpdateReviewParams &&
        other.reviewId == reviewId &&
        other.currentUserId == currentUserId &&
        other.rating == rating &&
        other.comment == comment;
  }

  @override
  int get hashCode {
    return reviewId.hashCode ^
        currentUserId.hashCode ^
        rating.hashCode ^
        comment.hashCode;
  }
}
