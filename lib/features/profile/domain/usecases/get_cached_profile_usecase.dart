import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetCachedProfileUseCase implements UseCase<ProfileEntity, NoParams> {
  final IProfileRepository repository;

  GetCachedProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(NoParams params) {
    return repository.getCachedProfile();
  }
}
