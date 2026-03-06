import 'package:equatable/equatable.dart';

/// Domain entity representing a Tutor Profile
class TutorEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? profileImage;
  final String? speciality;
  final String? address;
  final String? bio;
  final int experienceYears;
  final double hourlyRate;
  final List<String> languages;
  final List<String> subjects;
  final String verificationStatus;
  final int totalClasses;
  final double averageRating;
  final int totalReviews;
  final DateTime? createdAt;

  const TutorEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.profileImage,
    this.speciality,
    this.address,
    this.bio,
    this.experienceYears = 0,
    this.hourlyRate = 0,
    this.languages = const [],
    this.subjects = const [],
    this.verificationStatus = 'PENDING',
    this.totalClasses = 0,
    this.averageRating = 0,
    this.totalReviews = 0,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    phone,
    profileImage,
    speciality,
    address,
    bio,
    experienceYears,
    hourlyRate,
    languages,
    subjects,
    verificationStatus,
    totalClasses,
    averageRating,
    totalReviews,
  ];
}
