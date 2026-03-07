import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../data/services/review_notification_service.dart';
import '../failures/review_failures.dart';
import '../repositories/review_repository.dart';
import '../repositories/tutor_rating_repository.dart';

/// Use case for deleting a review
///
/// This use case handles:
/// 1. Validation of review ownership and existence
/// 2. Review deletion
/// 3. Automatic tutor rating recalculation
/// 4. Notification trigger for review deletion
/// 5. Proper error handling and cleanup
@injectable
class DeleteReviewUseCase {
  final ReviewRepository _reviewRepository;
  final TutorRatingRepository _ratingRepository;
  final ReviewNotificationService _notificationService;

  DeleteReviewUseCase(
    this._reviewRepository,
    this._ratingRepository,
    this._notificationService,
  );

  Future<Either<ReviewFailure, Unit>> call(DeleteReviewParams params) async {
    // Step 1: Get existing review to validate ownership and get tutor ID
    final existingReviewResult = await _reviewRepository.getReview(
      params.reviewId,
    );

    return existingReviewResult.fold((failure) => Left(failure), (
      existingReview,
    ) async {
      // Step 2: Validate ownership (students can delete their own reviews,
      // admins can delete any review)
      if (!params.isAdmin && existingReview.studentId != params.currentUserId) {
        return const Left(
          ReviewFailure.forbiddenError('You can only delete your own reviews'),
        );
      }

      // Step 3: Delete the review
      final deleteResult = await _reviewRepository.deleteReview(
        params.reviewId,
      );

      return deleteResult.fold((failure) => Left(failure), (_) async {
        // Step 4: Recalculate tutor rating
        final recalculateResult = await _ratingRepository
            .recalculateTutorRating(existingReview.tutorId);

        // Log warning if recalculation fails but continue
        recalculateResult.fold(
          (failure) =>
              print('Warning: Failed to recalculate tutor rating: $failure'),
          (_) => print('Tutor rating recalculated successfully'),
        );

        // Step 5: Send deletion notifications (non-blocking)
        _notificationService
            .notifyReviewDeleted(params.reviewId, existingReview.tutorId)
            .catchError((error) {
              print(
                'Warning: Failed to send review deletion notification: $error',
              );
            });

        return const Right(unit);
      });
    });
  }
}

class DeleteReviewParams {
  final String reviewId;
  final String currentUserId;
  final bool isAdmin;

  const DeleteReviewParams({
    required this.reviewId,
    required this.currentUserId,
    this.isAdmin = false,
  });

  @override
  String toString() {
    return 'DeleteReviewParams('
        'reviewId: $reviewId, '
        'currentUserId: $currentUserId, '
        'isAdmin: $isAdmin)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeleteReviewParams &&
        other.reviewId == reviewId &&
        other.currentUserId == currentUserId &&
        other.isAdmin == isAdmin;
  }

  @override
  int get hashCode =>
      reviewId.hashCode ^ currentUserId.hashCode ^ isAdmin.hashCode;
}
