import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/review_repository.dart';
import '../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<ReviewModel> createReview({
    required String bookingId,
    required int rating,
    String? comment,
  });

  Future<TutorReviewsResult> getTutorReviews(String tutorId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final ApiClient apiClient;
  ReviewRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ReviewModel> createReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.createReview(bookingId),
        data: {
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ReviewModel.fromJson(response.data['review']);
      }
      throw ServerException( response.data['message'] ?? 'Failed to create review',
      );
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to create review',
      );
    }
  }

  @override
  Future<TutorReviewsResult> getTutorReviews(String tutorId) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.tutorReviews(tutorId),
      );

      if (response.statusCode == 200) {
        final reviewsJson = response.data['reviews'] as List? ?? [];
        final reviews = reviewsJson
            .map((r) => ReviewModel.fromJson(r as Map<String, dynamic>))
            .toList();

        return TutorReviewsResult(
          averageRating: (response.data['averageRating'] is num)
              ? (response.data['averageRating'] as num).toDouble()
              : 0.0,
          totalReviews: (response.data['totalReviews'] is num)
              ? (response.data['totalReviews'] as num).toInt()
              : reviews.length,
          reviews: reviews,
        );
      }
      throw ServerException( 'Failed to fetch reviews');
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to fetch reviews',
      );
    }
  }
}
