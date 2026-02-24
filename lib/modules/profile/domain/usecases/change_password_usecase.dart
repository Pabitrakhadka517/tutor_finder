import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../failures/profile_failures.dart';
import '../repositories/profile_repository.dart';
import '../validators/profile_validators.dart';

/// Use case for changing the user's password.
/// Requires current password verification for security.
class ChangePasswordUseCase {
  final ProfileRepository _repository;

  const ChangePasswordUseCase(this._repository);

  Future<Either<ProfileFailure, void>> call(ChangePasswordParams params) async {
    // ── Validation ───────────────────────────────────────────────────────────
    final oldPasswordError = ProfileValidators.validateOldPassword(
      params.oldPassword,
    );
    if (oldPasswordError != null) {
      return Left(ValidationFailure(oldPasswordError));
    }

    final newPasswordError = ProfileValidators.validateNewPassword(
      params.newPassword,
    );
    if (newPasswordError != null) {
      return Left(ValidationFailure(newPasswordError));
    }

    if (params.oldPassword == params.newPassword) {
      return const Left(
        ValidationFailure(
          'New password must be different from current password.',
        ),
      );
    }

    return _repository.changePassword(
      oldPassword: params.oldPassword,
      newPassword: params.newPassword,
    );
  }
}

class ChangePasswordParams extends Equatable {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordParams({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword];
}
