import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../failures/auth_failures.dart';
import '../repositories/auth_repository.dart';
import '../validators/auth_validators.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;

  const ResetPasswordUseCase(this._repository);

  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    if (params.token.trim().isEmpty) {
      return const Left(ValidationFailure('Reset token is required.'));
    }

    final passwordError = AuthValidators.validatePassword(params.newPassword);
    if (passwordError != null) return Left(ValidationFailure(passwordError));

    return _repository.resetPassword(
      token: params.token.trim(),
      newPassword: params.newPassword,
    );
  }
}

class ResetPasswordParams extends Equatable {
  final String token;
  final String newPassword;

  const ResetPasswordParams({required this.token, required this.newPassword});

  @override
  List<Object?> get props => [token, newPassword];
}
