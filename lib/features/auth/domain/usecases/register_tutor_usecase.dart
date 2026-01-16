import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for registering a new tutor
class RegisterTutorUseCase implements UseCase<User, RegisterTutorParams> {
  final AuthRepository repository;

  RegisterTutorUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterTutorParams params) async {
    // Add validation logic here if needed
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

    return await repository.registerTutor(
      email: params.email,
      password: params.password,
    );
  }
}

class RegisterTutorParams {
  final String email;
  final String password;

  RegisterTutorParams({required this.email, required this.password});
}
