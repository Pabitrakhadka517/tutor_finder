import 'package:dartz/dartz.dart';

import '../entities/user_entity.dart';
import '../failures/auth_failures.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository _repository;

  const RefreshTokenUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call() async {
    return _repository.refreshToken();
  }
}
