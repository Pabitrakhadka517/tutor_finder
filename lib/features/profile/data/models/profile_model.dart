import 'package:hive/hive.dart';
import '../../domain/entities/profile_entity.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 1) // Unique ID for ProfileModel
class ProfileModel extends ProfileEntity {
  @HiveField(0) final String id;
  @HiveField(1) final String email;
  @HiveField(2) final String role;
  @HiveField(3) final String name;
  @HiveField(4) final String phone;
  @HiveField(5) final String speciality;
  @HiveField(6) final String address;
  @HiveField(7) final String? profileImage;

  const ProfileModel({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    required this.phone,
    required this.speciality,
    required this.address,
    this.profileImage,
  }) : super(
    id: id, 
    email: email, 
    role: role,
    name: name, 
    phone: phone, 
    speciality: speciality, 
    address: address, 
    profileImage: profileImage
  );

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      speciality: json['speciality'] ?? '',
      address: json['address'] ?? '',
      profileImage: json['profileImage'],
    );
  }
  
  // For Hive to save entity directly if needed, or convert entity to model
  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      email: entity.email,
      role: entity.role,
      name: entity.name,
      phone: entity.phone,
      speciality: entity.speciality,
      address: entity.address,
      profileImage: entity.profileImage,
    );
  }
}
