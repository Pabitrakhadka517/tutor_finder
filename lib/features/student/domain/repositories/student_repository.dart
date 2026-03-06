import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/student_profile_entity.dart';

/// Repository interface for student-specific operations.
///
/// Implementations live in the data layer; the domain layer only
/// knows about this abstract contract.
abstract class StudentRepository {
  /// Get the student's own profile.
  Future<Either<Failure, StudentProfileEntity>> getProfile(String userId);

  /// Update the student profile.
  Future<Either<Failure, StudentProfileEntity>> updateProfile(
    StudentProfileEntity profile,
  );

  /// Fetch recommended / featured tutors for the student dashboard.
  Future<Either<Failure, List<User>>> getRecommendedTutors({int limit = 10});

  /// Search tutors by subject or keyword.
  Future<Either<Failure, List<User>>> searchTutors({
    required String query,
    String? subject,
    int page = 1,
    int limit = 20,
  });
}
