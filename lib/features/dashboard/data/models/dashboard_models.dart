import '../../domain/entities/dashboard_stats.dart';

class StudentDashboardModel extends StudentDashboardStats {
  const StudentDashboardModel({
    super.totalBookings,
    super.upcomingBookings,
    super.completedBookings,
    super.totalSpent,
    super.totalTutorsWorkedWith,
  });

  factory StudentDashboardModel.fromJson(Map<String, dynamic> json) {
    return StudentDashboardModel(
      totalBookings: _toInt(json['totalBookings']),
      upcomingBookings: _toInt(json['upcomingBookings']),
      completedBookings: _toInt(json['completedBookings']),
      totalSpent: _toDouble(json['totalSpent']),
      totalTutorsWorkedWith: _toInt(json['totalTutorsWorkedWith']),
    );
  }
}

class TutorDashboardModel extends TutorDashboardStats {
  const TutorDashboardModel({
    super.totalEarnings,
    super.totalStudentsWorkedWith,
    super.totalBookings,
    super.completedBookings,
    super.pendingBookings,
    super.averageRating,
    super.verificationStatus,
  });

  factory TutorDashboardModel.fromJson(Map<String, dynamic> json) {
    return TutorDashboardModel(
      totalEarnings: _toDouble(json['totalEarnings']),
      totalStudentsWorkedWith: _toInt(json['totalStudentsWorkedWith']),
      totalBookings: _toInt(json['totalBookings']),
      completedBookings: _toInt(json['completedBookings']),
      pendingBookings: _toInt(json['pendingBookings']),
      averageRating: _toDouble(json['averageRating']),
      verificationStatus: json['verificationStatus'] as String? ?? 'PENDING',
    );
  }
}

class AdminDashboardModel extends AdminDashboardStats {
  const AdminDashboardModel({
    super.totalUsers,
    super.totalStudents,
    super.totalTutors,
    super.totalBookings,
    super.totalCompletedSessions,
    super.totalRevenue,
    super.totalCommission,
    super.pendingVerifications,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      totalUsers: _toInt(json['totalUsers']),
      totalStudents: _toInt(json['totalStudents']),
      totalTutors: _toInt(json['totalTutors']),
      totalBookings: _toInt(json['totalBookings']),
      totalCompletedSessions: _toInt(json['totalCompletedSessions']),
      totalRevenue: _toDouble(json['totalRevenue']),
      totalCommission: _toDouble(json['totalCommission']),
      pendingVerifications: _toInt(json['pendingVerifications']),
    );
  }
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
