import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/user_entity.dart';
import '../failures/auth_failures.dart';
import '../repositories/auth_repository.dart';
import '../validators/auth_validators.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCase(this._repository);

  /// Validates inputs then delegates to the appropriate registration endpoint.
  ///
  /// ADMIN role is **rejected** at the use-case level before any network call.
  Future<Either<Failure, UserEntity>> call(RegisterParams params) async {
    // ── Validation ──────────────────────────────────────────────────────────
    final emailError = AuthValidators.validateEmail(params.email);
    if (emailError != null) return Left(ValidationFailure(emailError));

    final passwordError = AuthValidators.validatePassword(params.password);
    if (passwordError != null) return Left(ValidationFailure(passwordError));

    final roleError = AuthValidators.validateRole(params.role);
    if (roleError != null) return Left(ForbiddenFailure(roleError));

    // ── Dispatch ────────────────────────────────────────────────────────────
    switch (params.role.toLowerCase()) {
      case 'tutor':
        return _repository.registerTutor(
          email: params.email.trim(),
          password: params.password,
          name: params.name.trim(),
        );
      case 'student':
      default:
        return _repository.registerUser(
          email: params.email.trim(),
          password: params.password,
          name: params.name.trim(),
        );
    }
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final String role; // "student" | "tutor"

  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, name, role];
}
