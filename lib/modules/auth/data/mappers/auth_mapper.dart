import '../../domain/entities/user_entity.dart';
import '../models/auth_response_dto.dart';
import '../models/user_hive_model.dart';

/// Pure mapping utilities between data-layer objects and domain entities.
///
/// Keeps conversion logic centralised and out of repositories/datasources.
class AuthMapper {
  AuthMapper._();

  // ── DTO → Entity ──────────────────────────────────────────────────────────

  static UserEntity fromDto(AuthResponseDto dto) {
    return UserEntity(
      id: dto.resolvedUserId,
      email: dto.resolvedEmail,
      name: dto.resolvedName ?? '',
      role: _parseRole(dto.resolvedRole),
      createdAt: dto.resolvedCreatedAt ?? DateTime.now(),
    );
  }

  // ── Hive Model → Entity ──────────────────────────────────────────────────

  static UserEntity fromHive(UserHiveModel model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      name: model.name,
      role: _parseRole(model.role),
      createdAt: model.createdAt != null
          ? DateTime.tryParse(model.createdAt!) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // ── Entity → Hive Model (for caching) ────────────────────────────────────

  static UserHiveModel toHive(UserEntity entity) {
    return UserHiveModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      role: entity.role.name,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  // ── DTO → Hive Model ─────────────────────────────────────────────────────

  static UserHiveModel dtoToHive(AuthResponseDto dto) {
    return UserHiveModel(
      id: dto.resolvedUserId,
      email: dto.resolvedEmail,
      name: dto.resolvedName ?? '',
      role: dto.resolvedRole,
      createdAt: dto.resolvedCreatedAt?.toIso8601String(),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static UserRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'tutor':
        return UserRole.tutor;
      case 'student':
      default:
        return UserRole.student;
    }
  }
}
