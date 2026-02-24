import 'package:hive/hive.dart';

part 'profile_hive_model.g.dart';

/// Hive-persisted model for cached profile data.
///
/// This is used for offline access and quick loading when the app starts.
/// All profile data including tutor fields are cached here.
@HiveType(typeId: 11) // Different from UserHiveModel (typeId: 10)
class ProfileHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String role;

  @HiveField(3)
  final String? name;

  @HiveField(4)
  final String? phone;

  @HiveField(5)
  final String? speciality;

  @HiveField(6)
  final String? address;

  @HiveField(7)
  final String? profileImage;

  @HiveField(8)
  final String? theme;

  @HiveField(9)
  final String? verificationStatus;

  @HiveField(10)
  final String? createdAt;

  // ── Tutor-specific fields ───────────────────────────────────────────────
  @HiveField(11)
  final String? bio;

  @HiveField(12)
  final double? hourlyRate;

  @HiveField(13)
  final int? experienceYears;

  @HiveField(14)
  final List<String>? subjects;

  @HiveField(15)
  final List<String>? languages;

  ProfileHiveModel({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.phone,
    this.speciality,
    this.address,
    this.profileImage,
    this.theme,
    this.verificationStatus,
    this.createdAt,
    // Tutor fields
    this.bio,
    this.hourlyRate,
    this.experienceYears,
    this.subjects,
    this.languages,
  });
}
