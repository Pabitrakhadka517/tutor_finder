import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/student_repository.dart';

/// Search tutors by subject or keyword.
class SearchTutorsUseCase implements UseCase<List<User>, SearchTutorsParams> {
  final StudentRepository repository;

  SearchTutorsUseCase(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(SearchTutorsParams params) async {
    if (params.query.trim().isEmpty) {
      return Either.left(
        const ValidationFailure('Please enter a search query'),
      );
    }
    return repository.searchTutors(
      query: params.query,
      subject: params.subject,
      page: params.page,
      limit: params.limit,
    );
  }
}

class SearchTutorsParams {
  final String query;
  final String? subject;
  final int page;
  final int limit;

  const SearchTutorsParams({
    required this.query,
    this.subject,
    this.page = 1,
    this.limit = 20,
  });
}
