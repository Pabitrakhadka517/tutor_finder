import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login
class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    // Add validation logic here if needed
    if (params.email.isEmpty || !params.email.contains('@')) {
      return Either.left(
        const ValidationFailure('Please enter a valid email address'),
      );
    }

    if (params.password.isEmpty) {
      return Either.left(const ValidationFailure('Please enter your password'));
    }

    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}
