/// Rating value object that encapsulates rating validation logic.
/// Ensures rating is always within valid bounds (1-5) and is an integer.
class Rating {
  const Rating._(this.value);

  final int value;

  /// Factory constructor that validates rating value.
  /// Throws ArgumentError if rating is invalid.
  factory Rating(dynamic ratingValue) {
    // Convert to double first for validation, then check if integer
    late final double doubleValue;

    if (ratingValue is int) {
      doubleValue = ratingValue.toDouble();
    } else if (ratingValue is double) {
      doubleValue = ratingValue;
    } else if (ratingValue is String) {
      final parsed = double.tryParse(ratingValue);
      if (parsed == null) {
        throw ArgumentError('Rating must be a valid number');
      }
      doubleValue = parsed;
    } else {
      throw ArgumentError('Rating must be a number');
    }

    // Check if it's an integer (no decimal places)
    if (doubleValue != doubleValue.floor()) {
      throw ArgumentError('Rating must be a whole number (no decimals)');
    }

    final intValue = doubleValue.toInt();

    // Validate range
    if (intValue < 1 || intValue > 5) {
      throw ArgumentError('Rating must be between 1 and 5 (inclusive)');
    }

    return Rating._(intValue);
  }

  /// Create rating from trusted source (already validated)
  const Rating.trusted(this.value);

  /// Check if rating is valid without throwing
  static bool isValid(dynamic ratingValue) {
    try {
      Rating(ratingValue);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get validation error message or null if valid
  static String? getValidationError(dynamic ratingValue) {
    try {
      Rating(ratingValue);
      return null;
    } on ArgumentError catch (e) {
      return e.message;
    } catch (e) {
      return 'Invalid rating value';
    }
  }

  /// Convert to display string
  String toDisplayString() {
    const stars = ['⭐', '⭐⭐', '⭐⭐⭐', '⭐⭐⭐⭐', '⭐⭐⭐⭐⭐'];
    return stars[value - 1]; // value is 1-5, array is 0-4
  }

  /// Get percentage representation (20% per star)
  double toPercentage() {
    return (value / 5.0) * 100.0;
  }

  /// Check if rating is excellent (4-5 stars)
  bool get isExcellent => value >= 4;

  /// Check if rating is good (3-5 stars)
  bool get isGood => value >= 3;

  /// Check if rating is poor (1-2 stars)
  bool get isPoor => value <= 2;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Rating && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Rating($value)';

  /// Compare ratings
  bool operator >(Rating other) => value > other.value;
  bool operator <(Rating other) => value < other.value;
  bool operator >=(Rating other) => value >= other.value;
  bool operator <=(Rating other) => value <= other.value;

  /// Convert to JSON representation
  int toJson() => value;

  /// Create from JSON
  static Rating fromJson(dynamic json) => Rating(json);
}
