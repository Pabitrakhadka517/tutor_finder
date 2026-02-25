import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/review_repository.dart';
import '../state/review_state.dart';

class ReviewListNotifier extends StateNotifier<ReviewListState> {
  final ReviewRepository _repository;
  ReviewListNotifier(this._repository) : super(const ReviewListState());

  Future<void> fetchTutorReviews(String tutorId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getTutorReviews(tutorId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        isLoading: false,
        reviews: data.reviews,
        averageRating: data.averageRating,
        totalReviews: data.totalReviews,
      ),
    );
  }
}

class CreateReviewNotifier extends StateNotifier<CreateReviewState> {
  final ReviewRepository _repository;
  CreateReviewNotifier(this._repository) : super(const CreateReviewState());

  Future<bool> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    state = const CreateReviewState(isLoading: true);

    final result = await _repository.createReview(
      bookingId: bookingId,
      rating: rating,
      comment: comment,
    );

    return result.fold(
      (failure) {
        state = CreateReviewState(
          isLoading: false,
          errorMessage: failure.message,
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
