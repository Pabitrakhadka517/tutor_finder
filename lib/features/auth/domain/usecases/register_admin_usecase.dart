import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for registering a new admin
class RegisterAdminUseCase implements UseCase<User, RegisterAdminParams> {
  final AuthRepository repository;

  RegisterAdminUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterAdminParams params) async {
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

    return await repository.registerAdmin(
      email: params.email,
      password: params.password,
    );
  }
}

class RegisterAdminParams {
  final String email;
  final String password;

  RegisterAdminParams({required this.email, required this.password});
}
