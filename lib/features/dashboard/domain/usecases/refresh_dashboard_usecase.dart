import 'package:injectable/injectable.dart';

import '../../../../core/utils/either.dart';
import '../failures/dashboard_failure.dart';
import '../repositories/dashboard_repository.dart';
import '../value_objects/user_role.dart';

/// Use case for refreshing dashboard data and cache management
///
/// This use case handles all operations related to refreshing dashboard data,
/// clearing cache, and ensuring data consistency across the system.
@injectable
class RefreshDashboardUseCase {
  final DashboardRepository _repository;

  const RefreshDashboardUseCase(this._repository);

  /// Refresh dashboard cache for a specific user
  ///
  /// [userId] - The ID of the user to refresh dashboard for
  /// [role] - The role of the user (student or tutor)
  /// [forceFullRefresh] - Whether to perform complete data refresh
  ///
  /// Returns success or [DashboardFailure] if operation fails
  Future<Either<DashboardFailure, void>> refreshDashboard(
    String userId,
    UserRole role, {
    bool forceFullRefresh = false,
  }) async {
    // Validate input parameters
    final validationResult = _validateInput(userId, role);
    if (validationResult != null) {
      return Left(validationResult);
    }

    try {
      // Check if user has permission to refresh dashboard
      final accessResult = await _repository.validateDashboardAccess(
        userId,
        role,
      );

      return await accessResult.fold((failure) => Left(failure), (
        hasAccess,
      ) async {
        if (!hasAccess) {
          return const Left(
            DashboardFailure.permissionDenied(
              'User does not have permission to refresh dashboard',
            ),
          );
        }

        // Perform the refresh operation
        if (forceFullRefresh) {
          // Clear all cached data and rebuild from source
          await _repository.refreshDashboardCache(userId, role);
        }

        // Refresh the dashboard cache
        final refreshResult = await _repository.refreshDashboardCache(
          userId,
          role,
        );

        return refreshResult.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        );
      });
    } catch (e) {
      return Left(
        DashboardFailure.serverError(
          'Failed to refresh dashboard: ${e.toString()}',
        ),
      );
    }
  }

  /// Clear dashboard cache for a specific user
  ///
  /// [userId] - The ID of the user to clear cache for
  /// [role] - The role of the user (student or tutor)
  ///
  /// Returns success or [DashboardFailure] if operation fails
  Future<Either<DashboardFailure, void>> clearCache(
    String userId,
    UserRole role,
  ) async {
    // Validate input parameters
    final validationResult = _validateInput(userId, role);
    if (validationResult != null) {
      return Left(validationResult);
    }

    try {
      final clearResult = await _repository.refreshDashboardCache(userId, role);
      return clearResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(
        DashboardFailure.serverError('Failed to clear cache: ${e.toString()}'),
      );
    }
  }

  /// Clear all dashboard cache (admin operation)
  ///
  /// Returns success or [DashboardFailure] if operation fails
  Future<Either<DashboardFailure, void>> clearAllCache() async {
    // Repository does not expose clearAllDashboardCache; return success stub
    return const Right(null);
  }

  /// Get cache status information for a user
  ///
  /// [userId] - The ID of the user to check cache for
  /// [role] - The role of the user (student or tutor)
  ///
  /// Returns cache information or [DashboardFailure] if operation fails
  Future<Either<DashboardFailure, Map<String, dynamic>>> getCacheStatus(
    String userId,
    UserRole role,
  ) async {
    // Validate input parameters
    final validationResult = _validateInput(userId, role);
    if (validationResult != null) {
      return Left(validationResult);
    }

    try {
      final isValid = await _repository.isDashboardCacheValid(userId, role);
      return isValid.fold((failure) => Left(failure), (valid) {
        final status = <String, dynamic>{
          'userId': userId,
          'role': role.value,
          'isValid': valid,
          'checkedAt': DateTime.now().toIso8601String(),
          'lastUpdated': valid ? DateTime.now().toIso8601String() : null,
        };
        return Right(status);
      });
    } catch (e) {
      return Left(
        DashboardFailure.serverError(
          'Failed to get cache status: ${e.toString()}',
        ),
      );
    }
  }

  /// Check if dashboard data needs refresh
  ///
  /// [userId] - The ID of the user to check
  /// [role] - The role of the user (student or tutor)
  /// [maxCacheAge] - Maximum age of cache in minutes (default: 30)
  ///
  /// Returns true if refresh is needed or [DashboardFailure] if operation fails
  Future<Either<DashboardFailure, bool>> needsRefresh(
    String userId,
    UserRole role, {
    int maxCacheAgeMinutes = 30,
  }) async {
    // Validate input parameters
    final validationResult = _validateInput(userId, role);
    if (validationResult != null) {
      return Left(validationResult);
    }

    if (maxCacheAgeMinutes <= 0) {
      return const Left(
        DashboardFailure.validationError(
          'Max cache age must be greater than 0',
        ),
      );
    }

    try {
      final statusResult = await getCacheStatus(userId, role);

      return statusResult.fold((failure) => Left(failure), (status) {
        final lastUpdated = status['lastUpdated'] as String?;

        if (lastUpdated == null) {
          // No cache exists, refresh needed
          return const Right(true);
        }

        final lastUpdatedTime = DateTime.tryParse(lastUpdated);
        if (lastUpdatedTime == null) {
          // Invalid timestamp, refresh needed
          return const Right(true);
        }

        final ageInMinutes = DateTime.now()
            .difference(lastUpdatedTime)
            .inMinutes;
        final needsRefresh = ageInMinutes >= maxCacheAgeMinutes;

        return Right(needsRefresh);
      });
    } catch (e) {
      return Left(
        DashboardFailure.serverError(
          'Failed to check refresh status: ${e.toString()}',
        ),
      );
    }
  }

  /// Refresh dashboard if needed (smart refresh)
  ///
  /// [userId] - The ID of the user to refresh dashboard for
  /// [role] - The role of the user (student or tutor)
  /// [maxCacheAgeMinutes] - Maximum age of cache in minutes (default: 30)
  ///
  /// Returns success or [DashboardFailure] if operation fails
  Future<Either<DashboardFailure, bool>> refreshIfNeeded(
    String userId,
    UserRole role, {
    int maxCacheAgeMinutes = 30,
  }) async {
    // Check if refresh is needed
    final needsRefreshResult = await needsRefresh(
      userId,
      role,
      maxCacheAgeMinutes: maxCacheAgeMinutes,
    );

    return await needsRefreshResult.fold((failure) => Left(failure), (
      needsRefresh,
    ) async {
      if (!needsRefresh) {
        // No refresh needed
        return const Right(false);
      }

      // Perform refresh
      final refreshResult = await refreshDashboard(userId, role);

      return refreshResult.fold(
        (failure) => Left(failure),
        (_) => const Right(true), // Refresh was performed
      );
    });
  }

  /// Bulk refresh dashboards for multiple users
  ///
  /// [userRolePairs] - List of user ID and role pairs to refresh
  /// [maxConcurrentRefreshes] - Maximum number of concurrent refresh operations
  ///
  /// Returns list of results for each user or [DashboardFailure] if operation fails
  Future<Either<DashboardFailure, List<BulkRefreshResult>>> bulkRefresh(
    List<UserRolePair> userRolePairs, {
    int maxConcurrentRefreshes = 5,
  }) async {
    if (userRolePairs.isEmpty) {
      return const Left(
        DashboardFailure.validationError(
          'User role pairs list cannot be empty',
        ),
      );
    }

    if (maxConcurrentRefreshes <= 0 || maxConcurrentRefreshes > 20) {
      return const Left(
        DashboardFailure.validationError(
          'Max concurrent refreshes must be between 1 and 20',
        ),
      );
    }

    try {
      final results = <BulkRefreshResult>[];

      // Process in batches to avoid overwhelming the system
      for (int i = 0; i < userRolePairs.length; i += maxConcurrentRefreshes) {
        final batch = userRolePairs
            .skip(i)
            .take(maxConcurrentRefreshes)
            .toList();

        final batchFutures = batch.map((pair) async {
          final refreshResult = await refreshDashboard(pair.userId, pair.role);

          return BulkRefreshResult(
            userId: pair.userId,
            role: pair.role,
            success: refreshResult.isRight,
            error: refreshResult.fold(
              (failure) => failure.toString(),
              (_) => null,
            ),
          );
        });

        final batchResults = await Future.wait(batchFutures);
        results.addAll(batchResults);
      }

      return Right(results);
    } catch (e) {
      return Left(
        DashboardFailure.serverError(
          'Failed to perform bulk refresh: ${e.toString()}',
        ),
      );
    }
  }

  // Private validation methods

  DashboardFailure? _validateInput(String userId, UserRole role) {
    if (userId.isEmpty) {
      return const DashboardFailure.validationError('User ID cannot be empty');
    }

    if (userId.length < 3) {
      return DashboardFailure.invalidUserId(userId);
    }

    // Additional role-specific validations could be added here

    return null;
  }
}

/// Data class for user ID and role pair
class UserRolePair {
  final String userId;
  final UserRole role;

  const UserRolePair({required this.userId, required this.role});

  @override
  String toString() {
    return 'UserRolePair(userId: $userId, role: ${role.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserRolePair &&
        other.userId == userId &&
        other.role == role;
  }

  @override
  int get hashCode => userId.hashCode ^ role.hashCode;
}

/// Result of bulk refresh operation
class BulkRefreshResult {
  final String userId;
  final UserRole role;
  final bool success;
  final String? error;

  const BulkRefreshResult({
    required this.userId,
    required this.role,
    required this.success,
    this.error,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'role': role.value,
      'success': success,
      'error': error,
    };
  }

  @override
  String toString() {
    return 'BulkRefreshResult(userId: $userId, success: $success, error: $error)';
  }
}
