import 'package:dartz/dartz.dart';

import '../entities/user_entity.dart';
import '../failures/auth_failures.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  const GetCurrentUserUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call() async {
    return _repository.getCurrentUser();
  }
}
