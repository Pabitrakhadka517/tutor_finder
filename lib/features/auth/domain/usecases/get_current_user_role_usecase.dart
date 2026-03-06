import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for extracting the current user's role.
/// On app start this is used to decide between
/// StudentDashboard / TutorDashboard / AdminDashboard.
///
/// The implementation first tries to decode the stored JWT locally
/// (fast, no network), falling back to a full [getCurrentUser] call.
class GetCurrentUserRoleUseCase {
  final AuthRepository repository;

  GetCurrentUserRoleUseCase(this.repository);

  /// Returns the [UserRole] or `null` when the user is not authenticated.
  Future<UserRole?> call() async {
    // Try fast JWT-based role extraction first
    final role = await repository.getUserRoleFromToken();
    if (role != null) return role;

    // Fallback: full getCurrentUser call
    final result = await repository.getCurrentUser();
    return result.fold((_) => null, (user) => user?.role);
  }
}
