import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/admin_repository.dart';
import '../state/admin_state.dart';

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminRepository repository;

  AdminNotifier({required this.repository}) : super(const AdminState());

  /// Fetch all users (paginated)
  Future<void> fetchUsers({int page = 1, int limit = 10, String? role}) async {
    state = state.copyWith(isLoading: true, error: null, currentPage: page);

    final result = await repository.getAllUsers(
      page: page,
      limit: limit,
      role: role,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (data) => state = state.copyWith(
        isLoading: false,
        users: data.users,
        totalUsers: data.total,
        totalPages: data.pages,
        roleFilter: role,
      ),
    );
  }

  /// Fetch platform statistics
  Future<void> fetchStats() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.getPlatformStats();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (stats) => state = state.copyWith(isLoading: false, stats: stats),
    );
  }

  /// Seed test tutors
  Future<bool> seedTutors({int count = 5}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.seedTutors(count: count);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (message) {
        state = state.copyWith(isLoading: false, successMessage: message);
        return true;
      },
    );
  }

  /// Verify a tutor
  Future<bool> verifyTutor({
    required String tutorId,
    required String status,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.verifyTutor(
      tutorId: tutorId,
      status: status,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Tutor status updated to $status',
        );
        return true;
      },
    );
  }

  /// Get user by ID
  Future<void> fetchUserById(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.getUserById(id);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        selectedUser: user,
      ),
    );
  }

  /// Update user
  Future<bool> updateUser({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.updateUser(id: id, data: data);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          selectedUser: user,
          successMessage: 'User updated successfully',
        );
        return true;
      },
    );
  }

  /// Delete user
  Future<bool> deleteUser(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.deleteUser(id);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          users: state.users.where((u) => u.id != id).toList(),
          successMessage: 'User deleted',
        );
        return true;
      },
    );
  }

  /// Create announcement
  Future<bool> createAnnouncement({
    required String title,
    required String content,
    String targetRole = 'ALL',
    String type = 'INFO',
    DateTime? expiresAt,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.createAnnouncement(
      title: title,
      content: content,
      targetRole: targetRole,
      type: type,
      expiresAt: expiresAt,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (announcement) {
        state = state.copyWith(
          isLoading: false,
          announcements: [announcement, ...state.announcements],
          successMessage: 'Announcement created',
        );
        return true;
      },
    );
  }

  /// Fetch announcements
  Future<void> fetchAnnouncements() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.getAnnouncements();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (announcements) => state = state.copyWith(
        isLoading: false,
        announcements: announcements,
      ),
    );
  }

  /// Delete announcement
  Future<bool> deleteAnnouncement(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.deleteAnnouncement(id);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          announcements: state.announcements.where((a) => a.id != id).toList(),
          successMessage: 'Announcement deleted',
        );
        return true;
      },
    );
  }

  /// Load next page
  Future<void> loadNextPage() async {
    if (state.currentPage < state.totalPages) {
      await fetchUsers(
        page: state.currentPage + 1,
        role: state.roleFilter,
      );
    }
  }
}
