import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/user_entity.dart';
import '../failures/auth_failures.dart';
import '../repositories/auth_repository.dart';
import '../validators/auth_validators.dart';

class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    // ── Frontend validation ─────────────────────────────────────────────────
    final emailError = AuthValidators.validateEmail(params.email);
    if (emailError != null) return Left(ValidationFailure(emailError));

    if (params.password.isEmpty) {
      return const Left(ValidationFailure('Password is required.'));
    }

    // ── Delegate to repository ──────────────────────────────────────────────
    return _repository.login(
      email: params.email.trim(),
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
