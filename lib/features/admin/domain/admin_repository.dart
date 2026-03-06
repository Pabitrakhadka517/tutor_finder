import '../../../core/utils/either.dart';
import '../../../core/error/failures.dart';
import 'entities/admin_entities.dart';

abstract class AdminRepository {
  /// Get all users (paginated, optional role filter)
  Future<Either<Failure, ({List<AdminUserEntity> users, int total, int pages})>>
      getAllUsers({int page, int limit, String? role});

  /// Get platform statistics
  Future<Either<Failure, PlatformStatsEntity>> getPlatformStats();

  /// Seed tutors (admin-only for testing)
  Future<Either<Failure, String>> seedTutors({int count});

  /// Verify a tutor (VERIFIED, REJECTED, PENDING)
  Future<Either<Failure, void>> verifyTutor({
    required String tutorId,
    required String status,
  });

  /// Get user by ID
  Future<Either<Failure, AdminUserEntity>> getUserById(String id);

  /// Update user
  Future<Either<Failure, AdminUserEntity>> updateUser({
    required String id,
    required Map<String, dynamic> data,
  });

  /// Delete user
  Future<Either<Failure, void>> deleteUser(String id);

  /// Create announcement
  Future<Either<Failure, AnnouncementEntity>> createAnnouncement({
    required String title,
    required String content,
    String targetRole,
    String type,
    DateTime? expiresAt,
  });

  /// Get all announcements
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncements();

  /// Delete announcement
  Future<Either<Failure, void>> deleteAnnouncement(String id);
}
