import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/utils/either.dart';
import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

/// Use case to get the current GPS location and reverse geocode it
class GetCurrentLocationUseCase implements UseCase<LocationEntity, NoParams> {
  final ILocationRepository repository;

  GetCurrentLocationUseCase(this.repository);

  @override
  Future<Either<Failure, LocationEntity>> call(NoParams params) {
    return repository.getCurrentLocation();
  }
}
