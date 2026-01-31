import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String email;
  final String role;
  final String name;
  final String phone;
  final String speciality;
  final String address;
  final String? profileImage;

  const ProfileEntity({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    required this.phone,
    required this.speciality,
    required this.address,
    this.profileImage,
  });

  @override
  List<Object?> get props => [id, email, role, name, phone, speciality, address, profileImage];
}
