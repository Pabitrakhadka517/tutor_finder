import 'package:json_annotation/json_annotation.dart';

import 'availability_slot_dto.dart';

part 'tutor_dto.g.dart';

/// Data Transfer Object for tutor information from API.
/// Handles JSON serialization/deserialization with proper field mapping.
@JsonSerializable()
class TutorDto {
  const TutorDto({
    required this.id,
    required this.profileId,
    required this.fullName,
    required this.profileImage,
    required this.bio,
    required this.experienceYears,
    required this.hourlyRate,
    required this.languages,
    required this.subjects,
    required this.rating,
    required this.reviewCount,
    required this.verificationStatus,
    required this.isAvailable,
    required this.createdAt,
    this.nextAvailableSlot,
    this.location,
    this.specialization,
    this.education,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'profile_id')
  final String profileId;

  @JsonKey(name: 'full_name')
  final String fullName;

  @JsonKey(name: 'profile_image')
  final String? profileImage;

  @JsonKey(name: 'bio')
  final String bio;

  @JsonKey(name: 'experience_years')
  final int experienceYears;

  @JsonKey(name: 'hourly_rate')
  final double hourlyRate;

  @JsonKey(name: 'languages')
  final List<String> languages;

  @JsonKey(name: 'subjects')
  final List<String> subjects;

  @JsonKey(name: 'rating')
  final double rating;

  @JsonKey(name: 'review_count')
  final int reviewCount;

  @JsonKey(name: 'verification_status')
  final String verificationStatus;

  @JsonKey(name: 'is_available')
  final bool isAvailable;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'next_available_slot')
  final AvailabilitySlotDto? nextAvailableSlot;

  @JsonKey(name: 'location')
  final String? location;

  @JsonKey(name: 'specialization')
  final String? specialization;

  @JsonKey(name: 'education')
  final String? education;

  /// Creates instance from JSON
  factory TutorDto.fromJson(Map<String, dynamic> json) =>
      _$TutorDtoFromJson(json);

  /// Converts instance to JSON
  Map<String, dynamic> toJson() => _$TutorDtoToJson(this);

  @override
  String toString() => 'TutorDto(id: $id, fullName: $fullName)';
}
