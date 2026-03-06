import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Unified use case for user sign-up.
/// Accepts role as a parameter so a single use case handles
/// student, tutor, and admin registration.
class SignUpUseCase implements UseCase<User, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    // ── Validation ──
    if (params.email.isEmpty || !params.email.contains('@')) {
      return Either.left(
        const ValidationFailure('Please enter a valid email address'),
      );
    }

    if (params.password.isEmpty || params.password.length < 6) {
      return Either.left(
        const ValidationFailure('Password must be at least 6 characters'),
      );
    }

    // ── Delegate to repository ──
    return repository.signUp(
      email: params.email,
      password: params.password,
      role: params.role,
    );
  }
}

/// Parameters for [SignUpUseCase].
class SignUpParams {
  final String email;
  final String password;
  final UserRole role;

  const SignUpParams({
    required this.email,
    required this.password,
    this.role = UserRole.student,
  });
}
