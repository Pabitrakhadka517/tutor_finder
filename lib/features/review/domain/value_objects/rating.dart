import 'package:equatable/equatable.dart';

/// Value object for a review rating (1-5 stars)
class Rating extends Equatable {
  final int value;

  const Rating._(this.value);

  factory Rating.fromInt(int value) {
    if (value < 1 || value > 5) {
      throw ArgumentError('Rating must be between 1 and 5, got $value');
    }
    return Rating._(value);
  }

  bool get isValid => value >= 1 && value <= 5;

  double get normalizedValue => value / 5.0;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Rating($value)';
}
