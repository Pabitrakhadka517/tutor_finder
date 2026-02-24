import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../state/review_state.dart';

class ReviewListNotifier extends StateNotifier<ReviewListState> {
  final ReviewRepository _repository;
  ReviewListNotifier(this._repository) : super(const ReviewListState());

  Future<void> fetchTutorReviews(String tutorId) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getTutorReviews(tutorId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.toString(),
      ),
      (reviews) => state = state.copyWith(
        isLoading: false,
        reviews: reviews,
        totalReviews: reviews.length,
      ),
    );
  }
}

class CreateReviewNotifier extends StateNotifier<CreateReviewState> {
  final ReviewRepository _repository;
  CreateReviewNotifier(this._repository) : super(const CreateReviewState());

  Future<bool> submitReview({
    required String bookingId,
    String tutorId = '',
    String studentId = '',
    required int rating,
    String? comment,
  }) async {
    state = const CreateReviewState(isLoading: true);

    final review = ReviewEntity.create(
      bookingId: bookingId,
      tutorId: tutorId,
      studentId: studentId,
      rating: rating,
      comment: comment,
    );

    final result = await _repository.createReview(review);

    return result.fold(
      (failure) {
        state = CreateReviewState(
          isLoading: false,
          errorMessage: failure.toString(),
        );
        return false;
      },
      (_) {
        state = const CreateReviewState(isLoading: false, success: true);
        return true;
      },
    );
  }

  void reset() => state = const CreateReviewState();
}
