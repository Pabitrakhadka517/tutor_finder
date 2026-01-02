import '../error/failures.dart';
import '../utils/either.dart';

/// Base class for all use cases
/// [T] is the return type
/// [Params] is the parameter type
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Used when a use case doesn't need parameters
class NoParams {
  const NoParams();
}
