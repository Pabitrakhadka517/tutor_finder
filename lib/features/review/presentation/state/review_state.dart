import '../../domain/entities/review_entity.dart';

class ReviewListState {
  final bool isLoading;
  final List<ReviewEntity> reviews;
  final double averageRating;
  final int totalReviews;
  final String? errorMessage;

  const ReviewListState({
    this.isLoading = false,
    this.reviews = const [],
    this.averageRating = 0,
    this.totalReviews = 0,
    this.errorMessage,
  });

  ReviewListState copyWith({
    bool? isLoading,
    List<ReviewEntity>? reviews,
    double? averageRating,
    int? totalReviews,
    String? errorMessage,
  }) {
    return ReviewListState(
      isLoading: isLoading ?? this.isLoading,
      reviews: reviews ?? this.reviews,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      errorMessage: errorMessage,
    );
  }
}

class CreateReviewState {
  final bool isLoading;
  final bool success;
  final String? errorMessage;

  const CreateReviewState({
    this.isLoading = false,
    this.success = false,
    this.errorMessage,
  });
}
