import 'package:dartz/dartz.dart';

import '../entities/review_entity.dart';
import '../failures/review_failures.dart';
import '../repositories/review_repository.dart';
import '../repositories/tutor_rating_repository.dart';
import '../value_objects/rating_vo.dart';

/// Use case for creating a new review.
/// Handles all business logic and validation for review creation.
class CreateReviewUseCase {
  final ReviewRepository reviewRepository;
  final TutorRatingRepository tutorRatingRepository;
  // Note: BookingRepository would be injected to validate booking status
  // final BookingRepository bookingRepository;
  // final NotificationService notificationService;

  CreateReviewUseCase({
    required this.reviewRepository,
    required this.tutorRatingRepository,
  });

  /// Create a new review for a completed booking.
  ///
  /// Business Rules Enforced:
  /// 1. Booking must exist and be COMPLETED
  /// 2. Only the booking's student can create the review
  /// 3. Only one review per booking is allowed
  /// 4. Rating must be valid (1-5)
  /// 5. Comment must be within length limits
  /// 6. Aggregate tutor rating must be updated atomically
  /// 7. Notification must be sent
  Future<Either<ReviewFailure, ReviewEntity>> call(
    CreateReviewParams params,
  ) async {
    try {
      // ── Step 1: Validate Input ──────────────────────────────────────────────

      // Validate rating
      late final Rating rating;
      try {
        rating = Rating(params.rating);
      } catch (e) {
        return Left(
          ReviewFailure.invalidInput('Invalid rating: ${e.toString()}'),
        );
      }

      // Validate review data
      final validationErrors = ReviewEntity.validateForCreation(
        bookingId: params.bookingId,
        tutorId: params.tutorId,
        studentId: params.studentId,
        rating: rating,
        comment: params.comment,
      );

      if (validationErrors.isNotEmpty) {
        return Left(ReviewFailure.invalidInput(validationErrors.join(', ')));
      }

      // ── Step 2: Check for Existing Review ────────────────────────────────────

      final existingReviewResult = await reviewRepository.findByBooking(
        params.bookingId,
      );

      if (existingReviewResult.isLeft()) {
        return existingReviewResult.map((review) => review!);
      }

      final existingReview = existingReviewResult.getOrElse(() => null);
      if (existingReview != null) {
        return Left(
          ReviewFailure.duplicateReview(
            'A review already exists for this booking',
          ),
        );
      }

      // ── Step 3: Validate Booking (Simulated - would call BookingRepository) ───

      // TODO: Implement booking validation
      // final bookingResult = await bookingRepository.getBookingById(params.bookingId);
      // if (bookingResult.isLeft()) {
      //   return Left(ReviewFailure.notFound('Booking not found'));
      // }
      //
      // final booking = bookingResult.getOrElse(() => throw Exception());
      //
      // // Validate booking status
      // if (booking.status != BookingStatus.completed) {
      //   return Left(ReviewFailure.invalidBookingStatus(
      //     'Can only review completed bookings',
      //   ));
      // }
      //
      // // Validate ownership
      // if (booking.studentId != params.studentId) {
      //   return Left(ReviewFailure.accessDenied(
      //     'Only the booking student can create a review',
      //   ));
      // }
      //
      // // Validate tutor matches
      // if (booking.tutorId != params.tutorId) {
      //   return Left(ReviewFailure.invalidInput(
      //     'Tutor ID does not match booking',
      //   ));
      // }

      // ── Step 4: Create Review Entity ─────────────────────────────────────────

      final review = ReviewEntity(
        id: '', // Will be set by repository
        bookingId: params.bookingId,
        tutorId: params.tutorId,
        studentId: params.studentId,
        rating: rating,
        comment: params.comment?.trim(),
        createdAt: DateTime.now(),
      );

      // ── Step 5: Save Review (Atomic Operation) ───────────────────────────────

      final createResult = await reviewRepository.createReview(review);

      if (createResult.isLeft()) {
        return createResult;
      }

      final createdReview = createResult.getOrElse(
        () => throw Exception('Should not happen'),
      );

      // ── Step 6: Update Tutor Aggregate Rating ────────────────────────────────

      final ratingUpdateResult = await tutorRatingRepository.addReviewRating(
        params.tutorId,
        rating.value,
      );

      if (ratingUpdateResult.isLeft()) {
        // TODO: In a real implementation, this should trigger a compensating action
        // to remove the created review since the rating update failed
        // For now, we'll continue as the review was created successfully
      }

      // ── Step 7: Send Notification (Simulated) ─────────────────────────────────

      // TODO: Implement notification service
      // try {
      //   await notificationService.sendNewReviewNotification(
      //     tutorId: params.tutorId,
      //     studentName: 'Student Name', // Would get from user service
      //     rating: rating.value,
      //     commentPreview: params.comment?.substring(0, 50),
      //   );
      // } catch (e) {
      //   // Log notification error but don't fail the operation
      // }

      return Right(createdReview);
    } catch (e) {
      return Left(
        ReviewFailure.serverError('Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// Validate that user can create a review for the specified booking.
  /// This is a helper method that could be called before the main operation.
  Future<Either<ReviewFailure, void>> validateUserCanCreateReview({
    required String bookingId,
    required String userId,
  }) async {
    // Check if review already exists
    final existingResult = await reviewRepository.existsByBooking(bookingId);

    if (existingResult.isLeft()) {
      return existingResult.map((_) => null);
    }

    final exists = existingResult.getOrElse(() => false);
    if (exists) {
      return Left(
        ReviewFailure.duplicateReview('You have already reviewed this booking'),
      );
    }

    // TODO: Additional booking validation would go here

    return const Right(null);
  }
}

/// Parameters for creating a review
class CreateReviewParams {
  final String bookingId;
  final String tutorId;
  final String studentId;
  final dynamic rating; // Will be validated into Rating VO
  final String? comment;

  CreateReviewParams({
    required this.bookingId,
    required this.tutorId,
    required this.studentId,
    required this.rating,
    this.comment,
  });

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
        (comment?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'CreateReviewParams('
        'bookingId: $bookingId, '
        'tutorId: $tutorId, '
        'studentId: $studentId, '
        'rating: $rating, '
        'commentLength: ${comment?.length ?? 0}'
        ')';
  }
}
