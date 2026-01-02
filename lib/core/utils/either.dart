/// Represents a value of one of two possible types (a disjoint union)
/// Either is commonly used for error handling, where [Left] represents failure
/// and [Right] represents success
sealed class Either<L, R> {
  const Either();

  /// Creates a Left value
  factory Either.left(L value) = Left<L, R>;

  /// Creates a Right value
  factory Either.right(R value) = Right<L, R>;

  /// Executes one of the provided functions depending on the value
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return switch (this) {
      Left(:final value) => onLeft(value),
      Right(:final value) => onRight(value),
    };
  }

  /// Returns true if this is a Left value
  bool get isLeft => this is Left<L, R>;

  /// Returns true if this is a Right value
  bool get isRight => this is Right<L, R>;

  /// Gets the right value or null
  R? getOrNull() {
    return switch (this) {
      Right(:final value) => value,
      _ => null,
    };
  }

  /// Gets the left value or null
  L? getLeftOrNull() {
    return switch (this) {
      Left(:final value) => value,
      _ => null,
    };
  }
}

/// Represents the left side of [Either], typically used for failures
final class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);
}

/// Represents the right side of [Either], typically used for success
final class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);
}
