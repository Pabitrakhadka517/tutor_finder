import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_entities.dart';

class AdminState extends Equatable {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  // Users management
  final List<AdminUserEntity> users;
  final int totalUsers;
  final int totalPages;
  final int currentPage;
  final String? roleFilter;

  // Stats
  final PlatformStatsEntity? stats;

  // Selected user detail
  final AdminUserEntity? selectedUser;

  // Announcements
  final List<AnnouncementEntity> announcements;

  const AdminState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.users = const [],
    this.totalUsers = 0,
    this.totalPages = 1,
    this.currentPage = 1,
    this.roleFilter,
    this.stats,
    this.selectedUser,
    this.announcements = const [],
  });

  AdminState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    List<AdminUserEntity>? users,
    int? totalUsers,
    int? totalPages,
    int? currentPage,
    String? roleFilter,
    PlatformStatsEntity? stats,
    AdminUserEntity? selectedUser,
    List<AnnouncementEntity>? announcements,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      users: users ?? this.users,
      totalUsers: totalUsers ?? this.totalUsers,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      roleFilter: roleFilter ?? this.roleFilter,
      stats: stats ?? this.stats,
      selectedUser: selectedUser ?? this.selectedUser,
      announcements: announcements ?? this.announcements,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        successMessage,
        users,
        totalUsers,
        totalPages,
        currentPage,
        roleFilter,
        stats,
        selectedUser,
        announcements,
      ];
}
