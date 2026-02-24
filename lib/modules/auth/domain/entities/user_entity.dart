import 'package:equatable/equatable.dart';

/// Allowed roles in the system
enum UserRole { student, tutor, admin }

/// Pure domain entity – no framework annotations, no JSON logic.
/// Tokens are **not** stored in the entity; they are an infrastructure concern
/// handled exclusively by the data layer.
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.role = UserRole.student,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, name, role, createdAt];
}
