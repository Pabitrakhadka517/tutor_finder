import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/tutor_entity.dart';
import '../repositories/tutor_repository.dart';

/// Use case for getting a single tutor profile
class GetTutorByIdUseCase implements UseCase<TutorEntity, String> {
  final TutorRepository repository;

  GetTutorByIdUseCase(this.repository);

  @override
  Future<Either<Failure, TutorEntity>> call(String tutorId) {
    return repository.getTutorById(tutorId);
  }
}
