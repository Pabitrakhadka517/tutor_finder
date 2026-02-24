import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/tutor_list_result_entity.dart';
import '../entities/tutor_search_params.dart';
import '../failures/tutor_failures.dart';
import '../repositories/tutor_repository.dart';

/// Use case for searching and filtering tutors with pagination support.
/// Handles business logic validation and delegates to repository.
class GetTutorsUsecase {
  const GetTutorsUsecase(this.repository);

  final TutorRepository repository;

  /// Executes tutor search with given parameters.
  ///
  /// Performs frontend validation before calling repository:
  /// - Validates search query length
  /// - Validates price range
  /// - Validates pagination parameters
  ///
  /// [params] - Search and filter parameters
  /// Returns Either<Failure, TutorListResult>
  Future<Either<TutorFailure, TutorListResultEntity>> call(
    GetTutorsParams params,
  ) async {
    // Frontend validation
    final validationFailure = _validateParams(params.searchParams);
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    // Delegate to repository
    return repository.getTutors(params.searchParams);
  }

  /// Validates search parameters before making API call
  TutorValidationFailure? _validateParams(TutorSearchParams params) {
    // Validate search query length
    if (params.hasSearch && params.search!.trim().length < 2) {
      return TutorValidationFailure.invalidSearch();
    }

    // Validate price range
    if (params.minPrice != null &&
        params.maxPrice != null &&
        params.minPrice! > params.maxPrice!) {
      return TutorValidationFailure.invalidPriceRange();
    }

    // Validate pagination
    if (params.page < 1) {
      return TutorValidationFailure.invalidPage();
    }

    if (params.limit < 1 || params.limit > 100) {
      return TutorValidationFailure.invalidLimit();
    }

    return null;
  }
}

/// Parameters for GetTutorsUsecase
class GetTutorsParams extends Equatable {
  const GetTutorsParams({required this.searchParams});

  final TutorSearchParams searchParams;

  @override
  List<Object?> get props => [searchParams];
}
