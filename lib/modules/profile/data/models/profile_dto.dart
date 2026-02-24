import 'package:json_annotation/json_annotation.dart';

part 'profile_dto.g.dart';

/// DTO that maps the profile API response from the server.
///
/// Uses `json_serializable` – run `dart run build_runner build` to regenerate
/// the `*.g.dart` file after any change.
@JsonSerializable()
class ProfileDto {
  final String? id;

  @JsonKey(name: '_id')
  final String? mongoId;

  final String email;
  final String? name;
  final String role;
  final String? phone;
  final String? speciality;
  final String? address;

  @JsonKey(name: 'profileImage')
  final String? profileImage;

  final String? theme;

  @JsonKey(name: 'verificationStatus')
  final String? verificationStatus;

  final DateTime? createdAt;

  // ── Tutor-specific fields ───────────────────────────────────────────────
  final String? bio;

  @JsonKey(name: 'hourlyRate')
  final double? hourlyRate;

  @JsonKey(name: 'experienceYears')
  final int? experienceYears;

  final List<String>? subjects;
  final List<String>? languages;

  const ProfileDto({
    this.id,
    this.mongoId,
    required this.email,
    this.name,
    required this.role,
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

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDtoToJson(this);

  /// Returns the best available ID from the response.
  String get resolvedId => id ?? mongoId ?? '';
}
