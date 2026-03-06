import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/student_profile_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_remote_datasource.dart';
import '../models/student_profile_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource remoteDataSource;

  StudentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, StudentProfileEntity>> getProfile(
    String userId,
  ) async {
    try {
      final data = await remoteDataSource.getProfile(userId);
      final profile = StudentProfileModel.fromJson(data['profile'] ?? data);
      return Either.right(profile);
    } catch (e) {
      return Either.left(
        ServerFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, StudentProfileEntity>> updateProfile(
    StudentProfileEntity profile,
  ) async {
    try {
      final model = StudentProfileModel.fromEntity(profile);
      final data = await remoteDataSource.updateProfile(model.toJson());
      final updated = StudentProfileModel.fromJson(data['profile'] ?? data);
      return Either.right(updated);
    } catch (e) {
      return Either.left(
        ServerFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, List<User>>> getRecommendedTutors({
    int limit = 10,
  }) async {
    try {
      final list = await remoteDataSource.getRecommendedTutors(limit: limit);
      final tutors = list
          .map(
            (json) => User(
              id: json['_id'] ?? json['id'] ?? '',
              email: json['email'] ?? '',
              fullName: json['fullName'] ?? json['name'] ?? '',
              role: UserRole.tutor,
              createdAt: json['createdAt'] != null
                  ? DateTime.parse(json['createdAt'].toString())
                  : DateTime.now(),
            ),
          )
          .toList();
      return Either.right(tutors);
    } catch (e) {
      return Either.left(
        ServerFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, List<User>>> searchTutors({
    required String query,
    String? subject,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final list = await remoteDataSource.searchTutors(
        query: query,
        subject: subject,
        page: page,
        limit: limit,
      );
      final tutors = list
          .map(
            (json) => User(
              id: json['_id'] ?? json['id'] ?? '',
              email: json['email'] ?? '',
              fullName: json['fullName'] ?? json['name'] ?? '',
              role: UserRole.tutor,
              createdAt: json['createdAt'] != null
                  ? DateTime.parse(json['createdAt'].toString())
                  : DateTime.now(),
            ),
          )
          .toList();
      return Either.right(tutors);
    } catch (e) {
      return Either.left(
        ServerFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }
}
