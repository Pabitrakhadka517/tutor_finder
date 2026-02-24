import 'package:json_annotation/json_annotation.dart';

import 'availability_slot_dto.dart';
import 'tutor_dto.dart';

part 'tutor_detail_dto.g.dart';

/// Data Transfer Object for detailed tutor information from API.
/// Contains comprehensive tutor data including availability slots.
@JsonSerializable()
class TutorDetailDto {
  const TutorDetailDto({
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
    required this.availabilitySlots,
    this.location,
    this.specialization,
    this.education,
    this.recentReviews,
    this.certifications,
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

  @JsonKey(name: 'availability_slots')
  final List<AvailabilitySlotDto> availabilitySlots;

  @JsonKey(name: 'location')
  final String? location;

  @JsonKey(name: 'specialization')
  final String? specialization;

  @JsonKey(name: 'education')
  final String? education;

  @JsonKey(name: 'recent_reviews')
  final List<Map<String, dynamic>>? recentReviews;

  @JsonKey(name: 'certifications')
  final List<String>? certifications;

  /// Converts to basic TutorDto
  TutorDto toTutorDto() {
    return TutorDto(
      id: id,
      profileId: profileId,
      fullName: fullName,
      profileImage: profileImage,
      bio: bio,
      experienceYears: experienceYears,
      hourlyRate: hourlyRate,
      languages: languages,
      subjects: subjects,
      rating: rating,
      reviewCount: reviewCount,
      verificationStatus: verificationStatus,
      isAvailable: isAvailable,
      createdAt: createdAt,
      nextAvailableSlot: availabilitySlots.isNotEmpty
          ? availabilitySlots.first
          : null,
      location: location,
      specialization: specialization,
      education: education,
    );
  }

  /// Creates instance from JSON
  factory TutorDetailDto.fromJson(Map<String, dynamic> json) =>
      _$TutorDetailDtoFromJson(json);

  /// Converts instance to JSON
  Map<String, dynamic> toJson() => _$TutorDetailDtoToJson(this);

  @override
  String toString() => 'TutorDetailDto(id: $id, fullName: $fullName)';
}
