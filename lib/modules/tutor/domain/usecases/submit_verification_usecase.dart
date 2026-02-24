import 'package:dartz/dartz.dart';

import '../failures/tutor_failures.dart';
import '../repositories/tutor_repository.dart';

/// Use case for submitting tutor profile for verification.
/// Handles business logic validation before delegating to repository.
class SubmitVerificationUsecase {
  const SubmitVerificationUsecase(this.repository);

  final TutorRepository repository;

  /// Submits the current user's tutor profile for verification.
  ///
  /// The repository will handle:
  /// - Authentication validation
  /// - Profile completeness check
  /// - Current verification status check
  ///
  /// No parameters needed as this operates on the authenticated user.
  /// Returns Either<Failure, void>
  Future<Either<TutorFailure, void>> call() async {
    return repository.submitVerification();
  }
}
