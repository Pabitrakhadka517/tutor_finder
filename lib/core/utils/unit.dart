/// Represents the unit value - a type with only one possible value
///
/// This is commonly used in functional programming when you need to indicate
/// that an operation was successful but doesn't return any meaningful data.
/// It's the equivalent of void but can be used with generic types.
class Unit {
  const Unit._();

  @override
  String toString() => '()';

  @override
  bool operator ==(Object other) => other is Unit;

  @override
  int get hashCode => 0;
}

/// The singleton instance of Unit
const unit = Unit._();
