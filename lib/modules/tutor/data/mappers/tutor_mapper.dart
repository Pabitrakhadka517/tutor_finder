import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../../domain/entities/availability_slot_entity.dart';
import '../../domain/entities/tutor_entity.dart';
import '../../domain/entities/tutor_list_result_entity.dart';
import '../../domain/entities/tutor_search_params.dart';
import '../models/availability_slot_dto.dart';
import '../models/tutor_detail_dto.dart';
import '../models/tutor_dto.dart';
import '../models/tutor_hive_model.dart';
import '../models/tutor_list_response_dto.dart';

/// Mapper class for converting between different data representations.
/// Handles conversion between DTOs, Entities, and Hive models.
class TutorMapper {
  /// Converts TutorDto to TutorEntity
  static TutorEntity dtoToEntity(TutorDto dto) {
    return TutorEntity(
      id: dto.id,
      profileId: dto.profileId,
      fullName: dto.fullName,
      profileImage: dto.profileImage,
      bio: dto.bio,
      experienceYears: dto.experienceYears,
      hourlyRate: dto.hourlyRate,
      languages: List<String>.from(dto.languages),
      subjects: List<String>.from(dto.subjects),
      rating: dto.rating,
      reviewCount: dto.reviewCount,
      verificationStatus: _mapVerificationStatus(dto.verificationStatus),
      isAvailable: dto.isAvailable,
      createdAt: DateTime.parse(dto.createdAt),
      nextAvailableSlot: dto.nextAvailableSlot != null
          ? _availabilitySlotDtoToEntity(dto.nextAvailableSlot!)
          : null,
      location: dto.location,
      specialization: dto.specialization,
      education: dto.education,
    );
  }

  /// Converts TutorDetailDto to TutorEntity
  static TutorEntity detailDtoToEntity(TutorDetailDto dto) {
    return TutorEntity(
      id: dto.id,
      profileId: dto.profileId,
      fullName: dto.fullName,
      profileImage: dto.profileImage,
      bio: dto.bio,
      experienceYears: dto.experienceYears,
      hourlyRate: dto.hourlyRate,
      languages: List<String>.from(dto.languages),
      subjects: List<String>.from(dto.subjects),
      rating: dto.rating,
      reviewCount: dto.reviewCount,
      verificationStatus: _mapVerificationStatus(dto.verificationStatus),
      isAvailable: dto.isAvailable,
      createdAt: DateTime.parse(dto.createdAt),
      nextAvailableSlot: dto.availabilitySlots.isNotEmpty
          ? _availabilitySlotDtoToEntity(dto.availabilitySlots.first)
          : null,
      location: dto.location,
      specialization: dto.specialization,
      education: dto.education,
    );
  }

  /// Converts TutorListResponseDto to TutorListResultEntity
  static TutorListResultEntity listResponseDtoToEntity(
    TutorListResponseDto dto,
  ) {
    final tutors = dto.data.map((tutorDto) => dtoToEntity(tutorDto)).toList();

    return TutorListResultEntity(
      tutors: tutors,
      total: dto.total,
      page: dto.page,
      totalPages: dto.totalPages,
      limit: dto.limit,
      hasNextPage: dto.hasNextPage,
      hasPreviousPage: dto.hasPreviousPage,
    );
  }

  /// Converts TutorEntity to TutorHiveModel
  static TutorHiveModel entityToHiveModel(TutorEntity entity) {
    return TutorHiveModel(
      id: entity.id,
      profileId: entity.profileId,
      fullName: entity.fullName,
      profileImage: entity.profileImage,
      bio: entity.bio,
      experienceYears: entity.experienceYears,
      hourlyRate: entity.hourlyRate,
      languages: List<String>.from(entity.languages),
      subjects: List<String>.from(entity.subjects),
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      verificationStatus: entity.verificationStatus.name,
      isAvailable: entity.isAvailable,
      cachedAt: DateTime.now(),
      createdAt: entity.createdAt,
      nextAvailableSlot: entity.nextAvailableSlot != null
          ? _availabilitySlotEntityToHiveModel(entity.nextAvailableSlot!)
          : null,
      location: entity.location,
      specialization: entity.specialization,
      education: entity.education,
    );
  }

  /// Converts TutorHiveModel to TutorEntity
  static TutorEntity hiveModelToEntity(TutorHiveModel hiveModel) {
    return TutorEntity(
      id: hiveModel.id,
      profileId: hiveModel.profileId,
      fullName: hiveModel.fullName,
      profileImage: hiveModel.profileImage,
      bio: hiveModel.bio,
      experienceYears: hiveModel.experienceYears,
      hourlyRate: hiveModel.hourlyRate,
      languages: List<String>.from(hiveModel.languages),
      subjects: List<String>.from(hiveModel.subjects),
      rating: hiveModel.rating,
      reviewCount: hiveModel.reviewCount,
      verificationStatus: _mapVerificationStatus(hiveModel.verificationStatus),
      isAvailable: hiveModel.isAvailable,
      createdAt: hiveModel.createdAt,
      nextAvailableSlot: hiveModel.nextAvailableSlot != null
          ? _availabilitySlotHiveModelToEntity(hiveModel.nextAvailableSlot!)
          : null,
      location: hiveModel.location,
      specialization: hiveModel.specialization,
      education: hiveModel.education,
    );
  }

  /// Converts AvailabilitySlotDto to AvailabilitySlotEntity
  static AvailabilitySlotEntity availabilitySlotDtoToEntity(
    AvailabilitySlotDto dto,
  ) {
    return _availabilitySlotDtoToEntity(dto);
  }

  /// Converts AvailabilitySlotEntity to AvailabilitySlotHiveModel
  static AvailabilitySlotHiveModel availabilitySlotEntityToHiveModel(
    AvailabilitySlotEntity entity,
  ) {
    return _availabilitySlotEntityToHiveModel(entity);
  }

  /// Converts AvailabilitySlotHiveModel to AvailabilitySlotEntity
  static AvailabilitySlotEntity availabilitySlotHiveModelToEntity(
    AvailabilitySlotHiveModel hiveModel,
  ) {
    return _availabilitySlotHiveModelToEntity(hiveModel);
  }

  /// Converts list of AvailabilitySlotDto to list of AvailabilitySlotEntity
  static List<AvailabilitySlotEntity> availabilitySlotListDtoToEntity(
    List<AvailabilitySlotDto> dtos,
  ) {
    return dtos.map((dto) => _availabilitySlotDtoToEntity(dto)).toList();
  }

  /// Converts list of AvailabilitySlotEntity to list of AvailabilitySlotHiveModel
  static List<AvailabilitySlotHiveModel> availabilitySlotListEntityToHiveModel(
    List<AvailabilitySlotEntity> entities,
  ) {
    return entities
        .map((entity) => _availabilitySlotEntityToHiveModel(entity))
        .toList();
  }

  /// Converts list of AvailabilitySlotHiveModel to list of AvailabilitySlotEntity
  static List<AvailabilitySlotEntity> availabilitySlotListHiveModelToEntity(
    List<AvailabilitySlotHiveModel> hiveModels,
  ) {
    return hiveModels
        .map((hiveModel) => _availabilitySlotHiveModelToEntity(hiveModel))
        .toList();
  }

  /// Creates a cache key from search parameters for consistent caching
  static String createCacheKey(TutorSearchParams params) {
    final queryMap = params.toQueryMap();
    final queryString = queryMap.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final bytes = utf8.encode(queryString);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Private helper methods

  static VerificationStatus _mapVerificationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return VerificationStatus.verified;
      case 'pending':
        return VerificationStatus.pending;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.unverified;
    }
  }

  static AvailabilitySlotEntity _availabilitySlotDtoToEntity(
    AvailabilitySlotDto dto,
  ) {
    return AvailabilitySlotEntity(
      id: dto.id,
      startTime: DateTime.parse(dto.startTime),
      endTime: DateTime.parse(dto.endTime),
      isBooked: dto.isBooked,
      dayOfWeek: dto.dayOfWeek,
      studentId: dto.studentId,
      lessonId: dto.lessonId,
      note: dto.note,
    );
  }

  static AvailabilitySlotHiveModel _availabilitySlotEntityToHiveModel(
    AvailabilitySlotEntity entity,
  ) {
    return AvailabilitySlotHiveModel(
      id: entity.id,
      startTime: entity.startTime,
      endTime: entity.endTime,
      isBooked: entity.isBooked,
      dayOfWeek: entity.dayOfWeek,
      studentId: entity.studentId,
      lessonId: entity.lessonId,
      note: entity.note,
    );
  }

  static AvailabilitySlotEntity _availabilitySlotHiveModelToEntity(
    AvailabilitySlotHiveModel hiveModel,
  ) {
    return AvailabilitySlotEntity(
      id: hiveModel.id,
      startTime: hiveModel.startTime,
      endTime: hiveModel.endTime,
      isBooked: hiveModel.isBooked,
      dayOfWeek: hiveModel.dayOfWeek,
      studentId: hiveModel.studentId,
      lessonId: hiveModel.lessonId,
      note: hiveModel.note,
    );
  }
}
