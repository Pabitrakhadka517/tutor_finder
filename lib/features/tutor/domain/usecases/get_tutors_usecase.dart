import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/tutor_entity.dart';
import '../repositories/tutor_repository.dart';

/// Use case for getting a list of tutors with optional filters
class GetTutorsUseCase implements UseCase<List<TutorEntity>, GetTutorsParams> {
  final TutorRepository repository;

  GetTutorsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TutorEntity>>> call(GetTutorsParams params) {
    return repository.getTutors(
      page: params.page,
      limit: params.limit,
      search: params.search,
      speciality: params.speciality,
      sortBy: params.sortBy,
      order: params.order,
    );
  }
}

class GetTutorsParams {
  final int page;
  final int limit;
  final String? search;
  final String? speciality;
  final String? sortBy;
  final String? order;

  const GetTutorsParams({
    this.page = 1,
    this.limit = 10,
    this.search,
    this.speciality,
    this.sortBy,
    this.order,
  });
}
