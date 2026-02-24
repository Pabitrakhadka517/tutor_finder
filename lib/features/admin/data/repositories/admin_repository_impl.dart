import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;
  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ({List<AdminUserEntity> users, int total, int pages})>>
      getAllUsers({int page = 1, int limit = 10, String? role}) async {
    try {
      final result = await remoteDataSource.getAllUsers(
        page: page,
        limit: limit,
        role: role,
      );
      return Either.right(result);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PlatformStatsEntity>> getPlatformStats() async {
    try {
      final result = await remoteDataSource.getPlatformStats();
      return Either.right(result);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> seedTutors({int count = 5}) async {
    try {
      final result = await remoteDataSource.seedTutors(count: count);
      return Either.right(result);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyTutor({
    required String tutorId,
    required String status,
  }) async {
    try {
      await remoteDataSource.verifyTutor(tutorId: tutorId, status: status);
      return Either.right(null);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> getUserById(String id) async {
    try {
      final result = await remoteDataSource.getUserById(id);
      return Either.right(result);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> updateUser({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final result = await remoteDataSource.updateUser(id: id, data: data);
      return Either.right(result);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String id) async {
    try {
      await remoteDataSource.deleteUser(id);
      return Either.right(null);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnnouncementEntity>> createAnnouncement({
    required String title,
    required String content,
    String targetRole = 'ALL',
    String type = 'INFO',
    DateTime? expiresAt,
  }) async {
    try {
      final result = await remoteDataSource.createAnnouncement(
        title: title,
        content: content,
        targetRole: targetRole,
        type: type,
        expiresAt: expiresAt,
      );
      return Either.right(result);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncements() async {
    try {
      final result = await remoteDataSource.getAnnouncements();
      return Either.right(result);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAnnouncement(String id) async {
    try {
      await remoteDataSource.deleteAnnouncement(id);
      return Either.right(null);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }
}
