import 'package:injectable/injectable.dart';

import '../../../../core/utils/either.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/failures/dashboard_failure.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/value_objects/user_role.dart';
import '../datasources/dashboard_local_datasource.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_models.dart';

@Injectable(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;
  final IDashboardLocalDataSource _localDataSource;

  const DashboardRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<DashboardFailure, StudentDashboardEntity>> getStudentDashboard(
    String studentId,
  ) async {
    try {
      final model = await _remoteDataSource.getStudentDashboard();
      return Right(_studentModelToEntity(studentId, model));
    } catch (e) {
      return Left(
        DashboardFailure.serverError('Failed to get student dashboard: $e'),
      );
    }
  }

  @override
  Future<Either<DashboardFailure, TutorDashboardEntity>> getTutorDashboard(
    String tutorId,
  ) async {
    try {
      final model = await _remoteDataSource.getTutorDashboard();
      return Right(_tutorModelToEntity(tutorId, model));
    } catch (e) {
      return Left(
        DashboardFailure.serverError('Failed to get tutor dashboard: $e'),
      );
    }
  }

  @override
  Future<Either<DashboardFailure, StudentDashboardEntity>>
  getStudentDashboardByDateRange(
    String studentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final model = await _remoteDataSource.getStudentDashboard();
      return Right(_studentModelToEntity(studentId, model));
    } catch (e) {
      return Left(
        DashboardFailure.serverError(
          'Failed to get student dashboard by date range: $e',
        ),
      );
    }
  }

  @override
  Future<Either<DashboardFailure, TutorDashboardEntity>>
  getTutorDashboardByDateRange(
    String tutorId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final model = await _remoteDataSource.getTutorDashboard();
      return Right(_tutorModelToEntity(tutorId, model));
    } catch (e) {
      return Left(
        DashboardFailure.serverError(
          'Failed to get tutor dashboard by date range: $e',
        ),
      );
    }
  }

  @override
  Future<Either<DashboardFailure, DashboardEntity>> getDashboardByRole(
    String userId,
    UserRole role,
  ) async {
    if (role == UserRole.student) return getStudentDashboard(userId);
    if (role == UserRole.tutor) return getTutorDashboard(userId);
    return const Left(DashboardFailure.permissionDenied('Role not supported'));
  }

  @override
  Future<Either<DashboardFailure, bool>> hasMinimumDataForDashboard(
    String userId,
    UserRole role,
  ) async => const Right(true);

  @override
  Future<Either<DashboardFailure, Map<String, dynamic>>> getDashboardSummary(
    String userId,
    UserRole role,
  ) async => Right({'userId': userId, 'role': role.value});

  @override
  Future<Either<DashboardFailure, void>> refreshDashboardCache(
    String userId,
    UserRole role,
  ) async {
    try {
      await _localDataSource.clearUserCache(userId, role.value);
      return const Right(null);
    } catch (e) {
      return Left(DashboardFailure.serverError('Failed to refresh cache: $e'));
    }
  }

  @override
  Future<Either<DashboardFailure, bool>> isDashboardCacheValid(
    String userId,
    UserRole role,
  ) async {
    try {
      return Right(await _localDataSource.isCacheValid(userId, role.value));
    } catch (_) {
      return const Right(false);
    }
  }

  @override
  Future<Either<DashboardFailure, Map<String, dynamic>>> getDashboardComparison(
    String userId,
    UserRole role,
    DateTime currentStart,
    DateTime currentEnd,
    DateTime previousStart,
    DateTime previousEnd,
  ) async => const Right({});

  @override
  Future<Either<DashboardFailure, Map<String, List<dynamic>>>>
  getDashboardTrends(
    String userId,
    UserRole role,
    DateTime startDate,
    DateTime endDate,
    String interval,
  ) async => const Right({});

  @override
  Future<Either<DashboardFailure, bool>> validateDashboardAccess(
    String userId,
    UserRole role,
  ) async => const Right(true);

  @override
  Future<Either<DashboardFailure, bool>> validateDashboardData(
    String userId,
    UserRole role,
  ) async => const Right(true);

  // ── Helpers ────────────────────────────────────────────────────────────

  StudentDashboardEntity _studentModelToEntity(
    String studentId,
    StudentDashboardModel model,
  ) {
    final now = DateTime.now();
    return StudentDashboardEntity(
      id: studentId,
      studentId: studentId,
      totalBookings: model.totalBookings,
      upcomingBookings: model.upcomingBookings,
      completedBookings: model.completedBookings,
      cancelledBookings: 0,
      totalSpent: model.totalSpent,
      averageSessionCost: model.totalBookings > 0
          ? model.totalSpent / model.totalBookings
          : 0,
      totalHoursLearned: 0,
      totalTutorsWorkedWith: model.totalTutorsWorkedWith,
      favoriteSubjects: const [],
      recentBookings: model.parseRecentBookings(),
      recentTransactions: model.parseRecentTransactions(),
      lastUpdated: now,
      createdAt: now,
    );
  }

  TutorDashboardEntity _tutorModelToEntity(
    String tutorId,
    TutorDashboardModel model,
  ) {
    final now = DateTime.now();
    return TutorDashboardEntity(
      id: tutorId,
      tutorId: tutorId,
      totalEarnings: model.totalEarnings,
      thisMonthEarnings: 0.0,
      pendingEarnings: 0.0,
      totalStudentsWorkedWith: model.totalStudentsWorkedWith,
      totalBookings: model.totalBookings,
      completedBookings: model.completedBookings,
      pendingBookings: model.pendingBookings,
      cancelledBookings: 0,
      averageRating: model.averageRating,
      totalReviews: 0,
      teachingSubjects: const [],
      verificationStatus: _mapVerificationStatus(model.verificationStatus),
      recentBookings: model.parseRecentBookings(),
      recentTransactions: model.parseRecentTransactions(),
      lastUpdated: now,
      createdAt: now,
    );
  }

  static VerificationStatus _mapVerificationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return VerificationStatus.verified;
      case 'pending':
        return VerificationStatus.pending;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'expired':
        return VerificationStatus.expired;
      default:
        return VerificationStatus.pending;
    }
  }
}
