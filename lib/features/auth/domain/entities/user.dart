import 'package:equatable/equatable.dart';

/// Domain Entity representing a User
/// This is framework-independent and contains only business logic
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, name, createdAt];
}
