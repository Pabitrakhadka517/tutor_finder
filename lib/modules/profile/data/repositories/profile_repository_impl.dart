import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/failures/profile_failures.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';
import '../mappers/profile_mapper.dart';

/// Concrete repository that coordinates between remote and local data sources.
///
/// Responsibilities:
/// - Call remote data source
/// - Cache successful responses locally
/// - Handle multipart uploads for images
/// - Map exceptions to domain failures
/// - Provide offline fallback via cache
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;
  final ProfileLocalDataSource _local;

  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remote,
    required ProfileLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  // ── Get Profile ───────────────────────────────────────────────────────────

  @override
  Future<Either<ProfileFailure, ProfileEntity>> getProfile() async {
    return _guard(() async {
      final dto = await _remote.getProfile();
      // Cache for offline access
      await _local.cacheProfile(ProfileMapper.dtoToHive(dto));
      return ProfileMapper.fromDto(dto);
    });
  }

  // ── Get Cached Profile ────────────────────────────────────────────────────

  @override
  Future<Either<ProfileFailure, ProfileEntity>> getCachedProfile() async {
    return _guard(() async {
      final cached = await _local.getCachedProfile();
      if (cached == null) {
        throw const CacheFailure('No cached profile found.');
      }
      return ProfileMapper.fromHive(cached);
    });
  }

  // ── Update Profile ────────────────────────────────────────────────────────

  @override
  Future<Either<ProfileFailure, ProfileEntity>> updateProfile(
    ProfileUpdateParams params,
  ) async {
    return _guard(() async {
      final formData = await _buildFormData(params);
      final dto = await _remote.updateProfile(formData);
      // Update cache
      await _local.cacheProfile(ProfileMapper.dtoToHive(dto));
      return ProfileMapper.fromDto(dto);
    });
  }

  // ── Update Theme ──────────────────────────────────────────────────────────

  @override
  Future<Either<ProfileFailure, ProfileEntity>> updateTheme(
    String theme,
  ) async {
    return _guard(() async {
      final dto = await _remote.updateTheme(theme: theme);
      // Update cache
      await _local.cacheProfile(ProfileMapper.dtoToHive(dto));
      return ProfileMapper.fromDto(dto);
    });
  }

  // ── Delete Profile Image ──────────────────────────────────────────────────

  @override
  Future<Either<ProfileFailure, ProfileEntity>> deleteProfileImage() async {
    return _guard(() async {
      final dto = await _remote.deleteProfileImage();
      // Update cache
      await _local.cacheProfile(ProfileMapper.dtoToHive(dto));
      return ProfileMapper.fromDto(dto);
    });
  }

  // ── Change Password ───────────────────────────────────────────────────────

  @override
  Future<Either<ProfileFailure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return _guard(() async {
      await _remote.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      // No caching needed for password change
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Private helpers
  // ═══════════════════════════════════════════════════════════════════════════

  /// Build FormData for multipart upload.
  Future<FormData> _buildFormData(ProfileUpdateParams params) async {
    final data = <String, dynamic>{};

    // Add regular fields
    if (params.name != null) data['name'] = params.name;
    if (params.phone != null) data['phone'] = params.phone;
    if (params.speciality != null) data['speciality'] = params.speciality;
    if (params.address != null) data['address'] = params.address;
    if (params.theme != null) data['theme'] = params.theme;

    // Add tutor fields
    if (params.bio != null) data['bio'] = params.bio;
    if (params.hourlyRate != null) data['hourlyRate'] = params.hourlyRate;
    if (params.experienceYears != null) {
      data['experienceYears'] = params.experienceYears;
    }
    if (params.subjects != null && params.subjects!.isNotEmpty) {
      data['subjects'] = params.subjects;
    }
    if (params.languages != null && params.languages!.isNotEmpty) {
      data['languages'] = params.languages;
    }

    // Add profile image if provided
    if (params.profileImagePath != null) {
      final file = File(params.profileImagePath!);
      if (file.existsSync()) {
        data['profileImage'] = await MultipartFile.fromFile(
          params.profileImagePath!,
          filename: file.path.split('/').last,
        );
      }
    }

    return FormData.fromMap(data);
  }

  /// Wraps an async operation and converts exceptions into [Left(ProfileFailure)].
  Future<Either<ProfileFailure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      final result = await body();
      return Right(result);
    } on ProfileFailure catch (f) {
      return Left(f);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Maps [DioException] to the appropriate domain [ProfileFailure].
  ProfileFailure _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();
      case DioExceptionType.cancel:
        return const CancelledFailure();
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        return _mapStatusCode(e);
      default:
        return ServerFailure(e.message ?? 'Unknown error');
    }
  }

  ProfileFailure _mapStatusCode(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final message = data is Map
        ? (data['message'] ?? 'Unknown error').toString()
        : 'Unknown error';

    switch (statusCode) {
      case 400:
        return ValidationFailure(message);
      case 401:
        return UnauthorizedFailure(message);
      case 403:
        return ForbiddenFailure(message);
      case 404:
        return NotFoundFailure(message);
      case 413:
        return FileTooLargeFailure(message);
      case 415:
        return UnsupportedFileTypeFailure(message);
      case 500:
        return ServerFailure(message);
      default:
        return ServerFailure('HTTP $statusCode: $message');
    }
  }
}
