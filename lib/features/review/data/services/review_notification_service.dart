import 'package:injectable/injectable.dart';

import '../../../../core/services/notification_service.dart';
import '../../domain/entities/review_entity.dart';

abstract class ReviewNotificationService {
  Future<void> notifyNewReview(ReviewEntity review);
  Future<void> notifyReviewUpdate(ReviewEntity review);
  Future<void> notifyReviewDeleted(String reviewId, String tutorId);
  Future<void> notifyRatingRecalculated(String tutorId, double newRating);
}

@LazySingleton(as: ReviewNotificationService)
class ReviewNotificationServiceImpl implements ReviewNotificationService {
  final NotificationService _notificationService;

  ReviewNotificationServiceImpl(this._notificationService);

  @override
  Future<void> notifyNewReview(ReviewEntity review) async {
    try {
      // Notify the tutor about the new review
      await _notificationService.sendNotification(
        userId: review.tutorId,
        type: 'NEW_REVIEW',
        title: 'New Review Received',
        body: 'You have received a new ${review.rating}-star review',
        data: {
          'reviewId': review.id,
          'bookingId': review.bookingId,
          'studentId': review.studentId,
          'rating': review.rating.toString(),
          'hasComment': review.comment != null && review.comment!.isNotEmpty,
        },
      );

      // Send push notification if tutor has enabled them
      await _notificationService.sendPushNotification(
        userId: review.tutorId,
        title: 'New Review',
        body: 'You received a ${review.rating}-star review',
        data: {
          'type': 'NEW_REVIEW',
          'reviewId': review.id,
          'navigation': '/reviews/${review.id}',
        },
      );
    } catch (e) {
      // Log the error but don't fail the operation
      // Notifications are not critical for the review creation process
      print('Failed to send new review notification: $e');
    }
  }

  @override
  Future<void> notifyReviewUpdate(ReviewEntity review) async {
    try {
      // Notify the tutor about the review update
      await _notificationService.sendNotification(
        userId: review.tutorId,
        type: 'REVIEW_UPDATED',
        title: 'Review Updated',
        body: 'A student has updated their review for you',
        data: {
          'reviewId': review.id,
          'bookingId': review.bookingId,
          'studentId': review.studentId,
          'rating': review.rating.toString(),
          'updatedAt': (review.updatedAt ?? DateTime.now()).toIso8601String(),
        },
      );
    } catch (e) {
      print('Failed to send review update notification: $e');
    }
  }

  @override
  Future<void> notifyReviewDeleted(String reviewId, String tutorId) async {
    try {
      // Notify the tutor about the review deletion
      await _notificationService.sendNotification(
        userId: tutorId,
        type: 'REVIEW_DELETED',
        title: 'Review Removed',
        body: 'A review has been removed from your profile',
        data: {
          'reviewId': reviewId,
          'deletedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Failed to send review deletion notification: $e');
    }
  }

  @override
  Future<void> notifyRatingRecalculated(
    String tutorId,
    double newRating,
  ) async {
    try {
      // Notify the tutor about their updated rating
      await _notificationService.sendNotification(
        userId: tutorId,
        type: 'RATING_UPDATED',
        title: 'Rating Updated',
        body:
            'Your overall rating has been updated to ${newRating.toStringAsFixed(1)} stars',
        data: {
          'newRating': newRating.toString(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      // Send special notification for milestone ratings
      if (_isRatingMilestone(newRating)) {
        await _notificationService.sendPushNotification(
          userId: tutorId,
          title: 'Congratulations!',
          body: 'You\'ve reached ${newRating.toStringAsFixed(1)} stars!',
          data: {
            'type': 'RATING_MILESTONE',
            'rating': newRating.toString(),
            'navigation': '/profile/ratings',
          },
        );
      }
    } catch (e) {
      print('Failed to send rating update notification: $e');
    }
  }

  bool _isRatingMilestone(double rating) {
    // Consider ratings of exactly 4.0, 4.5, 5.0 as milestones
    const milestones = [4.0, 4.5, 5.0];
    return milestones.any(
      (milestone) => (rating - milestone).abs() < 0.01,
    ); // Small epsilon for double comparison
  }
}
