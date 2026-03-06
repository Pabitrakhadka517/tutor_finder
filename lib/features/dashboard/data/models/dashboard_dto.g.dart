// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudentDashboardDtoImpl _$$StudentDashboardDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$StudentDashboardDtoImpl(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      totalBookings: (json['totalBookings'] as num).toInt(),
      upcomingBookings: (json['upcomingBookings'] as num).toInt(),
      completedBookings: (json['completedBookings'] as num).toInt(),
      cancelledBookings: (json['cancelledBookings'] as num).toInt(),
      totalSpent: (json['totalSpent'] as num).toDouble(),
      averageSessionCost: (json['averageSessionCost'] as num).toDouble(),
      totalHoursLearned: (json['totalHoursLearned'] as num).toInt(),
      totalTutorsWorkedWith: (json['totalTutorsWorkedWith'] as num).toInt(),
      favoriteSubjects: (json['favoriteSubjects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recentBookings: (json['recentBookings'] as List<dynamic>)
          .map((e) => RecentBookingDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentTransactions: (json['recentTransactions'] as List<dynamic>)
          .map((e) => RecentTransactionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      progress: json['progress'] == null
          ? null
          : StudentProgressDto.fromJson(
              json['progress'] as Map<String, dynamic>),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$StudentDashboardDtoImplToJson(
        _$StudentDashboardDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'totalBookings': instance.totalBookings,
      'upcomingBookings': instance.upcomingBookings,
      'completedBookings': instance.completedBookings,
      'cancelledBookings': instance.cancelledBookings,
      'totalSpent': instance.totalSpent,
      'averageSessionCost': instance.averageSessionCost,
      'totalHoursLearned': instance.totalHoursLearned,
      'totalTutorsWorkedWith': instance.totalTutorsWorkedWith,
      'favoriteSubjects': instance.favoriteSubjects,
      'recentBookings': instance.recentBookings,
      'recentTransactions': instance.recentTransactions,
      'progress': instance.progress,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'metadata': instance.metadata,
    };

_$TutorDashboardDtoImpl _$$TutorDashboardDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorDashboardDtoImpl(
      id: json['id'] as String,
      tutorId: json['tutorId'] as String,
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      thisMonthEarnings: (json['thisMonthEarnings'] as num).toDouble(),
      totalBookings: (json['totalBookings'] as num).toInt(),
      completedBookings: (json['completedBookings'] as num).toInt(),
      pendingBookings: (json['pendingBookings'] as num).toInt(),
      cancelledBookings: (json['cancelledBookings'] as num).toInt(),
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
      totalStudentsWorkedWith: (json['totalStudentsWorkedWith'] as num).toInt(),
      teachingSubjects: (json['teachingSubjects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recentBookings: (json['recentBookings'] as List<dynamic>)
          .map((e) => RecentBookingDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      performance: json['performance'] == null
          ? null
          : TutorPerformanceDto.fromJson(
              json['performance'] as Map<String, dynamic>),
      verificationStatus: json['verification_status'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$TutorDashboardDtoImplToJson(
        _$TutorDashboardDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tutorId': instance.tutorId,
      'totalEarnings': instance.totalEarnings,
      'thisMonthEarnings': instance.thisMonthEarnings,
      'totalBookings': instance.totalBookings,
      'completedBookings': instance.completedBookings,
      'pendingBookings': instance.pendingBookings,
      'cancelledBookings': instance.cancelledBookings,
      'averageRating': instance.averageRating,
      'totalReviews': instance.totalReviews,
      'totalStudentsWorkedWith': instance.totalStudentsWorkedWith,
      'teachingSubjects': instance.teachingSubjects,
      'recentBookings': instance.recentBookings,
      'performance': instance.performance,
      'verification_status': instance.verificationStatus,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'metadata': instance.metadata,
    };

_$RecentBookingDtoImpl _$$RecentBookingDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$RecentBookingDtoImpl(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      tutorId: json['tutorId'] as String,
      subject: json['subject'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      duration: (json['duration'] as num).toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$RecentBookingDtoImplToJson(
        _$RecentBookingDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'tutorId': instance.tutorId,
      'subject': instance.subject,
      'scheduledDate': instance.scheduledDate.toIso8601String(),
      'status': instance.status,
      'amount': instance.amount,
      'duration': instance.duration,
      'notes': instance.notes,
    };

_$RecentTransactionDtoImpl _$$RecentTransactionDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$RecentTransactionDtoImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      bookingId: json['bookingId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$RecentTransactionDtoImplToJson(
        _$RecentTransactionDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'amount': instance.amount,
      'description': instance.description,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'bookingId': instance.bookingId,
      'metadata': instance.metadata,
    };

_$StudentProgressDtoImpl _$$StudentProgressDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$StudentProgressDtoImpl(
      studentId: json['studentId'] as String,
      subjectProgress: (json['subjectProgress'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      completedMilestones: (json['completedMilestones'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      learningStats: json['learningStats'] as Map<String, dynamic>,
      lastProgressUpdate: DateTime.parse(json['lastProgressUpdate'] as String),
    );

Map<String, dynamic> _$$StudentProgressDtoImplToJson(
        _$StudentProgressDtoImpl instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'subjectProgress': instance.subjectProgress,
      'completedMilestones': instance.completedMilestones,
      'learningStats': instance.learningStats,
      'lastProgressUpdate': instance.lastProgressUpdate.toIso8601String(),
    };

_$TutorPerformanceDtoImpl _$$TutorPerformanceDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TutorPerformanceDtoImpl(
      tutorId: json['tutorId'] as String,
      responseRate: (json['responseRate'] as num).toDouble(),
      completionRate: (json['completionRate'] as num).toDouble(),
      punctualityScore: (json['punctualityScore'] as num).toDouble(),
      performanceMetrics: json['performanceMetrics'] as Map<String, dynamic>,
      lastPerformanceUpdate:
          DateTime.parse(json['lastPerformanceUpdate'] as String),
    );

Map<String, dynamic> _$$TutorPerformanceDtoImplToJson(
        _$TutorPerformanceDtoImpl instance) =>
    <String, dynamic>{
      'tutorId': instance.tutorId,
      'responseRate': instance.responseRate,
      'completionRate': instance.completionRate,
      'punctualityScore': instance.punctualityScore,
      'performanceMetrics': instance.performanceMetrics,
      'lastPerformanceUpdate': instance.lastPerformanceUpdate.toIso8601String(),
    };
