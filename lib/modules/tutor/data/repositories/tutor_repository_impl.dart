import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/availability_slot_entity.dart';
import '../../domain/entities/tutor_entity.dart';
import '../../domain/entities/tutor_list_result_entity.dart';
import '../../domain/entities/tutor_search_params.dart';
import '../../domain/failures/tutor_failures.dart';
import '../../domain/repositories/tutor_repository.dart';
import '../datasources/tutor_local_datasource.dart';
import '../datasources/tutor_remote_datasource.dart';
import '../mappers/tutor_mapper.dart';

/// Implementation of TutorRepository that coordinates between remote and local data sources.
/// Handles caching strategies, error mapping, and data transformation.
class TutorRepositoryImpl implements TutorRepository {
  const TutorRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  final TutorRemoteDatasource remoteDatasource;
  final TutorLocalDatasource localDatasource;

  @override
  Future<Either<TutorFailure, TutorListResultEntity>> getTutors(
    TutorSearchParams params,
  ) async {
    try {
      final cacheKey = TutorMapper.createCacheKey(params);

      // Check cache first (only for first page and no specific search)
      if (!params.hasSearch && params.isFirstPage) {
        final cachedResult = await localDatasource.getCachedTutorList(
          cacheKey,
          params.page,
        );
        if (cachedResult != null) {
          // Get individual tutors from cache
          final cachedTutors = <TutorEntity>[];
          for (final tutorId in cachedResult.tutorIds) {
            final cachedTutor = await localDatasource.getCachedTutorDetail(
              tutorId,
            );
            if (cachedTutor != null) {
              cachedTutors.add(TutorMapper.hiveModelToEntity(cachedTutor));
            }
          }

          if (cachedTutors.length == cachedResult.tutorIds.length) {
            // All tutors found in cache
            final result = TutorListResultEntity(
              tutors: cachedTutors,
              total: cachedResult.total,
              page: cachedResult.page,
              totalPages: cachedResult.totalPages,
              limit: cachedResult.limit,
              hasNextPage: cachedResult.hasNextPage,
              hasPreviousPage: cachedResult.hasPreviousPage,
            );
            return Right(result);
          }
        }
      }

      // Fetch from API
      final query = params.toQueryMap();
      final response = await remoteDatasource.getTutors(query);

      // Map to entity
      final result = TutorMapper.listResponseDtoToEntity(response);

      // Cache the result (only cache first page to avoid complexity)
      if (params.isFirstPage && !params.hasSearch) {
        try {
          final tutorHiveModels = result.tutors
              .map((tutor) => TutorMapper.entityToHiveModel(tutor))
              .toList();

          await localDatasource.cacheTutorList(
            tutorHiveModels,
            cacheKey,
            result.page,
            result.total,
            result.totalPages,
          );
        } catch (e) {
          // Cache error should not fail the operation
          print('Cache error: $e');
        }
      }

      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(TutorUnknownFailure.general());
    }
  }

  @override
  Future<Either<TutorFailure, TutorEntity>> getTutorById(String tutorId) async {
    try {
      // Check cache first
      final cachedTutor = await localDatasource.getCachedTutorDetail(tutorId);
      if (cachedTutor != null) {
        return Right(TutorMapper.hiveModelToEntity(cachedTutor));
      }

      // Fetch from API
      final response = await remoteDatasource.getTutorById(tutorId);

      // Map to entity
      final tutor = TutorMapper.detailDtoToEntity(response);

      // Cache the result
      try {
        final tutorHiveModel = TutorMapper.entityToHiveModel(tutor);
        await localDatasource.cacheTutorDetail(tutorHiveModel);
      } catch (e) {
        // Cache error should not fail the operation
        print('Cache error: $e');
      }

      return Right(tutor);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(TutorUnknownFailure.general());
    }
  }

  @override
  Future<Either<TutorFailure, List<AvailabilitySlotEntity>>>
  getMyAvailability() async {
    try {
      // Check cache first
      final cachedSlots = await localDatasource.getCachedMyAvailability();
      if (cachedSlots != null) {
        final slots = TutorMapper.availabilitySlotListHiveModelToEntity(
          cachedSlots,
        );
        return Right(slots);
      }

      // Fetch from API
      final response = await remoteDatasource.getMyAvailability();

      // Map to entities
      final slots = TutorMapper.availabilitySlotListDtoToEntity(response);

      // Cache the result
      try {
        final slotsHiveModels =
            TutorMapper.availabilitySlotListEntityToHiveModel(slots);
        await localDatasource.cacheMyAvailability(slotsHiveModels);
      } catch (e) {
        // Cache error should not fail the operation
        print('Cache error: $e');
      }

      return Right(slots);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(TutorUnknownFailure.general());
    }
  }

  @override
  Future<Either<TutorFailure, void>> setAvailability(
    List<AvailabilitySlotEntity> slots,
  ) async {
    try {
      // Convert slots to API format
      final slotsData = slots
          .map(
            (slot) => {
              'start_time': slot.startTime.toIso8601String(),
              'end_time': slot.endTime.toIso8601String(),
              'day_of_week': slot.dayOfWeek,
              'note': slot.note,
            },
          )
          .toList();

      // Send to API
      await remoteDatasource.setAvailability(slotsData);

      // Clear cached availability to force refresh on next load
      try {
        await localDatasource.cacheMyAvailability([]);
      } catch (e) {
        // Cache error should not fail the operation
        print('Cache clear error: $e');
      }

      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(TutorUnknownFailure.general());
    }
  }

  @override
  Future<Either<TutorFailure, void>> submitVerification() async {
    try {
      await remoteDatasource.submitVerification();
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(TutorUnknownFailure.general());
    }
  }

  @override
  Future<Either<TutorFailure, void>> clearTutorCache() async {
    try {
      await localDatasource.clearTutorCache();
      return const Right(null);
    } catch (e) {
      return Left(TutorCacheFailure.storageError());
    }
  }

  // Private helper methods

  TutorFailure _mapDioExceptionToFailure(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return TutorNetworkFailure.timeout();

      case DioExceptionType.connectionError:
        return TutorNetworkFailure.connectionError();

      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final message = exception.response?.data['message'] ?? 'Request failed';

        switch (statusCode) {
          case 400:
            return TutorValidationFailure(message);
          case 401:
            return TutorAuthFailure.unauthorized();
          case 403:
            return TutorAuthFailure.forbidden();
          case 404:
            return TutorNotFoundFailure.tutorNotFound();
          case 409:
            return TutorBusinessFailure(message);
          case 422:
            return TutorValidationFailure(message);
          case 429:
            return TutorRateLimitFailure.tooManyRequests();
          case 500:
            return TutorServerFailure.general();
          case 502:
          case 503:
          case 504:
            return TutorServerFailure.serviceUnavailable();
          default:
            return TutorServerFailure(message);
        }

      case DioExceptionType.cancel:
        return const TutorNetworkFailure('Request was cancelled');

      default:
        return TutorUnknownFailure.general();
    }
  }
}
