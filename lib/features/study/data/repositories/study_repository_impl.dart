import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/study_resource_entity.dart';
import '../../domain/study_repository.dart';
import '../datasources/study_remote_datasource.dart';

class StudyRepositoryImpl implements StudyRepository {
  final StudyRemoteDataSource remoteDataSource;
  StudyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<StudyResourceEntity>>> getResources({
    String? category,
  }) async {
    try {
      final result = await remoteDataSource.getResources(category: category);
      return Either.right(result);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudyResourceEntity>>> getMyResources() async {
    try {
      final result = await remoteDataSource.getMyResources();
      return Either.right(result);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudyResourceEntity>> uploadResource({
    required String title,
    required String category,
    required String type,
    required String filePath,
    bool isPublic = true,
  }) async {
    try {
      final result = await remoteDataSource.uploadResource(
        title: title,
        category: category,
        type: type,
        filePath: filePath,
        isPublic: isPublic,
      );
      return Either.right(result);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteResource(String id) async {
    try {
      await remoteDataSource.deleteResource(id);
      return Either.right(null);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }
}
