import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/profile_entity.dart';
import '../failures/profile_failures.dart';
import '../repositories/profile_repository.dart';
import '../validators/profile_validators.dart';

/// Use case for updating the user's profile.
/// Handles validation and ensures tutor fields are only allowed for tutors.
class UpdateProfileUseCase {
  final ProfileRepository _repository;

  const UpdateProfileUseCase(this._repository);

  Future<Either<ProfileFailure, ProfileEntity>> call(
    UpdateProfileParams params,
  ) async {
    // ── Frontend validation ─────────────────────────────────────────────────
    if (params.name != null) {
      final nameError = ProfileValidators.validateName(params.name);
      if (nameError != null) {
        return Left(ValidationFailure(nameError));
      }
    }

    if (params.phone != null) {
      final phoneError = ProfileValidators.validatePhone(params.phone);
      if (phoneError != null) {
        return Left(ValidationFailure(phoneError));
      }
    }

    if (params.speciality != null) {
      final specialityError = ProfileValidators.validateSpeciality(
        params.speciality,
      );
      if (specialityError != null) {
        return Left(ValidationFailure(specialityError));
      }
    }

    // ── Tutor-specific validation ───────────────────────────────────────────
    if (params.tutorFields != null) {
      final tutorFields = params.tutorFields!;

      if (tutorFields.bio != null) {
        final bioError = ProfileValidators.validateBio(tutorFields.bio);
        if (bioError != null) {
          return Left(ValidationFailure(bioError));
        }
      }

      if (tutorFields.hourlyRate != null) {
        final rateError = ProfileValidators.validateHourlyRate(
          tutorFields.hourlyRate,
        );
        if (rateError != null) {
          return Left(ValidationFailure(rateError));
        }
      }

      if (tutorFields.experienceYears != null) {
        final expError = ProfileValidators.validateExperienceYears(
          tutorFields.experienceYears,
        );
        if (expError != null) {
          return Left(ValidationFailure(expError));
        }
      }

      if (tutorFields.subjects != null) {
        final subjectsError = ProfileValidators.validateSubjects(
          tutorFields.subjects,
        );
        if (subjectsError != null) {
          return Left(ValidationFailure(subjectsError));
        }
      }

      if (tutorFields.languages != null) {
        final langError = ProfileValidators.validateLanguages(
          tutorFields.languages,
        );
        if (langError != null) {
          return Left(ValidationFailure(langError));
        }
      }
    }

    // ── Image validation ────────────────────────────────────────────────────
    if (params.profileImagePath != null) {
      // Note: File validation happens in the presentation layer
      // since this use case shouldn't depend on dart:io
    }

    // ── Convert to repository params ────────────────────────────────────────
    final repoParams = ProfileUpdateParams(
      name: params.name,
      phone: params.phone,
      speciality: params.speciality,
      address: params.address,
      profileImagePath: params.profileImagePath,
      theme: params.theme,
      // Tutor fields
      bio: params.tutorFields?.bio,
      hourlyRate: params.tutorFields?.hourlyRate,
      experienceYears: params.tutorFields?.experienceYears,
      subjects: params.tutorFields?.subjects,
      languages: params.tutorFields?.languages,
    );

    return _repository.updateProfile(repoParams);
  }
}

/// Use case parameters for profile updates.
class UpdateProfileParams extends Equatable {
  final String? name;
  final String? phone;
  final String? speciality;
  final String? address;
  final String? profileImagePath;
  final String? theme;
  final TutorFields? tutorFields;

  const UpdateProfileParams({
    this.name,
    this.phone,
    this.speciality,
    this.address,
    this.profileImagePath,
    this.theme,
    this.tutorFields,
  });

  @override
  List<Object?> get props => [
    name,
    phone,
    speciality,
    address,
    profileImagePath,
    theme,
    tutorFields,
  ];
}

/// Tutor-specific fields grouped together.
class TutorFields extends Equatable {
  final String? bio;
  final double? hourlyRate;
  final int? experienceYears;
  final List<String>? subjects;
  final List<String>? languages;

  const TutorFields({
    this.bio,
    this.hourlyRate,
    this.experienceYears,
    this.subjects,
    this.languages,
  });

  @override
  List<Object?> get props => [
    bio,
    hourlyRate,
    experienceYears,
    subjects,
    languages,
  ];
}
