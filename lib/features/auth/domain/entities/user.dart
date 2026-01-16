import 'package:equatable/equatable.dart';

/// User role enum
enum UserRole { student, admin, tutor }

/// Domain Entity representing a User
/// This is framework-independent and contains only business logic
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? token;
  final String? refreshToken;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.role = UserRole.student,
    this.token,
    this.refreshToken,
    required this.createdAt,
  });

  /// Copy with method for immutability
  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? token,
    String? refreshToken,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    role,
    token,
    refreshToken,
    createdAt,
  ];
}
