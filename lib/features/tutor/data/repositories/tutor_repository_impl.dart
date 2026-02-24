import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/tutor_entity.dart';
import '../../domain/entities/availability_slot_entity.dart';
import '../../domain/repositories/tutor_repository.dart';
import '../datasources/tutor_remote_datasource.dart';
import '../models/availability_slot_model.dart';

/// Implementation of TutorRepository
class TutorRepositoryImpl implements TutorRepository {
  final TutorRemoteDataSource remoteDataSource;

  TutorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TutorEntity>>> getTutors({
    int page = 1,
    int limit = 10,
    String? search,
    String? speciality,
    String? sortBy,
    String? order,
  }) async {
    try {
      final tutors = await remoteDataSource.getTutors(
        page: page,
        limit: limit,
        search: search,
        speciality: speciality,
        sortBy: sortBy,
        order: order,
      );
      return Either.right(tutors);
    } catch (e) {
      return Either.left(
        ServerFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, TutorEntity>> getTutorById(String id) async {
    try {
      final tutor = await remoteDataSource.getTutorById(id);
      return Either.right(tutor);
    } catch (e) {
      return Either.left(
        ServerFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, List<AvailabilitySlotEntity>>> getMyAvailability({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final slots = await remoteDataSource.getMyAvailability(
        startDate: startDate,
        endDate: endDate,
      );
      return Either.right(slots);
    } catch (e) {
      return Either.left(
        ServerFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, void>> setAvailability(
    List<AvailabilitySlotEntity> slots,
  ) async {
    try {
      final models = slots
          .map(
            (s) => AvailabilitySlotModel(
              id: s.id,
              tutorId: s.tutorId,
              startTime: s.startTime,
              endTime: s.endTime,
              isBooked: s.isBooked,
            ),
          )
          .toList();
      await remoteDataSource.setAvailability(models);
      return Either.right(null);
    } catch (e) {
      return Either.left(
        ServerFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, void>> submitForVerification() async {
    try {
      await remoteDataSource.submitForVerification();
      return Either.right(null);
    } catch (e) {
      return Either.left(
        ServerFailure(e.toString().replaceAll('Exception: ', '')),
      );
    }
  }
}
