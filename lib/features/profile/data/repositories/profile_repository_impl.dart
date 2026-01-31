import 'dart:io';
import '../../../../core/utils/either.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    try {
      final onlineProfile = await remoteDataSource.getProfile();
      await localDataSource.cacheProfile(onlineProfile);
      return Right(onlineProfile);
    } catch (e) {
      try {
        final localProfile = await localDataSource.getLastProfile();
        return Right(localProfile);
      } catch (cacheError) {
        return Left(CacheFailure('No profile found'));
      }
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> getCachedProfile() async {
    try {
      final localProfile = await localDataSource.getLastProfile();
      return Right(localProfile);
    } catch (e) {
      return Left(CacheFailure('No cached profile found'));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({
    required String name,
    required String phone,
    required String speciality,
    required String address,
    File? image,
  }) async {
    try {
      final fields = {
        'name': name,
        'phone': phone,
        'speciality': speciality,
        'address': address,
      };
      
      final updatedProfile = await remoteDataSource.updateProfile(fields, image);
      await localDataSource.cacheProfile(updatedProfile);
      return Right(updatedProfile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
