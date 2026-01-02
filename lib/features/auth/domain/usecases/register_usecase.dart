import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for registering a new user
class RegisterUseCase implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
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

    if (params.name.isEmpty) {
      return Either.left(const ValidationFailure('Please enter your name'));
    }

    return await repository.register(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}

class RegisterParams {
  final String email;
  final String password;
  final String name;

  RegisterParams({
    required this.email,
    required this.password,
    required this.name,
  });
}
