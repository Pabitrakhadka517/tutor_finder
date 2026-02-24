import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_entity.dart';

/// Theme options available in the app
enum AppTheme { light, dark, system }

/// Verification status for tutors
enum VerificationStatus { pending, verified, rejected }

/// Pure domain entity for user profile data.
/// Contains both basic user fields and optional tutor-specific fields.
class ProfileEntity extends Equatable {
  final String id;
  final String email;
  final UserRole role;
  final String name;
  final String? phone;
  final String? speciality;
  final String? address;
  final String? profileImage;
  final AppTheme theme;
  final VerificationStatus? verificationStatus;
  final DateTime createdAt;

  // ── Tutor-specific fields (only valid if role == UserRole.tutor) ─────────
  final String? bio;
  final double? hourlyRate;
  final int? experienceYears;
  final List<String> subjects;
  final List<String> languages;

  const ProfileEntity({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    this.phone,
    this.speciality,
    this.address,
    this.profileImage,
    this.theme = AppTheme.system,
    this.verificationStatus,
    required this.createdAt,
    // Tutor fields
    this.bio,
    this.hourlyRate,
    this.experienceYears,
    this.subjects = const [],
    this.languages = const [],
  });

  /// Returns true if this user can have tutor-specific fields
  bool get isTutor => role == UserRole.tutor;

  /// Returns true if profile has a profile image
  bool get hasProfileImage => profileImage != null && profileImage!.isNotEmpty;

  ProfileEntity copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? name,
    String? phone,
    String? speciality,
    String? address,
    String? profileImage,
    AppTheme? theme,
    VerificationStatus? verificationStatus,
    DateTime? createdAt,
    // Tutor fields
    String? bio,
    double? hourlyRate,
    int? experienceYears,
    List<String>? subjects,
    List<String>? languages,
    // Special handling for nullable fields
    bool clearProfileImage = false,
    bool clearPhone = false,
    bool clearSpeciality = false,
    bool clearAddress = false,
    bool clearBio = false,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      name: name ?? this.name,
      phone: clearPhone ? null : (phone ?? this.phone),
      speciality: clearSpeciality ? null : (speciality ?? this.speciality),
      address: clearAddress ? null : (address ?? this.address),
      profileImage: clearProfileImage
          ? null
          : (profileImage ?? this.profileImage),
      theme: theme ?? this.theme,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      // Tutor fields
      bio: clearBio ? null : (bio ?? this.bio),
      hourlyRate: hourlyRate ?? this.hourlyRate,
      experienceYears: experienceYears ?? this.experienceYears,
      subjects: subjects ?? this.subjects,
      languages: languages ?? this.languages,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    role,
    name,
    phone,
    speciality,
    address,
    profileImage,
    theme,
    verificationStatus,
    createdAt,
    bio,
    hourlyRate,
    experienceYears,
    subjects,
    languages,
  ];
}
