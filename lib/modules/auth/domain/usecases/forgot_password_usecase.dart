import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../failures/auth_failures.dart';
import '../repositories/auth_repository.dart';
import '../validators/auth_validators.dart';

class ForgotPasswordUseCase {
  final AuthRepository _repository;

  const ForgotPasswordUseCase(this._repository);

  Future<Either<Failure, void>> call(ForgotPasswordParams params) async {
    final emailError = AuthValidators.validateEmail(params.email);
    if (emailError != null) return Left(ValidationFailure(emailError));

    return _repository.forgotPassword(email: params.email.trim());
  }
}

class ForgotPasswordParams extends Equatable {
  final String email;

  const ForgotPasswordParams({required this.email});

  @override
  List<Object?> get props => [email];
}
