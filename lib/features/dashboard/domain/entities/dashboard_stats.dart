import 'package:equatable/equatable.dart';

class StudentDashboardStats extends Equatable {
  final int totalBookings;
  final int upcomingBookings;
  final int completedBookings;
  final double totalSpent;
  final int totalTutorsWorkedWith;

  const StudentDashboardStats({
    this.totalBookings = 0,
    this.upcomingBookings = 0,
    this.completedBookings = 0,
    this.totalSpent = 0,
    this.totalTutorsWorkedWith = 0,
  });

  @override
  List<Object?> get props => [totalBookings, totalSpent];
}

class TutorDashboardStats extends Equatable {
  final double totalEarnings;
  final int totalStudentsWorkedWith;
  final int totalBookings;
  final int completedBookings;
  final int pendingBookings;
  final double averageRating;
  final String verificationStatus;

  const TutorDashboardStats({
    this.totalEarnings = 0,
    this.totalStudentsWorkedWith = 0,
    this.totalBookings = 0,
    this.completedBookings = 0,
    this.pendingBookings = 0,
    this.averageRating = 0,
    this.verificationStatus = 'PENDING',
  });

  @override
  List<Object?> get props => [totalBookings, totalEarnings];
}

class AdminDashboardStats extends Equatable {
  final int totalUsers;
  final int totalStudents;
  final int totalTutors;
  final int totalBookings;
  final int totalCompletedSessions;
  final double totalRevenue;
  final double totalCommission;
  final int pendingVerifications;

  const AdminDashboardStats({
    this.totalUsers = 0,
    this.totalStudents = 0,
    this.totalTutors = 0,
    this.totalBookings = 0,
    this.totalCompletedSessions = 0,
    this.totalRevenue = 0,
    this.totalCommission = 0,
    this.pendingVerifications = 0,
  });

  @override
  List<Object?> get props => [totalUsers, totalBookings];
}
