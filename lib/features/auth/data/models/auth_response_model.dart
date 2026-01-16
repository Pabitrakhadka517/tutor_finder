import '../../domain/entities/user.dart';

/// Response model for authentication API calls
class AuthResponseModel {
  final String? userId;
  final String email;
  final String? name;
  final String role;
  final String? token;
  final String? refreshToken;
  final String? message;
  final DateTime? createdAt;

  AuthResponseModel({
    this.userId,
    required this.email,
    this.name,
    required this.role,
    this.token,
    this.refreshToken,
    this.message,
    this.createdAt,
  });

  /// Parse from JSON response
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle nested user object if present
    final userData = json['user'] as Map<String, dynamic>?;

    return AuthResponseModel(
      userId:
          json['userId'] ??
          json['id'] ??
          json['_id'] ??
          userData?['id'] ??
          userData?['_id'],
      email: json['email'] ?? userData?['email'] ?? '',
      name: json['name'] ?? userData?['name'],
      role: json['role'] ?? userData?['role'] ?? 'student',
      token: json['token'] ?? json['accessToken'] ?? json['access_token'],
      refreshToken: json['refreshToken'] ?? json['refresh_token'],
      message: json['message'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : userData?['createdAt'] != null
          ? DateTime.tryParse(userData!['createdAt'])
          : null,
    );
  }

  /// Convert to Domain Entity
  User toEntity() {
    return User(
      id: userId ?? '',
      email: email,
      name: name ?? '',
      role: _parseRole(role),
      token: token,
      refreshToken: refreshToken,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Parse role string to UserRole enum
  UserRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'tutor':
        return UserRole.tutor;
      case 'student':
      default:
        return UserRole.student;
    }
  }
}
