import 'package:equatable/equatable.dart';

/// User role enum – mirrors the roles recognised by the backend.
enum UserRole { student, tutor, admin }

/// Pure domain entity representing a User.
///
/// Framework-independent – no Flutter, Hive, or HTTP dependencies.
/// All business rules related to the user concept live here.
class User extends Equatable {
  final String id;
  final String email;

  /// Display name (full name) of the user.
  final String fullName;

  final UserRole role;
  final String? token;
  final String? refreshToken;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.role = UserRole.student,
    this.token,
    this.refreshToken,
    required this.createdAt,
  });

  /// Convenience alias – many widgets still reference `user.name`.
  String get name => fullName;

  /// Whether this user is a student.
  bool get isStudent => role == UserRole.student;

  /// Whether this user is a tutor.
  bool get isTutor => role == UserRole.tutor;

  /// Whether this user is an admin.
  bool get isAdmin => role == UserRole.admin;

  /// Copy with method for immutability.
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    UserRole? role,
    String? token,
    String? refreshToken,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
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
    fullName,
    role,
    token,
    refreshToken,
    createdAt,
  ];
}
