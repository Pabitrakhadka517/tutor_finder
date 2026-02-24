import 'package:equatable/equatable.dart';

import 'availability_slot_entity.dart';

/// Core domain entity representing a tutor with all their information.
/// This is the purest representation used throughout the business logic.
class TutorEntity extends Equatable {
  const TutorEntity({
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

  /// Unique tutor identifier
  final String id;

  /// Reference to the user's profile ID
  final String profileId;

  /// Full display name of the tutor
  final String fullName;

  /// URL to the tutor's profile image
  final String? profileImage;

  /// Tutor's bio/description
  final String bio;

  /// Years of teaching experience
  final int experienceYears;

  /// Hourly rate in USD
  final double hourlyRate;

  /// List of languages the tutor speaks
  final List<String> languages;

  /// List of subjects the tutor teaches
  final List<String> subjects;

  /// Average rating from reviews (0.0 to 5.0)
  final double rating;

  /// Total number of reviews received
  final int reviewCount;

  /// Verification status of the tutor
  final VerificationStatus verificationStatus;

  /// Whether the tutor is currently available
  final bool isAvailable;

  /// When the tutor profile was created
  final DateTime createdAt;

  /// Next available time slot (optional)
  final AvailabilitySlotEntity? nextAvailableSlot;

  /// Tutor's location (optional)
  final String? location;

  /// Area of specialization (optional)
  final String? specialization;

  /// Educational background (optional)
  final String? education;

  /// Helper getters
  bool get isVerified => verificationStatus == VerificationStatus.verified;
  bool get isPending => verificationStatus == VerificationStatus.pending;
  bool get isRejected => verificationStatus == VerificationStatus.rejected;
  bool get hasHighRating => rating >= 4.0;
  bool get isExperienced => experienceYears >= 3;
  bool get hasNextSlot => nextAvailableSlot != null;
  String get ratingDisplay => rating.toStringAsFixed(1);
  String get priceDisplay => '\$${hourlyRate.toStringAsFixed(2)}/hr';

  /// Alias for bio (backward compatibility)
  String get biography => bio;

  /// Creates a copy with modified fields
  TutorEntity copyWith({
    String? id,
    String? profileId,
    String? fullName,
    String? profileImage,
    String? bio,
    int? experienceYears,
    double? hourlyRate,
    List<String>? languages,
    List<String>? subjects,
    double? rating,
    int? reviewCount,
    VerificationStatus? verificationStatus,
    bool? isAvailable,
    DateTime? createdAt,
    AvailabilitySlotEntity? nextAvailableSlot,
    String? location,
    String? specialization,
    String? education,
  }) {
    return TutorEntity(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      fullName: fullName ?? this.fullName,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      experienceYears: experienceYears ?? this.experienceYears,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      languages: languages ?? this.languages,
      subjects: subjects ?? this.subjects,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      nextAvailableSlot: nextAvailableSlot ?? this.nextAvailableSlot,
      location: location ?? this.location,
      specialization: specialization ?? this.specialization,
      education: education ?? this.education,
    );
  }

  @override
  List<Object?> get props => [
    id,
    profileId,
    fullName,
    profileImage,
    bio,
    experienceYears,
    hourlyRate,
    languages,
    subjects,
    rating,
    reviewCount,
    verificationStatus,
    isAvailable,
    createdAt,
    nextAvailableSlot,
    location,
    specialization,
    education,
  ];

  @override
  String toString() =>
      'TutorEntity(id: $id, fullName: $fullName, rating: $rating)';
}

/// Verification status for tutors
enum VerificationStatus {
  unverified,
  pending,
  verified,
  rejected;

  /// Display name for the status
  String get displayName {
    switch (this) {
      case VerificationStatus.unverified:
        return 'Unverified';
      case VerificationStatus.pending:
        return 'Verification Pending';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Verification Rejected';
    }
  }

  /// Whether this status indicates a positive verification state
  bool get isPositive {
    switch (this) {
      case VerificationStatus.verified:
        return true;
      case VerificationStatus.unverified:
      case VerificationStatus.pending:
      case VerificationStatus.rejected:
        return false;
    }
  }
}
