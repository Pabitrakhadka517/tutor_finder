import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileParams extends Equatable {
  final String name;
  final String phone;
  final String speciality;
  final String address;
  final File? image;

  const UpdateProfileParams({
    required this.name,
    required this.phone,
    required this.speciality,
    required this.address,
    this.image,
  });

  @override
  List<Object?> get props => [name, phone, speciality, address, image];
}

class UpdateProfileUseCase implements UseCase<ProfileEntity, UpdateProfileParams> {
  final IProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(UpdateProfileParams params) {
    return repository.updateProfile(
      name: params.name,
      phone: params.phone,
      speciality: params.speciality,
      address: params.address,
      image: params.image,
    );
  }
}
