import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/utils/either.dart';
import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

/// Parameters for updating location on server
class UpdateLocationParams extends Equatable {
  final LocationEntity location;

  const UpdateLocationParams({required this.location});

  @override
  List<Object?> get props => [location];
}

/// Use case to update user's location on the server
class UpdateLocationUseCase implements UseCase<void, UpdateLocationParams> {
  final ILocationRepository repository;

  UpdateLocationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateLocationParams params) {
    return repository.updateLocationOnServer(params.location);
  }
}
