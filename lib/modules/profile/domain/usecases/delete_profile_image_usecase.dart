import 'package:dartz/dartz.dart';

import '../entities/profile_entity.dart';
import '../failures/profile_failures.dart';
import '../repositories/profile_repository.dart';

/// Use case for deleting the user's profile image.
class DeleteProfileImageUseCase {
  final ProfileRepository _repository;

  const DeleteProfileImageUseCase(this._repository);

  Future<Either<ProfileFailure, ProfileEntity>> call() async {
    return _repository.deleteProfileImage();
  }
}
