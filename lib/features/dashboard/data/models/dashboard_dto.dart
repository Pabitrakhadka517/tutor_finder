import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/dashboard_entity.dart';
import '../../domain/value_objects/user_role.dart';

part 'dashboard_dto.freezed.dart';
part 'dashboard_dto.g.dart';

/// Data Transfer Object for Student Dashboard
///
/// This DTO handles serialization/deserialization for student dashboard data
/// when communicating with the API and MongoDB aggregation pipelines.
@freezed
class StudentDashboardDto with _$StudentDashboardDto {
  const factory StudentDashboardDto({
    required String id,
    required String studentId,
    required int totalBookings,
    required int upcomingBookings,
    required int completedBookings,
    required int cancelledBookings,
    required double totalSpent,
    required double averageSessionCost,
    required int totalHoursLearned,
    required int totalTutorsWorkedWith,
    required List<String> favoriteSubjects,
    required List<RecentBookingDto> recentBookings,
    required List<RecentTransactionDto> recentTransactions,
    required StudentProgressDto? progress,
    required DateTime lastUpdated,
    required DateTime createdAt,
    Map<String, dynamic>? metadata,
  }) = _StudentDashboardDto;

  const StudentDashboardDto._();

  /// Create DTO from JSON (MongoDB/API response)
  factory StudentDashboardDto.fromJson(Map<String, dynamic> json) =>
      _$StudentDashboardDtoFromJson(json);

  /// Convert DTO to domain entity
  StudentDashboardEntity toDomain() {
    return StudentDashboardEntity(
      id: id,
      studentId: studentId,
      totalBookings: totalBookings,
      upcomingBookings: upcomingBookings,
      completedBookings: completedBookings,
      cancelledBookings: cancelledBookings,
      totalSpent: totalSpent,
      averageSessionCost: averageSessionCost,
      totalHoursLearned: totalHoursLearned,
      totalTutorsWorkedWith: totalTutorsWorkedWith,
      favoriteSubjects: favoriteSubjects,
      recentBookings: recentBookings.map((dto) => dto.toDomain()).toList(),
      recentTransactions: recentTransactions
          .map((dto) => dto.toDomain())
          .toList(),
      progress: progress?.toDomain(),
      lastUpdated: lastUpdated,
      createdAt: createdAt,
      metadata: metadata ?? {},
    );
  }

  /// Create DTO from domain entity
  static StudentDashboardDto fromDomain(StudentDashboardEntity entity) {
    return StudentDashboardDto(
      id: entity.id,
      studentId: entity.studentId,
      totalBookings: entity.totalBookings,
      upcomingBookings: entity.upcomingBookings,
      completedBookings: entity.completedBookings,
      cancelledBookings: entity.cancelledBookings,
      totalSpent: entity.totalSpent,
      averageSessionCost: entity.averageSessionCost,
      totalHoursLearned: entity.totalHoursLearned,
      totalTutorsWorkedWith: entity.totalTutorsWorkedWith,
      favoriteSubjects: List.from(entity.favoriteSubjects),
      recentBookings: entity.recentBookings
          .map((booking) => RecentBookingDto.fromDomain(booking))
          .toList(),
      recentTransactions: entity.recentTransactions
          .map((transaction) => RecentTransactionDto.fromDomain(transaction))
          .toList(),
      progress: entity.progress != null
          ? StudentProgressDto.fromDomain(entity.progress!)
          : null,
      lastUpdated: entity.lastUpdated,
      createdAt: entity.createdAt,
      metadata: Map.from(entity.metadata),
    );
  }

  /// Create empty DTO for new student
  static StudentDashboardDto empty(String studentId) {
    final now = DateTime.now();
    return StudentDashboardDto(
      id: 'temp_${studentId}_${now.millisecondsSinceEpoch}',
      studentId: studentId,
      totalBookings: 0,
      upcomingBookings: 0,
      completedBookings: 0,
      cancelledBookings: 0,
      totalSpent: 0.0,
      averageSessionCost: 0.0,
      totalHoursLearned: 0,
      totalTutorsWorkedWith: 0,
      favoriteSubjects: [],
      recentBookings: [],
      recentTransactions: [],
      progress: null,
      lastUpdated: now,
      createdAt: now,
      metadata: {},
    );
  }
}

/// Data Transfer Object for Tutor Dashboard
///
/// This DTO handles serialization/deserialization for tutor dashboard data
/// including earnings, performance metrics, and verification status.
@freezed
class TutorDashboardDto with _$TutorDashboardDto {
  const factory TutorDashboardDto({
    required String id,
    required String tutorId,
    required double totalEarnings,
    required double thisMonthEarnings,
    required int totalBookings,
    required int completedBookings,
    required int pendingBookings,
    required int cancelledBookings,
    required double averageRating,
    required int totalReviews,
    required int totalStudentsWorkedWith,
    required List<String> teachingSubjects,
    required List<RecentBookingDto> recentBookings,
    required TutorPerformanceDto? performance,
    @JsonKey(name: 'verification_status') required String verificationStatus,
    required DateTime lastUpdated,
    required DateTime createdAt,
    Map<String, dynamic>? metadata,
  }) = _TutorDashboardDto;

  const TutorDashboardDto._();

  /// Create DTO from JSON (MongoDB/API response)
  factory TutorDashboardDto.fromJson(Map<String, dynamic> json) =>
      _$TutorDashboardDtoFromJson(json);

  /// Convert DTO to domain entity
  TutorDashboardEntity toDomain() {
    return TutorDashboardEntity(
      id: id,
      tutorId: tutorId,
      totalEarnings: totalEarnings,
      thisMonthEarnings: thisMonthEarnings,
      pendingEarnings: 0.0,
      totalBookings: totalBookings,
      completedBookings: completedBookings,
      pendingBookings: pendingBookings,
      cancelledBookings: cancelledBookings,
      averageRating: averageRating,
      totalReviews: totalReviews,
      totalStudentsWorkedWith: totalStudentsWorkedWith,
      teachingSubjects: teachingSubjects,
      recentBookings: recentBookings.map((dto) => dto.toDomain()).toList(),
      recentTransactions: const [],
      performance: performance?.toDomain(),
      verificationStatus: VerificationStatus.values.firstWhere(
        (status) =>
            status.name.toLowerCase() == verificationStatus.toLowerCase(),
        orElse: () => VerificationStatus.pending,
      ),
      lastUpdated: lastUpdated,
      createdAt: createdAt,
      metadata: metadata ?? {},
    );
  }

  /// Create DTO from domain entity
  static TutorDashboardDto fromDomain(TutorDashboardEntity entity) {
    return TutorDashboardDto(
      id: entity.id,
      tutorId: entity.tutorId,
      totalEarnings: entity.totalEarnings,
      thisMonthEarnings: entity.thisMonthEarnings,
      totalBookings: entity.totalBookings,
      completedBookings: entity.completedBookings,
      pendingBookings: entity.pendingBookings,
      cancelledBookings: entity.cancelledBookings,
      averageRating: entity.averageRating,
      totalReviews: entity.totalReviews,
      totalStudentsWorkedWith: entity.totalStudentsWorkedWith,
      teachingSubjects: List.from(entity.teachingSubjects),
      recentBookings: entity.recentBookings
          .map((booking) => RecentBookingDto.fromDomain(booking))
          .toList(),
      performance: entity.performance != null
          ? TutorPerformanceDto.fromDomain(entity.performance!)
          : null,
      verificationStatus: entity.verificationStatus.name,
      lastUpdated: entity.lastUpdated,
      createdAt: entity.createdAt,
      metadata: Map.from(entity.metadata),
    );
  }

  /// Create empty DTO for new tutor
  static TutorDashboardDto empty(String tutorId) {
    final now = DateTime.now();
    return TutorDashboardDto(
      id: 'temp_${tutorId}_${now.millisecondsSinceEpoch}',
      tutorId: tutorId,
      totalEarnings: 0.0,
      thisMonthEarnings: 0.0,
      totalBookings: 0,
      completedBookings: 0,
      pendingBookings: 0,
      cancelledBookings: 0,
      averageRating: 0.0,
      totalReviews: 0,
      totalStudentsWorkedWith: 0,
      teachingSubjects: [],
      recentBookings: [],
      performance: null,
      verificationStatus: VerificationStatus.pending.name,
      lastUpdated: now,
      createdAt: now,
      metadata: {},
    );
  }
}

/// Data Transfer Object for Recent Booking
@freezed
class RecentBookingDto with _$RecentBookingDto {
  const factory RecentBookingDto({
    required String id,
    required String studentId,
    required String tutorId,
    required String subject,
    required DateTime scheduledDate,
    required String status,
    required double amount,
    required int duration,
    String? notes,
  }) = _RecentBookingDto;

  const RecentBookingDto._();

  factory RecentBookingDto.fromJson(Map<String, dynamic> json) =>
      _$RecentBookingDtoFromJson(json);

  RecentBookingEntity toDomain() {
    return RecentBookingEntity(
      id: id,
      studentId: studentId,
      tutorId: tutorId,
      subject: subject,
      scheduledDate: scheduledDate,
      status: BookingStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == status.toLowerCase(),
        orElse: () => BookingStatus.scheduled,
      ),
      amount: amount,
      duration: duration,
      notes: notes,
    );
  }

  static RecentBookingDto fromDomain(RecentBookingEntity entity) {
    return RecentBookingDto(
      id: entity.id,
      studentId: entity.studentId,
      tutorId: entity.tutorId,
      subject: entity.subject,
      scheduledDate: entity.scheduledDate,
      status: entity.status.name,
      amount: entity.amount,
      duration: entity.duration,
      notes: entity.notes,
    );
  }
}

/// Data Transfer Object for Recent Transaction
@freezed
class RecentTransactionDto with _$RecentTransactionDto {
  const factory RecentTransactionDto({
    required String id,
    required String userId,
    required String type,
    required double amount,
    required String description,
    required String status,
    required DateTime createdAt,
    String? bookingId,
    Map<String, dynamic>? metadata,
  }) = _RecentTransactionDto;

  const RecentTransactionDto._();

  factory RecentTransactionDto.fromJson(Map<String, dynamic> json) =>
      _$RecentTransactionDtoFromJson(json);

  RecentTransactionEntity toDomain() {
    return RecentTransactionEntity(
      id: id,
      userId: userId,
      type: TransactionType.values.firstWhere(
        (t) => t.name.toLowerCase() == type.toLowerCase(),
        orElse: () => TransactionType.payment,
      ),
      amount: amount,
      description: description,
      status: TransactionStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == status.toLowerCase(),
        orElse: () => TransactionStatus.pending,
      ),
      createdAt: createdAt,
      bookingId: bookingId,
      metadata: metadata ?? {},
    );
  }

  static RecentTransactionDto fromDomain(RecentTransactionEntity entity) {
    return RecentTransactionDto(
      id: entity.id,
      userId: entity.userId,
      type: entity.type.name,
      amount: entity.amount,
      description: entity.description,
      status: entity.status.name,
      createdAt: entity.createdAt,
      bookingId: entity.bookingId,
      metadata: Map.from(entity.metadata),
    );
  }
}

/// Data Transfer Object for Student Progress
@freezed
class StudentProgressDto with _$StudentProgressDto {
  const factory StudentProgressDto({
    required String studentId,
    required Map<String, double> subjectProgress,
    required List<String> completedMilestones,
    required Map<String, dynamic> learningStats,
    required DateTime lastProgressUpdate,
  }) = _StudentProgressDto;

  const StudentProgressDto._();

  factory StudentProgressDto.fromJson(Map<String, dynamic> json) =>
      _$StudentProgressDtoFromJson(json);

  StudentProgressEntity toDomain() {
    return StudentProgressEntity(
      studentId: studentId,
      subjectProgress: Map.from(subjectProgress),
      completedMilestones: List.from(completedMilestones),
      learningStats: Map.from(learningStats),
      lastProgressUpdate: lastProgressUpdate,
    );
  }

  static StudentProgressDto fromDomain(StudentProgressEntity entity) {
    return StudentProgressDto(
      studentId: entity.studentId,
      subjectProgress: Map.from(entity.subjectProgress),
      completedMilestones: List.from(entity.completedMilestones),
      learningStats: Map.from(entity.learningStats),
      lastProgressUpdate: entity.lastProgressUpdate,
    );
  }
}

/// Data Transfer Object for Tutor Performance
@freezed
class TutorPerformanceDto with _$TutorPerformanceDto {
  const factory TutorPerformanceDto({
    required String tutorId,
    required double responseRate,
    required double completionRate,
    required double punctualityScore,
    required Map<String, dynamic> performanceMetrics,
    required DateTime lastPerformanceUpdate,
  }) = _TutorPerformanceDto;

  const TutorPerformanceDto._();

  factory TutorPerformanceDto.fromJson(Map<String, dynamic> json) =>
      _$TutorPerformanceDtoFromJson(json);

  TutorPerformanceEntity toDomain() {
    return TutorPerformanceEntity(
      tutorId: tutorId,
      responseRate: responseRate,
      completionRate: completionRate,
      punctualityScore: punctualityScore,
      performanceMetrics: Map.from(performanceMetrics),
      lastPerformanceUpdate: lastPerformanceUpdate,
    );
  }

  static TutorPerformanceDto fromDomain(TutorPerformanceEntity entity) {
    return TutorPerformanceDto(
      tutorId: entity.tutorId,
      responseRate: entity.responseRate,
      completionRate: entity.completionRate,
      punctualityScore: entity.punctualityScore,
      performanceMetrics: Map.from(entity.performanceMetrics),
      lastPerformanceUpdate: entity.lastPerformanceUpdate,
    );
  }
}
