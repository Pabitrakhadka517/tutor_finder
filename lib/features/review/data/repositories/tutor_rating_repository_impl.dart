import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/exceptions/cache_exception.dart';
import '../../../../core/exceptions/network_exception.dart';
import '../../../../core/utils/network_info.dart';
import '../../domain/entities/platform_stats_entity.dart';
import '../../domain/entities/tutor_rating_entity.dart';
import '../../domain/failures/tutor_rating_failures.dart';
import '../../domain/repositories/tutor_rating_repository.dart';
import '../datasources/review_local_datasource.dart';
import '../datasources/review_remote_datasouce.dart';
import '../dtos/tutor_rating_dto.dart';

@LazySingleton(as: TutorRatingRepository)
class TutorRatingRepositoryImpl implements TutorRatingRepository {
  final ReviewRemoteDataSource _remoteDataSource;
  final ReviewLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  TutorRatingRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<TutorRatingFailure, TutorRatingEntity>> createTutorRating(
    TutorRatingEntity rating,
  ) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(
          TutorRatingFailure.networkError('No internet connection'),
        );
      }

      final ratingDto = TutorRatingDto.fromEntity(rating);
      final result = await _remoteDataSource.createTutorRating(ratingDto);
      final entity = result.toEntity();

      // Cache the created rating
      await _localDataSource.cacheTutorRating(result);

      return Right(entity);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } on CacheException catch (e) {
      // Cache failed but operation succeeded
      return _handleRatingFromDto(TutorRatingDto.fromEntity(rating));
    } catch (e) {
      return Left(
        TutorRatingFailure.unknownError('Failed to create tutor rating: $e'),
      );
    }
  }

  @override
  Future<Either<TutorRatingFailure, TutorRatingEntity>> updateTutorRating(
    String tutorId,
    TutorRatingEntity rating,
  ) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(
          TutorRatingFailure.networkError('No internet connection'),
        );
      }

      final ratingDto = TutorRatingDto.fromEntity(rating);
      final result = await _remoteDataSource.updateTutorRating(
        tutorId,
        ratingDto,
      );
      final entity = result.toEntity();

      // Update cache
      await _localDataSource.cacheTutorRating(result);

      return Right(entity);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } on CacheException catch (e) {
      // Cache failed but operation succeeded
      return _handleRatingFromDto(TutorRatingDto.fromEntity(rating));
    } catch (e) {
      return Left(
        TutorRatingFailure.unknownError('Failed to update tutor rating: $e'),
      );
    }
  }

  @override
  Future<Either<TutorRatingFailure, TutorRatingEntity>> getTutorRating(
    String tutorId,
  ) async {
    try {
      // Try to get from cache first
      final cachedRating = await _localDataSource.getCachedTutorRating(tutorId);
      if (cachedRating != null) {
        return Right(cachedRating.toEntity());
      }

      // If not in cache and no network, return error
      if (!await _networkInfo.isConnected) {
        return const Left(
          TutorRatingFailure.networkError('No internet connection'),
        );
      }

      // Fetch from network
      final ratingDto = await _remoteDataSource.getTutorRating(tutorId);
      final entity = ratingDto.toEntity();

      // Cache the result
      await _localDataSource.cacheTutorRating(ratingDto);

      return Right(entity);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } on CacheException catch (e) {
      // If cache fails but we have network data, still return the data
      if (await _networkInfo.isConnected) {
        try {
          final ratingDto = await _remoteDataSource.getTutorRating(tutorId);
          return Right(ratingDto.toEntity());
        } on NetworkException catch (networkE) {
          return Left(_mapNetworkException(networkE));
        }
      }
      return Left(
        TutorRatingFailure.cacheError('Failed to retrieve tutor rating: $e'),
      );
    } catch (e) {
      return Left(
        TutorRatingFailure.unknownError('Failed to get tutor rating: $e'),
      );
    }
  }

  @override
  Future<Either<TutorRatingFailure, TutorRatingEntity>> recalculateTutorRating(
    String tutorId,
  ) async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(
          TutorRatingFailure.networkError('No internet connection'),
        );
      }

      final ratingDto = await _remoteDataSource.recalculateTutorRating(tutorId);
      final entity = ratingDto.toEntity();

      // Update cache with new calculation
      await _localDataSource.cacheTutorRating(ratingDto);

      return Right(entity);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } on CacheException catch (e) {
      // Cache failed but recalculation succeeded
      if (await _networkInfo.isConnected) {
        try {
          final ratingDto = await _remoteDataSource.recalculateTutorRating(
            tutorId,
          );
          return Right(ratingDto.toEntity());
        } on NetworkException catch (networkE) {
          return Left(_mapNetworkException(networkE));
        }
      }
      return Left(
        TutorRatingFailure.cacheError(
          'Failed to cache recalculated rating: $e',
        ),
      );
    } catch (e) {
      return Left(
        TutorRatingFailure.unknownError(
          'Failed to recalculate tutor rating: $e',
        ),
      );
    }
  }

  @override
  Future<Either<TutorRatingFailure, List<TutorRatingEntity>>>
  getTopRatedTutors({int? limit}) async {
    try {
      final cacheKey = 'top_rated_${limit ?? 10}';

      // Try cache first
      final cachedRatings = await _localDataSource.getCachedTutorRatings(
        cacheKey,
      );
      if (cachedRatings != null) {
        return Right(cachedRatings.map((dto) => dto.toEntity()).toList());
      }

      if (!await _networkInfo.isConnected) {
        return const Left(
          TutorRatingFailure.networkError('No internet connection'),
        );
      }

      final ratingDtos = await _remoteDataSource.getTopRatedTutors(
        limit: limit,
      );

      // Cache the results
      await _localDataSource.cacheTutorRatings(ratingDtos, cacheKey);

      return Right(ratingDtos.map((dto) => dto.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } on CacheException catch (e) {
      // Try network if cache fails
      if (await _networkInfo.isConnected) {
        try {
          final ratingDtos = await _remoteDataSource.getTopRatedTutors(
            limit: limit,
          );
          return Right(ratingDtos.map((dto) => dto.toEntity()).toList());
        } on NetworkException catch (networkE) {
          return Left(_mapNetworkException(networkE));
        }
      }
      return Left(
        TutorRatingFailure.cacheError(
          'Failed to retrieve top rated tutors: $e',
        ),
      );
    } catch (e) {
      return Left(
        TutorRatingFailure.unknownError('Failed to get top rated tutors: $e'),
      );
    }
  }

  @override
  Future<Either<TutorRatingFailure, List<TutorRatingEntity>>>
  getMostReviewedTutors({int? limit}) async {
    try {
      final cacheKey = 'most_reviewed_${limit ?? 10}';

      // Try cache first
      final cachedRatings = await _localDataSource.getCachedTutorRatings(
        cacheKey,
      );
      if (cachedRatings != null) {
        return Right(cachedRatings.map((dto) => dto.toEntity()).toList());
      }

      if (!await _networkInfo.isConnected) {
        return const Left(
          TutorRatingFailure.networkError('No internet connection'),
        );
      }

      final ratingDtos = await _remoteDataSource.getMostReviewedTutors(
        limit: limit,
      );

      // Cache the results
      await _localDataSource.cacheTutorRatings(ratingDtos, cacheKey);

      return Right(ratingDtos.map((dto) => dto.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } on CacheException catch (e) {
      // Try network if cache fails
      if (await _networkInfo.isConnected) {
        try {
          final ratingDtos = await _remoteDataSource.getMostReviewedTutors(
            limit: limit,
          );
          return Right(ratingDtos.map((dto) => dto.toEntity()).toList());
        } on NetworkException catch (networkE) {
          return Left(_mapNetworkException(networkE));
        }
      }
      return Left(
        TutorRatingFailure.cacheError(
          'Failed to retrieve most reviewed tutors: $e',
        ),
      );
    } catch (e) {
      return Left(
        TutorRatingFailure.unknownError(
          'Failed to get most reviewed tutors: $e',
        ),
      );
    }
  }

  @override
  Future<Either<TutorRatingFailure, PlatformStatsEntity>>
  getPlatformRatingStats() async {
    try {
      // Try cache first
      final cachedStats = await _localDataSource.getCachedPlatformStats();
      if (cachedStats != null) {
        return Right(cachedStats.toEntity());
      }

      if (!await _networkInfo.isConnected) {
        return const Left(
          TutorRatingFailure.networkError('No internet connection'),
        );
      }

      final statsDto = await _remoteDataSource.getPlatformRatingStats();
      final entity = statsDto.toEntity();

      // Cache the result
      await _localDataSource.cachePlatformStats(statsDto);

      return Right(entity);
    } on NetworkException catch (e) {
      return Left(_mapNetworkException(e));
    } on CacheException catch (e) {
      // Try network if cache fails
      if (await _networkInfo.isConnected) {
        try {
          final statsDto = await _remoteDataSource.getPlatformRatingStats();
          return Right(statsDto.toEntity());
        } on NetworkException catch (networkE) {
          return Left(_mapNetworkException(networkE));
        }
      }
      return Left(
        TutorRatingFailure.cacheError('Failed to retrieve platform stats: $e'),
      );
    } catch (e) {
      return Left(
        TutorRatingFailure.unknownError(
          'Failed to get platform rating stats: $e',
        ),
      );
    }
  }

  TutorRatingFailure _mapNetworkException(NetworkException e) {
    return e.when(
      connectionError: () =>
          const TutorRatingFailure.networkError('Connection failed'),
      timeoutError: () =>
          const TutorRatingFailure.networkError('Request timeout'),
      unauthorizedError: () =>
          const TutorRatingFailure.unauthorizedError('Authentication required'),
      forbiddenError: (message) =>
          TutorRatingFailure.forbiddenError(message ?? 'Access denied'),
      notFound: (message) =>
          TutorRatingFailure.notFoundError(message ?? 'Tutor rating not found'),
      badRequest: (message) =>
          TutorRatingFailure.validationError(message ?? 'Invalid request'),
      conflictError: (message) =>
          TutorRatingFailure.conflictError(message ?? 'Rating conflict'),
      validationError: (message) =>
          TutorRatingFailure.validationError(message ?? 'Validation failed'),
      rateLimitError: () =>
          const TutorRatingFailure.networkError('Rate limit exceeded'),
      serverError: (message) =>
          TutorRatingFailure.serverError(message ?? 'Server error'),
      unknownError: (message) =>
          TutorRatingFailure.unknownError(message ?? 'Unknown error'),
    );
  }

  Either<TutorRatingFailure, TutorRatingEntity> _handleRatingFromDto(
    TutorRatingDto dto,
  ) {
    try {
      return Right(dto.toEntity());
    } catch (e) {
      return Left(
        TutorRatingFailure.unknownError('Failed to process tutor rating: $e'),
      );
    }
  }
}
