import 'package:equatable/equatable.dart';

class AdminUserEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? profileImage;
  final String? phone;
  final double balance;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdminUserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.profileImage,
    this.phone,
    this.balance = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isTutor => role == 'tutor';
  bool get isStudent => role == 'student';

  @override
  List<Object?> get props => [id, email, role];
}

class PlatformStatsEntity extends Equatable {
  final int totalUsers;
  final int totalStudents;
  final int totalTutors;
  final int totalAdmins;
  final int totalBookings;
  final int totalTransactions;
  final double totalRevenue;
  final int pendingVerifications;

  const PlatformStatsEntity({
    this.totalUsers = 0,
    this.totalStudents = 0,
    this.totalTutors = 0,
    this.totalAdmins = 0,
    this.totalBookings = 0,
    this.totalTransactions = 0,
    this.totalRevenue = 0,
    this.pendingVerifications = 0,
  });

  @override
  List<Object?> get props => [
    totalUsers,
    totalStudents,
    totalTutors,
    totalBookings,
    totalRevenue,
  ];
}

class AnnouncementEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final String targetRole; // ALL, STUDENT, TUTOR
  final String type; // INFO, WARNING, URGENT
  final String? createdById;
  final String? createdByName;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AnnouncementEntity({
    required this.id,
    required this.title,
    required this.content,
    this.targetRole = 'ALL',
    this.type = 'INFO',
    this.createdById,
    this.createdByName,
    this.isActive = true,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isUrgent => type == 'URGENT';
  bool get isWarning => type == 'WARNING';

  @override
  List<Object?> get props => [id, title, type, targetRole];
}
