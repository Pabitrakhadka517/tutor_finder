import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/tutor_entity.dart';
import '../failures/tutor_failures.dart';
import '../repositories/tutor_repository.dart';

/// Use case for getting detailed information about a specific tutor.
/// Validates tutor ID and delegates to repository.
class GetTutorDetailUsecase {
  const GetTutorDetailUsecase(this.repository);

  final TutorRepository repository;

  /// Gets tutor detail by ID.
  ///
  /// Performs frontend validation:
  /// - Validates tutor ID is not empty
  /// - Validates tutor ID format (if needed)
  ///
  /// [params] - Contains tutor ID to fetch
  /// Returns Either<Failure, Tutor>
  Future<Either<TutorFailure, TutorEntity>> call(
    GetTutorDetailParams params,
  ) async {
    // Frontend validation
    final validationFailure = _validateParams(params);
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    // Delegate to repository
    return repository.getTutorById(params.tutorId);
  }

  /// Validates tutor detail parameters
  TutorValidationFailure? _validateParams(GetTutorDetailParams params) {
    // Validate tutor ID
    if (params.tutorId.trim().isEmpty) {
      return const TutorValidationFailure('Tutor ID cannot be empty.');
    }

    // Additional ID format validation could be added here
    // For example, UUID validation if IDs follow that format

    return null;
  }
}

/// Parameters for GetTutorDetailUsecase
class GetTutorDetailParams extends Equatable {
  const GetTutorDetailParams({required this.tutorId});

  final String tutorId;

  @override
  List<Object?> get props => [tutorId];
}
