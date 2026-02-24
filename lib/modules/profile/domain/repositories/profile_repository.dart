import 'package:dartz/dartz.dart';

import '../entities/profile_entity.dart';
import '../failures/profile_failures.dart';

/// Abstract contract that the data-layer repository must implement.
/// Every method returns `Future<Either<ProfileFailure, T>>`.
abstract class ProfileRepository {
  /// Fetch the current user's profile.
  Future<Either<ProfileFailure, ProfileEntity>> getProfile();

  /// Update the current user's profile with given parameters.
  /// Supports multipart upload for profile image.
  Future<Either<ProfileFailure, ProfileEntity>> updateProfile(
    ProfileUpdateParams params,
  );

  /// Update only the theme preference.
  Future<Either<ProfileFailure, ProfileEntity>> updateTheme(String theme);

  /// Delete the current user's profile image.
  Future<Either<ProfileFailure, ProfileEntity>> deleteProfileImage();

  /// Change password (requires current password verification).
  Future<Either<ProfileFailure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// Get cached profile from local storage (for offline access).
  Future<Either<ProfileFailure, ProfileEntity>> getCachedProfile();
}

/// Parameters for updating a profile.
class ProfileUpdateParams {
  final String? name;
  final String? phone;
  final String? speciality;
  final String? address;
  final String? profileImagePath; // File path for new image
  final String? theme;

  // ── Tutor-specific fields ───────────────────────────────────────────────
  final String? bio;
  final double? hourlyRate;
  final int? experienceYears;
  final List<String>? subjects;
  final List<String>? languages;

  const ProfileUpdateParams({
    this.name,
    this.phone,
    this.speciality,
    this.address,
    this.profileImagePath,
    this.theme,
    // Tutor fields
    this.bio,
    this.hourlyRate,
    this.experienceYears,
    this.subjects,
    this.languages,
  });

  /// Returns true if this update contains any tutor-specific data.
  bool get hasTutorFields =>
      bio != null ||
      hourlyRate != null ||
      experienceYears != null ||
      (subjects != null && subjects!.isNotEmpty) ||
      (languages != null && languages!.isNotEmpty);
}
