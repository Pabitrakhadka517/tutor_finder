import '../../domain/entities/dashboard_entity.dart';
import '../../domain/entities/dashboard_stats.dart';

class StudentDashboardModel extends StudentDashboardStats {
  final List<Map<String, dynamic>> rawRecentBookings;
  final List<Map<String, dynamic>> rawRecentTransactions;

  const StudentDashboardModel({
    super.totalBookings,
    super.upcomingBookings,
    super.completedBookings,
    super.totalSpent,
    super.totalTutorsWorkedWith,
    this.rawRecentBookings = const [],
    this.rawRecentTransactions = const [],
  });

  factory StudentDashboardModel.fromJson(
    Map<String, dynamic> json, {
    List<dynamic> recentBookings = const [],
    List<dynamic> recentTransactions = const [],
  }) {
    return StudentDashboardModel(
      totalBookings: _toInt(json['totalBookings']),
      upcomingBookings: _toInt(json['upcomingBookings']),
      completedBookings: _toInt(json['completedBookings']),
      totalSpent: _toDouble(json['totalSpent']),
      totalTutorsWorkedWith: _toInt(json['totalTutorsWorkedWith']),
      rawRecentBookings: recentBookings
          .whereType<Map<String, dynamic>>()
          .toList(),
      rawRecentTransactions: recentTransactions
          .whereType<Map<String, dynamic>>()
          .toList(),
    );
  }

  /// Parse raw booking JSON into [RecentBookingEntity] list
  List<RecentBookingEntity> parseRecentBookings() {
    return rawRecentBookings.map((b) {
      // Tutor can be populated object or string
      String tutorId = '';
      String tutorName = '';
      if (b['tutor'] is Map) {
        final t = b['tutor'] as Map<String, dynamic>;
        tutorId = t['_id']?.toString() ?? t['id']?.toString() ?? '';
        tutorName = t['fullName']?.toString() ?? t['name']?.toString() ?? '';
      } else {
        tutorId = b['tutor']?.toString() ?? '';
      }

      return RecentBookingEntity(
        id: b['_id']?.toString() ?? b['id']?.toString() ?? '',
        studentId: b['student']?.toString() ?? '',
        tutorId: tutorName.isNotEmpty ? tutorName : tutorId,
        subject:
            b['subject']?.toString() ?? b['title']?.toString() ?? 'Session',
        scheduledDate:
            DateTime.tryParse(
              b['startTime']?.toString() ??
                  b['scheduledDate']?.toString() ??
                  '',
            ) ??
            DateTime.now(),
        status: _parseBookingStatus(b['status']?.toString() ?? 'pending'),
        amount: _toDouble(b['price'] ?? b['amount']),
        duration: _toInt(b['duration'] ?? 60),
        notes: b['notes']?.toString(),
      );
    }).toList();
  }

  /// Parse raw transaction JSON into [RecentTransactionEntity] list
  List<RecentTransactionEntity> parseRecentTransactions() {
    return rawRecentTransactions.map((t) {
      return RecentTransactionEntity(
        id: t['_id']?.toString() ?? t['id']?.toString() ?? '',
        userId: t['sender']?.toString() ?? '',
        type: TransactionType.payment,
        amount: _toDouble(t['amount']),
        createdAt:
            DateTime.tryParse(t['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        status: _parseTransactionStatus(t['status']?.toString() ?? 'pending'),
        description: t['description']?.toString() ?? 'Payment',
        bookingId: t['booking']?.toString(),
      );
    }).toList();
  }

  static BookingStatus _parseBookingStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return BookingStatus.pending;
      case 'CONFIRMED':
        return BookingStatus.confirmed;
      case 'COMPLETED':
        return BookingStatus.completed;
      case 'CANCELLED':
        return BookingStatus.cancelled;
      case 'PAID':
      case 'IN_PROGRESS':
        return BookingStatus.inProgress;
      case 'SCHEDULED':
        return BookingStatus.scheduled;
      default:
        return BookingStatus.pending;
    }
  }

  static TransactionStatus _parseTransactionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'done':
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      case 'refunded':
        return TransactionStatus.refunded;
      case 'processing':
        return TransactionStatus.processing;
      default:
        return TransactionStatus.pending;
    }
  }
}

class TutorDashboardModel extends TutorDashboardStats {
  final List<Map<String, dynamic>> rawRecentBookings;
  final List<Map<String, dynamic>> rawRecentTransactions;

  const TutorDashboardModel({
    super.totalEarnings,
    super.totalStudentsWorkedWith,
    super.totalBookings,
    super.completedBookings,
    super.pendingBookings,
    super.averageRating,
    super.verificationStatus,
    this.rawRecentBookings = const [],
    this.rawRecentTransactions = const [],
  });

  factory TutorDashboardModel.fromJson(
    Map<String, dynamic> json, {
    List<dynamic> recentBookings = const [],
    List<dynamic> recentTransactions = const [],
  }) {
    return TutorDashboardModel(
      totalEarnings: _toDouble(json['totalEarnings']),
      totalStudentsWorkedWith: _toInt(json['totalStudentsWorkedWith']),
      totalBookings: _toInt(json['totalBookings']),
      completedBookings: _toInt(json['completedBookings']),
      pendingBookings: _toInt(json['pendingBookings']),
      averageRating: _toDouble(json['averageRating']),
      verificationStatus: json['verificationStatus'] as String? ?? 'PENDING',
      rawRecentBookings: recentBookings
          .whereType<Map<String, dynamic>>()
          .toList(),
      rawRecentTransactions: recentTransactions
          .whereType<Map<String, dynamic>>()
          .toList(),
    );
  }

  /// Parse raw booking JSON into [RecentBookingEntity] list
  List<RecentBookingEntity> parseRecentBookings() {
    return rawRecentBookings.map((b) {
      String studentId = '';
      String studentName = '';
      if (b['student'] is Map) {
        final s = b['student'] as Map<String, dynamic>;
        studentId = s['_id']?.toString() ?? s['id']?.toString() ?? '';
        studentName = s['fullName']?.toString() ?? s['name']?.toString() ?? '';
      } else {
        studentId = b['student']?.toString() ?? '';
      }

      return RecentBookingEntity(
        id: b['_id']?.toString() ?? b['id']?.toString() ?? '',
        studentId: studentName.isNotEmpty ? studentName : studentId,
        tutorId: b['tutor']?.toString() ?? '',
        subject:
            b['subject']?.toString() ?? b['title']?.toString() ?? 'Session',
        scheduledDate:
            DateTime.tryParse(
              b['startTime']?.toString() ??
                  b['scheduledDate']?.toString() ??
                  '',
            ) ??
            DateTime.now(),
        status: StudentDashboardModel._parseBookingStatus(
          b['status']?.toString() ?? 'pending',
        ),
        amount: _toDouble(b['price'] ?? b['amount']),
        duration: _toInt(b['duration'] ?? 60),
        notes: b['notes']?.toString(),
      );
    }).toList();
  }

  /// Parse raw transaction JSON into [RecentTransactionEntity] list
  List<RecentTransactionEntity> parseRecentTransactions() {
    return rawRecentTransactions.map((t) {
      return RecentTransactionEntity(
        id: t['_id']?.toString() ?? t['id']?.toString() ?? '',
        userId: t['receiver']?.toString() ?? '',
        type: TransactionType.earnings,
        amount: _toDouble(t['receiverAmount'] ?? t['amount']),
        createdAt:
            DateTime.tryParse(t['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        status: StudentDashboardModel._parseTransactionStatus(
          t['status']?.toString() ?? 'pending',
        ),
        description: t['description']?.toString() ?? 'Earnings',
        bookingId: t['booking']?.toString(),
      );
    }).toList();
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
