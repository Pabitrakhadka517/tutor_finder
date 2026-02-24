import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../models/profile_dto.dart';
import '../models/profile_hive_model.dart';

/// Pure mapping utilities between data-layer objects and domain entities.
///
/// Centralizes conversion logic and keeps it out of repositories/datasources.
class ProfileMapper {
  ProfileMapper._();

  // ── DTO → Entity ──────────────────────────────────────────────────────────

  static ProfileEntity fromDto(ProfileDto dto) {
    return ProfileEntity(
      id: dto.resolvedId,
      email: dto.email,
      role: _parseUserRole(dto.role),
      name: dto.name ?? '',
      phone: dto.phone,
      speciality: dto.speciality,
      address: dto.address,
      profileImage: dto.profileImage,
      theme: _parseAppTheme(dto.theme),
      verificationStatus: _parseVerificationStatus(dto.verificationStatus),
      createdAt: dto.createdAt ?? DateTime.now(),
      // Tutor fields
      bio: dto.bio,
      hourlyRate: dto.hourlyRate,
      experienceYears: dto.experienceYears,
      subjects: dto.subjects ?? [],
      languages: dto.languages ?? [],
    );
  }

  // ── Hive Model → Entity ──────────────────────────────────────────────────

  static ProfileEntity fromHive(ProfileHiveModel model) {
    return ProfileEntity(
      id: model.id,
      email: model.email,
      role: _parseUserRole(model.role),
      name: model.name ?? '',
      phone: model.phone,
      speciality: model.speciality,
      address: model.address,
      profileImage: model.profileImage,
      theme: _parseAppTheme(model.theme),
      verificationStatus: _parseVerificationStatus(model.verificationStatus),
      createdAt: model.createdAt != null
          ? DateTime.tryParse(model.createdAt!) ?? DateTime.now()
          : DateTime.now(),
      // Tutor fields
      bio: model.bio,
      hourlyRate: model.hourlyRate,
      experienceYears: model.experienceYears,
      subjects: model.subjects ?? [],
      languages: model.languages ?? [],
    );
  }

  // ── Entity → Hive Model (for caching) ────────────────────────────────────

  static ProfileHiveModel toHive(ProfileEntity entity) {
    return ProfileHiveModel(
      id: entity.id,
      email: entity.email,
      role: entity.role.name,
      name: entity.name,
      phone: entity.phone,
      speciality: entity.speciality,
      address: entity.address,
      profileImage: entity.profileImage,
      theme: entity.theme.name,
      verificationStatus: entity.verificationStatus?.name,
      createdAt: entity.createdAt.toIso8601String(),
      // Tutor fields
      bio: entity.bio,
      hourlyRate: entity.hourlyRate,
      experienceYears: entity.experienceYears,
      subjects: entity.subjects.isEmpty ? null : entity.subjects,
      languages: entity.languages.isEmpty ? null : entity.languages,
    );
  }

  // ── DTO → Hive Model (direct conversion) ─────────────────────────────────

  static ProfileHiveModel dtoToHive(ProfileDto dto) {
    return ProfileHiveModel(
      id: dto.resolvedId,
      email: dto.email,
      role: dto.role,
      name: dto.name,
      phone: dto.phone,
      speciality: dto.speciality,
      address: dto.address,
      profileImage: dto.profileImage,
      theme: dto.theme,
      verificationStatus: dto.verificationStatus,
      createdAt: dto.createdAt?.toIso8601String(),
      // Tutor fields
      bio: dto.bio,
      hourlyRate: dto.hourlyRate,
      experienceYears: dto.experienceYears,
      subjects: dto.subjects,
      languages: dto.languages,
    );
  }

  // ── Enum parsing helpers ─────────────────────────────────────────────────

  static UserRole _parseUserRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'tutor':
        return UserRole.tutor;
      case 'student':
      default:
        return UserRole.student;
    }
  }

  static AppTheme _parseAppTheme(String? theme) {
    switch (theme?.toLowerCase()) {
      case 'light':
        return AppTheme.light;
      case 'dark':
        return AppTheme.dark;
      case 'system':
      default:
        return AppTheme.system;
    }
  }

  static VerificationStatus? _parseVerificationStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return VerificationStatus.pending;
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return null;
    }
  }
}
