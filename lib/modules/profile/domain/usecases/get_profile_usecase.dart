import 'package:dartz/dartz.dart';

import '../entities/profile_entity.dart';
import '../failures/profile_failures.dart';
import '../repositories/profile_repository.dart';

/// Use case for fetching the current user's profile.
/// Tries remote first, falls back to cache on failure.
class GetProfileUseCase {
  final ProfileRepository _repository;

  const GetProfileUseCase(this._repository);

  Future<Either<ProfileFailure, ProfileEntity>> call() async {
    return _repository.getProfile();
  }

  /// Get cached profile (for offline scenarios or quick display).
  Future<Either<ProfileFailure, ProfileEntity>> getCached() async {
    return _repository.getCachedProfile();
  }
}
