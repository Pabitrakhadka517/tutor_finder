import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/student_repository.dart';

/// Fetches a list of recommended/featured tutors for the student dashboard.
class FetchRecommendedTutorsUseCase
    implements UseCase<List<User>, FetchRecommendedTutorsParams> {
  final StudentRepository repository;

  FetchRecommendedTutorsUseCase(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(
    FetchRecommendedTutorsParams params,
  ) async {
    return repository.getRecommendedTutors(limit: params.limit);
  }
}

class FetchRecommendedTutorsParams {
  final int limit;
  const FetchRecommendedTutorsParams({this.limit = 10});
}
