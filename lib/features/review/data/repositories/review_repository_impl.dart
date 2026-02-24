import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/exceptions/cache_exception.dart';
import '../../../../core/exceptions/network_exception.dart';
import '../../../../core/utils/network_info.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/failures/review_failures.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_local_datasource.dart';
import '../datasources/review_remote_datasouce.dart';
import '../dtos/review_dto.dart';
import '../models/review_search_params.dart';

@LazySingleton(as: ReviewRepository)
class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource _remoteDataSource;
  final ReviewLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  ReviewRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<ReviewFailure, ReviewEntity>> createReview(
    ReviewEntity review,
  ) async {
    try {
      // Check if we have network connectivity
      if (!await _networkInfo.isConnected) {
        return const Left(ReviewFailure.networkError('No internet connection'));
      }

      final reviewDto = ReviewDto.fromEntity(review);
      final result = await _remoteDataSource.createReview(reviewDto);
      final entity = result.toEntity();

      // Cache the created review
      await _localDataSource.cacheReview(result);

      return Right(entity);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } on CacheException catch (e) {
      // Log the cache error but don't fail the operation
      // The review was successfully created, caching is optional
      return _handleReviewFromDto(ReviewDto.fromEntity(review));
    } catch (e) {
      return Left(ReviewFailure.unknownError('Failed to create review: $e'));
    }
  }

  @override
  Future<Either<ReviewFailure, Unit>> updateReview(ReviewEntity review) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(ReviewFailure.networkError('No internet connection'));
      }

      final reviewDto = ReviewDto.fromEntity(review);
      await _remoteDataSource.updateReview(review.id, reviewDto);

      // Update cache
      await _localDataSource.cacheReview(reviewDto);

      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } on CacheException catch (e) {
      // Cache update failed but network update succeeded
      return const Right(unit);
    } catch (e) {
      return Left(ReviewFailure.unknownError('Failed to update review: $e'));
    }
  }

  @override
  Future<Either<ReviewFailure, Unit>> deleteReview(String id) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(ReviewFailure.networkError('No internet connection'));
      }

      await _remoteDataSource.deleteReview(id);

      // Remove from cache
      await _localDataSource.removeCachedReview(id);

      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } on CacheException catch (e) {
      // Cache removal failed but network deletion succeeded
      return const Right(unit);
    } catch (e) {
      return Left(ReviewFailure.unknownError('Failed to delete review: $e'));
    }
  }

  @override
  Future<Either<ReviewFailure, ReviewEntity>> getReview(String id) async {
    try {
      // Try to get from cache first
      final cachedReview = await _localDataSource.getCachedReview(id);
      if (cachedReview != null) {
        return Right(cachedReview.toEntity());
      }

      // If not in cache and no network, return error
      if (!await _networkInfo.isConnected) {
        return const Left(ReviewFailure.networkError('No internet connection'));
      }

      // Fetch from network
      final reviewDto = await _remoteDataSource.getReview(id);
      final entity = reviewDto.toEntity();

      // Cache the result
      await _localDataSource.cacheReview(reviewDto);

      return Right(entity);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } on CacheException catch (e) {
      // If cache fails but we have network data, still return the data
      if (await _networkInfo.isConnected) {
        try {
          final reviewDto = await _remoteDataSource.getReview(id);
          return Right(reviewDto.toEntity());
        } on NetworkException catch (networkE) {
          return Left(_mapNetworkException(networkE));
        }
      }
      return Left(ReviewFailure.cacheError('Failed to retrieve review: $e'));
    } catch (e) {
      return Left(ReviewFailure.unknownError('Failed to get review: $e'));
    }
  }

  @override
  Future<Either<ReviewFailure, ReviewEntity?>> getReviewByBooking(
    String bookingId,
  ) async {
    try {
      // Check cache first using booking ID as key
      final cacheKey = 'booking_$bookingId';
      final cachedReviews = await _localDataSource.getCachedReviews(cacheKey);
      if (cachedReviews != null && cachedReviews.isNotEmpty) {
        return Right(cachedReviews.first.toEntity());
      }

      if (!await _networkInfo.isConnected) {
        return const Left(ReviewFailure.networkError('No internet connection'));
      }

      final reviewDto = await _remoteDataSource.getReviewByBooking(bookingId);

      if (reviewDto == null) {
        return const Right(null);
      }

      // Cache the result
      await _localDataSource.cacheReviews([reviewDto], cacheKey);

      return Right(reviewDto.toEntity());
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } on CacheException catch (e) {
      // Try network if cache fails
      if (await _networkInfo.isConnected) {
        try {
          final reviewDto = await _remoteDataSource.getReviewByBooking(
            bookingId,
          );
          return Right(reviewDto?.toEntity());
        } on NetworkException catch (networkE) {
          return Left(_mapNetworkException(networkE));
        }
      }
      return Left(ReviewFailure.cacheError('Failed to retrieve review: $e'));
    } catch (e) {
      return Left(
        ReviewFailure.unknownError('Failed to get review by booking: $e'),
      );
    }
  }

  @override
  Future<Either<ReviewFailure, List<ReviewEntity>>> getTutorReviews(
    String tutorId, {
    int? page,
    int? limit,
  }) async {
    try {
      final cacheKey = 'tutor_${tutorId}_${page ?? 1}_${limit ?? 20}';

      // Try cache first
      final cachedReviews = await _localDataSource.getCachedReviews(cacheKey);
      if (cachedReviews != null) {
        return Right(cachedReviews.map((dto) => dto.toEntity()).toList());
      }

      if (!await _networkInfo.isConnected) {
        return const Left(ReviewFailure.networkError('No internet connection'));
      }

      final reviewDtos = await _remoteDataSource.getTutorReviews(
        tutorId,
        page: page,
        limit: limit,
      );

      // Cache the results
      await _localDataSource.cacheReviews(reviewDtos, cacheKey);

      return Right(reviewDtos.map((dto) => dto.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } on CacheException catch (e) {
      // Try network if cache fails
      if (await _networkInfo.isConnected) {
        try {
          final reviewDtos = await _remoteDataSource.getTutorReviews(
            tutorId,
            page: page,
            limit: limit,
          );
          return Right(reviewDtos.map((dto) => dto.toEntity()).toList());
        } on NetworkException catch (networkE) {
          return Left(_mapNetworkException(networkE));
        }
      }
      return Left(ReviewFailure.cacheError('Failed to retrieve reviews: $e'));
    } catch (e) {
      return Left(
        ReviewFailure.unknownError('Failed to get tutor reviews: $e'),
      );
    }
  }

  @override
  Future<Either<ReviewFailure, List<ReviewEntity>>> getStudentReviews(
    String studentId, {
    int? page,
    int? limit,
  }) async {
    try {
      final cacheKey = 'student_${studentId}_${page ?? 1}_${limit ?? 20}';

      // Try cache first
      final cachedReviews = await _localDataSource.getCachedReviews(cacheKey);
      if (cachedReviews != null) {
        return Right(cachedReviews.map((dto) => dto.toEntity()).toList());
      }

      if (!await _networkInfo.isConnected) {
        return const Left(ReviewFailure.networkError('No internet connection'));
      }

      final reviewDtos = await _remoteDataSource.getStudentReviews(
        studentId,
        page: page,
        limit: limit,
      );

      // Cache the results
      await _localDataSource.cacheReviews(reviewDtos, cacheKey);

      return Right(reviewDtos.map((dto) => dto.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } on CacheException catch (e) {
      // Try network if cache fails
      if (await _networkInfo.isConnected) {
        try {
          final reviewDtos = await _remoteDataSource.getStudentReviews(
            studentId,
            page: page,
            limit: limit,
          );
          return Right(reviewDtos.map((dto) => dto.toEntity()).toList());
        } on NetworkException catch (networkE) {
          return Left(_mapNetworkException(networkE));
        }
      }
      return Left(ReviewFailure.cacheError('Failed to retrieve reviews: $e'));
    } catch (e) {
      return Left(
        ReviewFailure.unknownError('Failed to get student reviews: $e'),
      );
    }
  }

  @override
  Future<Either<ReviewFailure, List<ReviewEntity>>> searchReviews({
    String? tutorId,
    String? studentId,
    String? bookingId,
    int? rating,
    int? minRating,
    int? maxRating,
    String? query,
    String? subject,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    String? sortOrder,
    int? page,
    int? limit,
  }) async {
    try {
      final params = ReviewSearchParams(
        tutorId: tutorId,
        studentId: studentId,
        bookingId: bookingId,
        rating: rating,
        minRating: minRating,
        maxRating: maxRating,
        query: query,
        subject: subject,
        startDate: startDate,
        endDate: endDate,
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
        limit: limit,
      );

      final cacheKey = 'search_${params.hashCode}';

      // Try cache first
      final cachedReviews = await _localDataSource.getCachedReviews(cacheKey);
      if (cachedReviews != null) {
        return Right(cachedReviews.map((dto) => dto.toEntity()).toList());
      }

      if (!await _networkInfo.isConnected) {
        return const Left(ReviewFailure.networkError('No internet connection'));
      }

      final reviewDtos = await _remoteDataSource.searchReviews(params);

      // Cache the results (shorter cache time for searches)
      await _localDataSource.cacheReviews(reviewDtos, cacheKey);

      return Right(reviewDtos.map((dto) => dto.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } on CacheException catch (e) {
      // Try network if cache fails
      if (await _networkInfo.isConnected) {
        try {
          final params = ReviewSearchParams(
            tutorId: tutorId,
            studentId: studentId,
            bookingId: bookingId,
            rating: rating,
            minRating: minRating,
            maxRating: maxRating,
            query: query,
            subject: subject,
            startDate: startDate,
            endDate: endDate,
            sortBy: sortBy,
            sortOrder: sortOrder,
            page: page,
            limit: limit,
          );
          final reviewDtos = await _remoteDataSource.searchReviews(params);
          return Right(reviewDtos.map((dto) => dto.toEntity()).toList());
        } on NetworkException catch (networkE) {
          return Left(_mapNetworkException(networkE));
        }
      }
      return Left(ReviewFailure.cacheError('Failed to search reviews: $e'));
    } catch (e) {
      return Left(ReviewFailure.unknownError('Failed to search reviews: $e'));
    }
  }

  @override
  Future<Either<ReviewFailure, bool>> checkReviewExists(
    String bookingId,
  ) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(ReviewFailure.networkError('No internet connection'));
      }

      final exists = await _remoteDataSource.checkReviewExists(bookingId);
      return Right(exists);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } catch (e) {
      return Left(
        ReviewFailure.unknownError('Failed to check if review exists: $e'),
      );
    }
  }

  ReviewFailure _mapNetworkException(NetworkException e) {
    return e.when(
      connectionError: () =>
          const ReviewFailure.networkError('Connection failed'),
      timeoutError: () => const ReviewFailure.networkError('Request timeout'),
      unauthorizedError: () =>
          const ReviewFailure.unauthorizedError('Authentication required'),
      forbiddenError: (message) =>
          ReviewFailure.forbiddenError(message ?? 'Access denied'),
      notFound: (message) =>
          ReviewFailure.notFoundError(message ?? 'Review not found'),
      badRequest: (message) =>
          ReviewFailure.validationError(message ?? 'Invalid request'),
      conflictError: (message) =>
          ReviewFailure.conflictError(message ?? 'Review already exists'),
      validationError: (message) =>
          ReviewFailure.validationError(message ?? 'Validation failed'),
      rateLimitError: () =>
          const ReviewFailure.networkError('Rate limit exceeded'),
      serverError: (message) =>
          ReviewFailure.serverError(message ?? 'Server error'),
      unknownError: (message) =>
          ReviewFailure.unknownError(message ?? 'Unknown error'),
    );
  }

  Either<ReviewFailure, ReviewEntity> _handleReviewFromDto(ReviewDto dto) {
    try {
      return Right(dto.toEntity());
    } catch (e) {
      return Left(ReviewFailure.unknownError('Failed to process review: $e'));
    }
  }
}
