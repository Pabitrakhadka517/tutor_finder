import '../../../core/utils/either.dart';
import '../../../core/error/failures.dart';
import 'entities/study_resource_entity.dart';

abstract class StudyRepository {
  /// Get public study resources (optionally filter by category)
  Future<Either<Failure, List<StudyResourceEntity>>> getResources({
    String? category,
  });

  /// Get tutor's own resources
  Future<Either<Failure, List<StudyResourceEntity>>> getMyResources();

  /// Upload a new study resource (multipart)
  Future<Either<Failure, StudyResourceEntity>> uploadResource({
    required String title,
    required String category,
    required String type,
    required String filePath,
    bool isPublic,
  });

  /// Delete a study resource
  Future<Either<Failure, void>> deleteResource(String id);
}
