/// Base class for dashboard statistics
abstract class DashboardEntity {
  const DashboardEntity();

  Map<String, dynamic> calculateAggregates() => {};
  Map<String, dynamic> toMap();
}

/// Dashboard statistics specific to student users
class StudentDashboardEntity extends DashboardEntity {
  final String id;
  final String studentId;
  final int totalBookings;
  final int upcomingBookings;
  final int completedBookings;
  final int cancelledBookings;
  final double totalSpent;
  final double averageSessionCost;
  final int totalHoursLearned;
  final int totalTutorsWorkedWith;
  final List<String> favoriteSubjects;
  final List<RecentBookingEntity> recentBookings;
  final List<RecentTransactionEntity> recentTransactions;
  final StudentProgressEntity? progress;
  final DateTime lastUpdated;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const StudentDashboardEntity({
    required this.id,
    required this.studentId,
    required this.totalBookings,
    required this.upcomingBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.totalSpent,
    required this.averageSessionCost,
    required this.totalHoursLearned,
    required this.totalTutorsWorkedWith,
    required this.favoriteSubjects,
    required this.recentBookings,
    required this.recentTransactions,
    required this.lastUpdated,
    required this.createdAt,
    this.progress,
    this.metadata = const {},
  });

  DateTime get lastActivity => lastUpdated;

  @override
  Map<String, dynamic> calculateAggregates() {
    final completionRate = totalBookings > 0
        ? (completedBookings / totalBookings * 100)
        : 0.0;
    return {
      'completionRate': completionRate,
      'hasUpcomingBookings': upcomingBookings > 0,
    };
  }

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'studentId': studentId,
    'totalBookings': totalBookings,
    'upcomingBookings': upcomingBookings,
    'completedBookings': completedBookings,
    'cancelledBookings': cancelledBookings,
    'totalSpent': totalSpent,
    'averageSessionCost': averageSessionCost,
    'totalHoursLearned': totalHoursLearned,
    'totalTutorsWorkedWith': totalTutorsWorkedWith,
    'favoriteSubjects': favoriteSubjects,
    'recentBookings': recentBookings.map((b) => b.toMap()).toList(),
    'recentTransactions': recentTransactions.map((t) => t.toMap()).toList(),
    'progress': progress?.toMap(),
    'lastUpdated': lastUpdated.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentDashboardEntity &&
          other.id == id &&
          other.studentId == studentId;

  @override
  int get hashCode => id.hashCode ^ studentId.hashCode;
}

/// Dashboard statistics specific to tutor users
class TutorDashboardEntity extends DashboardEntity {
  final String id;
  final String tutorId;
  final double totalEarnings;
  final double thisMonthEarnings;
  final double pendingEarnings;
  final int totalStudentsWorkedWith;
  final int totalBookings;
  final int completedBookings;
  final int pendingBookings;
  final int cancelledBookings;
  final double averageRating;
  final int totalReviews;
  final List<String> teachingSubjects;
  final VerificationStatus verificationStatus;
  final List<RecentBookingEntity> recentBookings;
  final List<RecentTransactionEntity> recentTransactions;
  final TutorPerformanceEntity? performance;
  final DateTime lastUpdated;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const TutorDashboardEntity({
    required this.id,
    required this.tutorId,
    required this.totalEarnings,
    required this.thisMonthEarnings,
    required this.pendingEarnings,
    required this.totalStudentsWorkedWith,
    required this.totalBookings,
    required this.completedBookings,
    required this.pendingBookings,
    required this.cancelledBookings,
    required this.averageRating,
    required this.totalReviews,
    required this.teachingSubjects,
    required this.verificationStatus,
    required this.recentBookings,
    required this.recentTransactions,
    required this.lastUpdated,
    required this.createdAt,
    this.performance,
    this.metadata = const {},
  });

  DateTime get lastActivity => lastUpdated;

  @override
  Map<String, dynamic> calculateAggregates() {
    final completionRate = totalBookings > 0
        ? (completedBookings / totalBookings * 100)
        : 0.0;
    return {
      'completionRate': completionRate,
      'potentialEarnings': totalEarnings + pendingEarnings,
      'hasPendingBookings': pendingBookings > 0,
    };
  }

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'tutorId': tutorId,
    'totalEarnings': totalEarnings,
    'thisMonthEarnings': thisMonthEarnings,
    'pendingEarnings': pendingEarnings,
    'totalStudentsWorkedWith': totalStudentsWorkedWith,
    'totalBookings': totalBookings,
    'completedBookings': completedBookings,
    'pendingBookings': pendingBookings,
    'cancelledBookings': cancelledBookings,
    'averageRating': averageRating,
    'totalReviews': totalReviews,
    'teachingSubjects': teachingSubjects,
    'verificationStatus': verificationStatus.toString(),
    'recentBookings': recentBookings.map((b) => b.toMap()).toList(),
    'recentTransactions': recentTransactions.map((t) => t.toMap()).toList(),
    'performance': performance?.toMap(),
    'lastUpdated': lastUpdated.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TutorDashboardEntity &&
          other.id == id &&
          other.tutorId == tutorId;

  @override
  int get hashCode => id.hashCode ^ tutorId.hashCode;
}

/// Recent booking information for dashboard display
class RecentBookingEntity {
  final String id;
  final String studentId;
  final String tutorId;
  final String subject;
  final DateTime scheduledDate;
  final BookingStatus status;
  final double amount;
  final int duration;
  final String? notes;

  // Legacy getters
  String get bookingId => id;
  String get partnerName => tutorId;
  DateTime get startTime => scheduledDate;
  DateTime get endTime => scheduledDate.add(Duration(minutes: duration));

  const RecentBookingEntity({
    required this.id,
    required this.studentId,
    required this.tutorId,
    required this.subject,
    required this.scheduledDate,
    required this.status,
    required this.amount,
    required this.duration,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'studentId': studentId,
    'tutorId': tutorId,
    'subject': subject,
    'scheduledDate': scheduledDate.toIso8601String(),
    'status': status.toString(),
    'amount': amount,
    'duration': duration,
    'notes': notes,
  };

  @override
  String toString() =>
      'RecentBookingEntity(id: $id, subject: $subject, status: $status)';
}

/// Transaction type enum
enum TransactionType {
  payment,
  earnings,
  refund,
  withdrawal,
  topup,
  commission,
}

/// Recent transaction information for dashboard display
class RecentTransactionEntity {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final DateTime createdAt;
  final TransactionStatus status;
  final String description;
  final String? bookingId;
  final Map<String, dynamic> metadata;

  // Legacy getter
  String get transactionId => id;

  const RecentTransactionEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.createdAt,
    required this.status,
    required this.description,
    this.bookingId,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'type': type.name,
    'amount': amount,
    'createdAt': createdAt.toIso8601String(),
    'status': status.toString(),
    'description': description,
    'bookingId': bookingId,
    'metadata': metadata,
  };

  @override
  String toString() =>
      'RecentTransactionEntity(id: $id, type: $type, amount: $amount)';
}

/// Student progress tracking entity
class StudentProgressEntity {
  final String studentId;
  final Map<String, double> subjectProgress;
  final List<String> completedMilestones;
  final Map<String, dynamic> learningStats;
  final DateTime lastProgressUpdate;

  // Legacy getters
  int get totalSessionsCompleted =>
      (learningStats['totalSessionsCompleted'] as int?) ?? 0;
  Map<String, int> get subjectDistribution =>
      (learningStats['subjectDistribution'] as Map<String, int>?) ?? {};
  double get averageSessionRating =>
      (learningStats['averageSessionRating'] as num?)?.toDouble() ?? 0.0;
  int get streak => (learningStats['streak'] as int?) ?? 0;
  DateTime get lastSessionDate => lastProgressUpdate;

  const StudentProgressEntity({
    required this.studentId,
    required this.subjectProgress,
    required this.completedMilestones,
    required this.learningStats,
    required this.lastProgressUpdate,
  });

  Map<String, dynamic> toMap() => {
    'studentId': studentId,
    'subjectProgress': subjectProgress,
    'completedMilestones': completedMilestones,
    'learningStats': learningStats,
    'lastProgressUpdate': lastProgressUpdate.toIso8601String(),
  };
}

/// Tutor performance tracking entity
class TutorPerformanceEntity {
  final String tutorId;
  final double responseRate;
  final double completionRate;
  final double punctualityScore;
  final Map<String, dynamic> performanceMetrics;
  final DateTime lastPerformanceUpdate;

  // Legacy getters
  int get totalSessionsDelivered =>
      (performanceMetrics['totalSessionsDelivered'] as int?) ?? 0;
  double get averageSessionDuration =>
      (performanceMetrics['averageSessionDuration'] as num?)?.toDouble() ?? 0.0;
  Map<String, int> get subjectExpertise =>
      (performanceMetrics['subjectExpertise'] as Map<String, int>?) ?? {};
  int get repeatStudents => (performanceMetrics['repeatStudents'] as int?) ?? 0;
  double get cancellationRate =>
      (performanceMetrics['cancellationRate'] as num?)?.toDouble() ?? 0.0;
  DateTime get joinDate => lastPerformanceUpdate;

  const TutorPerformanceEntity({
    required this.tutorId,
    required this.responseRate,
    required this.completionRate,
    required this.punctualityScore,
    required this.performanceMetrics,
    required this.lastPerformanceUpdate,
  });

  Map<String, dynamic> toMap() => {
    'tutorId': tutorId,
    'responseRate': responseRate,
    'completionRate': completionRate,
    'punctualityScore': punctualityScore,
    'performanceMetrics': performanceMetrics,
    'lastPerformanceUpdate': lastPerformanceUpdate.toIso8601String(),
  };
}

/// Verification status for tutors
enum VerificationStatus { pending, verified, rejected, expired }

/// Booking status enum
enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow,
  scheduled,
}

/// Transaction status enum
enum TransactionStatus { pending, completed, failed, refunded, processing }
