import 'dart:io';
import '../../../../core/utils/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';


abstract class IProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
  Future<Either<Failure, ProfileEntity>> getCachedProfile();
  
  Future<Either<Failure, ProfileEntity>> updateProfile({
    required String name,
    required String phone,
    required String speciality,
    required String address,
    File? image, 
  });
}
