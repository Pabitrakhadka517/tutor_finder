/// User role value object for dashboard access control
enum UserRole {
  student,
  tutor,
  admin;

  /// Convert string to UserRole
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return UserRole.student;
      case 'tutor':
        return UserRole.tutor;
      case 'admin':
        return UserRole.admin;
      default:
        throw ArgumentError('Unknown role: $role');
    }
  }

  /// Convert UserRole to string
  String get value {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.tutor:
        return 'tutor';
      case UserRole.admin:
        return 'admin';
    }
  }

  /// Check if role has dashboard access
  bool get hasDashboardAccess {
    return this == UserRole.student || this == UserRole.tutor;
  }

  /// Get role display name
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.tutor:
        return 'Tutor';
      case UserRole.admin:
        return 'Administrator';
    }
  }
}
