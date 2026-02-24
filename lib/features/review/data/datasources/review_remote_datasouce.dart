import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/exceptions/network_exception.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../dtos/review_dto.dart';
import '../dtos/tutor_rating_dto.dart';
import '../models/review_search_params.dart';

abstract class ReviewRemoteDataSource {
  Future<ReviewDto> createReview(ReviewDto reviewDto);
  Future<void> updateReview(String id, ReviewDto reviewDto);
  Future<void> deleteReview(String id);
  Future<ReviewDto> getReview(String id);
  Future<ReviewDto?> getReviewByBooking(String bookingId);
  Future<List<ReviewDto>> getTutorReviews(
    String tutorId, {
    int? page,
    int? limit,
  });
  Future<List<ReviewDto>> getStudentReviews(
    String studentId, {
    int? page,
    int? limit,
  });
  Future<List<ReviewDto>> searchReviews(ReviewSearchParams params);
  Future<bool> checkReviewExists(String bookingId);
  Future<List<ReviewDto>> getRecentReviews({int? limit});
  Future<TutorRatingDto> getTutorRating(String tutorId);
  Future<TutorRatingDto> updateTutorRating(
    String tutorId,
    TutorRatingDto ratingDto,
  );
  Future<TutorRatingDto> createTutorRating(TutorRatingDto ratingDto);
  Future<TutorRatingDto> recalculateTutorRating(String tutorId);
  Future<List<TutorRatingDto>> getTopRatedTutors({int? limit});
  Future<List<TutorRatingDto>> getMostReviewedTutors({int? limit});
  Future<PlatformStatsDto> getPlatformRatingStats();
}

@LazySingleton(as: ReviewRemoteDataSource)
class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final DioClient _dioClient;

  ReviewRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ReviewDto> createReview(ReviewDto reviewDto) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.createReview,
        data: reviewDto.toJson(),
      );

      return ReviewDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to create review');
    }
  }

  @override
  Future<void> updateReview(String id, ReviewDto reviewDto) async {
    try {
      await _dioClient.put(
        ApiEndpoints.updateReview.replaceFirst('{id}', id),
        data: reviewDto.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to update review');
    }
  }

  @override
  Future<void> deleteReview(String id) async {
    try {
      await _dioClient.delete(
        ApiEndpoints.deleteReview.replaceFirst('{id}', id),
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to delete review');
    }
  }

  @override
  Future<ReviewDto> getReview(String id) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.getReview.replaceFirst('{id}', id),
      );

      return ReviewDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get review');
    }
  }

  @override
  Future<ReviewDto?> getReviewByBooking(String bookingId) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.getReviewByBooking.replaceFirst('{bookingId}', bookingId),
      );

      if (response.data == null) return null;
      return ReviewDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleError(e, 'Failed to get review by booking');
    }
  }

  @override
  Future<List<ReviewDto>> getTutorReviews(
    String tutorId, {
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dioClient.get(
        ApiEndpoints.getTutorReviews.replaceFirst('{tutorId}', tutorId),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data == null) return [];
      return (response.data['reviews'] as List)
          .map((json) => ReviewDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get tutor reviews');
    }
  }

  @override
  Future<List<ReviewDto>> getStudentReviews(
    String studentId, {
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dioClient.get(
        ApiEndpoints.getStudentReviews.replaceFirst('{studentId}', studentId),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data == null) return [];
      return (response.data['reviews'] as List)
          .map((json) => ReviewDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get student reviews');
    }
  }

  @override
  Future<List<ReviewDto>> searchReviews(ReviewSearchParams params) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.searchReviews,
        queryParameters: params.toMap(),
      );

      if (response.data == null) return [];
      return (response.data['reviews'] as List)
          .map((json) => ReviewDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to search reviews');
    }
  }

  @override
  Future<bool> checkReviewExists(String bookingId) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.checkReviewExists.replaceFirst('{bookingId}', bookingId),
      );

      return response.data?['exists'] ?? false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return false;
      }
      throw _handleError(e, 'Failed to check if review exists');
    }
  }

  @override
  Future<List<ReviewDto>> getRecentReviews({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dioClient.get(
        ApiEndpoints.getRecentReviews,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data == null) return [];
      return (response.data['reviews'] as List)
          .map((json) => ReviewDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get recent reviews');
    }
  }

  @override
  Future<TutorRatingDto> getTutorRating(String tutorId) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.getTutorRating.replaceFirst('{tutorId}', tutorId),
      );

      return TutorRatingDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get tutor rating');
    }
  }

  @override
  Future<TutorRatingDto> updateTutorRating(
    String tutorId,
    TutorRatingDto ratingDto,
  ) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.updateTutorRating.replaceFirst('{tutorId}', tutorId),
        data: ratingDto.toJson(),
      );

      return TutorRatingDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to update tutor rating');
    }
  }

  @override
  Future<TutorRatingDto> createTutorRating(TutorRatingDto ratingDto) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.createTutorRating,
        data: ratingDto.toJson(),
      );

      return TutorRatingDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to create tutor rating');
    }
  }

  @override
  Future<TutorRatingDto> recalculateTutorRating(String tutorId) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.recalculateTutorRating.replaceFirst('{tutorId}', tutorId),
      );

      return TutorRatingDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to recalculate tutor rating');
    }
  }

  @override
  Future<List<TutorRatingDto>> getTopRatedTutors({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dioClient.get(
        ApiEndpoints.getTopRatedTutors,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data == null) return [];
      return (response.data['tutors'] as List)
          .map((json) => TutorRatingDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get top rated tutors');
    }
  }

  @override
  Future<List<TutorRatingDto>> getMostReviewedTutors({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dioClient.get(
        ApiEndpoints.getMostReviewedTutors,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data == null) return [];
      return (response.data['tutors'] as List)
          .map((json) => TutorRatingDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get most reviewed tutors');
    }
  }

  @override
  Future<PlatformStatsDto> getPlatformRatingStats() async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.getPlatformRatingStats,
      );

      return PlatformStatsDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get platform rating stats');
    }
  }

  NetworkException _handleError(DioException e, String defaultMessage) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return const NetworkException.connectionError();
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionTimeout:
        return const NetworkException.timeoutError();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final message = e.response?.data?['message'] ?? defaultMessage;

        switch (statusCode) {
          case 400:
            return NetworkException.badRequest(message);
          case 401:
            return const NetworkException.unauthorizedError();
          case 403:
            return NetworkException.forbiddenError(message);
          case 404:
            return NetworkException.notFound(message);
          case 409:
            return NetworkException.conflictError(message);
          case 422:
            return NetworkException.validationError(message);
          case 429:
            return const NetworkException.rateLimitError();
          case 500:
            return NetworkException.serverError(message);
          default:
            return NetworkException.unknownError(message);
        }
      default:
        return NetworkException.unknownError(defaultMessage);
    }
  }
}
