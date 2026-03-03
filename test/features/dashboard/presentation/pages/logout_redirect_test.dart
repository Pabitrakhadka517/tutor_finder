import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tutor_finder/core/error/failures.dart';
import 'package:tutor_finder/core/services/socket/socket_service.dart';
import 'package:tutor_finder/core/utils/either.dart';
import 'package:tutor_finder/core/utils/unit.dart';
import 'package:tutor_finder/features/auth/data/models/forgot_password_response.dart';
import 'package:tutor_finder/features/auth/domain/entities/user.dart';
import 'package:tutor_finder/features/auth/domain/repositories/auth_repository.dart';
import 'package:tutor_finder/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:tutor_finder/features/auth/domain/usecases/get_current_user_role_usecase.dart';
import 'package:tutor_finder/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:tutor_finder/features/auth/domain/usecases/login_usecase.dart';
import 'package:tutor_finder/features/auth/domain/usecases/logout_usecase.dart';
import 'package:tutor_finder/features/auth/domain/usecases/register_admin_usecase.dart';
import 'package:tutor_finder/features/auth/domain/usecases/register_tutor_usecase.dart';
import 'package:tutor_finder/features/auth/domain/usecases/register_usecase.dart';
import 'package:tutor_finder/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:tutor_finder/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:tutor_finder/features/auth/presentation/providers/auth_providers.dart';
import 'package:tutor_finder/features/auth/presentation/state/auth_state.dart';
import 'package:tutor_finder/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:tutor_finder/features/dashboard/data/models/dashboard_models.dart';
import 'package:tutor_finder/features/dashboard/domain/dashboard_repository.dart';
import 'package:tutor_finder/features/dashboard/presentation/notifiers/dashboard_notifier.dart';
import 'package:tutor_finder/features/dashboard/presentation/pages/role_based_dashboard_shell.dart';
import 'package:tutor_finder/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:tutor_finder/features/notification/domain/entities/notification_entity.dart';
import 'package:tutor_finder/features/notification/domain/failures/notification_failures.dart';
import 'package:tutor_finder/features/notification/domain/notification_repository.dart';
import 'package:tutor_finder/features/notification/presentation/notifiers/notification_notifier.dart';
import 'package:tutor_finder/features/notification/presentation/providers/notification_providers.dart';

void main() {
  Widget createWidgetUnderTest(UserRole role) {
    return ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith((ref) => _TestAuthNotifier(role)),
        notificationNotifierProvider.overrideWith(
          (ref) => _TestNotificationNotifier(),
        ),
        dashboardNotifierProvider.overrideWith(
          (ref) => _TestDashboardNotifier(),
        ),
        socketServiceProvider.overrideWithValue(_FakeSocketService()),
      ],
      child: const MaterialApp(home: RoleBasedDashboardShell()),
    );
  }

  Future<void> _logoutFromDrawer(WidgetTester tester) async {
    final scaffoldFinder = find.byWidgetPredicate(
      (widget) => widget is Scaffold && widget.drawer != null,
    );
    final scaffoldState = tester.state<ScaffoldState>(scaffoldFinder.first);
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    final logoutTileFinder = find.byWidgetPredicate(
      (widget) =>
          widget is ListTile &&
          widget.title is Text &&
          (widget.title as Text).data == 'Logout',
      skipOffstage: false,
    );
    final logoutTile = tester.widget<ListTile>(logoutTileFinder.first);
    logoutTile.onTap?.call();
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout').first);
    await tester.pumpAndSettle();
  }

  group('RoleBasedDashboardShell logout redirect', () {
    testWidgets('redirects tutor to Tutor login page on logout', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(UserRole.tutor));
      await tester.pumpAndSettle();

      await _logoutFromDrawer(tester);

      expect(find.text('Login as Tutor'), findsOneWidget);
    });

    testWidgets('keeps student redirect to Student login page on logout', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(UserRole.student));
      await tester.pumpAndSettle();

      await _logoutFromDrawer(tester);

      expect(find.text('Login as Student'), findsOneWidget);
    });
  });
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(UserRole role)
    : super(
        signUpUseCase: SignUpUseCase(_FakeAuthRepository()),
        loginUseCase: LoginUseCase(_FakeAuthRepository()),
        logoutUseCase: LogoutUseCase(_FakeAuthRepository()),
        getCurrentUserUseCase: GetCurrentUserUseCase(_FakeAuthRepository()),
        getCurrentUserRoleUseCase: GetCurrentUserRoleUseCase(
          _FakeAuthRepository(),
        ),
        checkAuthStatusUseCase: CheckAuthStatusUseCase(_FakeAuthRepository()),
        registerUseCase: RegisterUseCase(_FakeAuthRepository()),
        registerAdminUseCase: RegisterAdminUseCase(_FakeAuthRepository()),
        registerTutorUseCase: RegisterTutorUseCase(_FakeAuthRepository()),
        authRepository: _FakeAuthRepository(),
      ) {
    state = AuthState.authenticated(
      User(
        id: 'test-user',
        email: 'test@example.com',
        fullName: 'Test User',
        role: role,
        createdAt: DateTime(2026, 1, 1),
      ),
    );
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestNotificationNotifier extends NotificationNotifier {
  _TestNotificationNotifier() : super(_FakeNotificationRepository());
}

class _FakeNotificationRepository implements NotificationRepository {
  @override
  Future<void> connectWebSocket(String userId) async {}

  @override
  Future<void> disconnectWebSocket() async {}

  @override
  Future<Either<NotificationFailure, Unit>> deleteNotification(
    String notificationId,
  ) async {
    return const Right(unit);
  }

  @override
  Future<Either<NotificationFailure, List<NotificationEntity>>>
  getNotifications({int page = 1, int limit = 20}) async {
    return const Right([]);
  }

  @override
  Future<Either<NotificationFailure, int>> getUnreadCount() async {
    return const Right(0);
  }

  @override
  Future<Either<NotificationFailure, Unit>> markAllAsRead() async {
    return const Right(unit);
  }

  @override
  Future<Either<NotificationFailure, Unit>> markAsRead(
    String notificationId,
  ) async {
    return const Right(unit);
  }

  @override
  Stream<NotificationEntity> get realtimeNotifications => const Stream.empty();
}

class _TestDashboardNotifier extends DashboardNotifier {
  _TestDashboardNotifier()
    : super(
        repository: _FakeDashboardRepository(),
        remoteDataSource: _FakeDashboardRemoteDataSource(),
      );

  @override
  Future<void> fetchStudentDashboard(String studentId) async {}

  @override
  Future<void> fetchTutorDashboard(String tutorId) async {}

  @override
  Future<void> fetchAdminDashboard() async {}
}

class _FakeDashboardRepository implements DashboardRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDashboardRemoteDataSource implements DashboardRemoteDataSource {
  @override
  Future<AdminDashboardModel> getAdminDashboard() async {
    return AdminDashboardModel.fromJson({});
  }

  @override
  Future<StudentDashboardModel> getStudentDashboard() async {
    return StudentDashboardModel.fromJson({});
  }

  @override
  Future<TutorDashboardModel> getTutorDashboard() async {
    return TutorDashboardModel.fromJson({});
  }
}

class _FakeSocketService extends SocketService {
  @override
  Future<void> connect() async {}

  @override
  void onNewNotification(void Function(dynamic data) callback) {}

  @override
  void off(String event) {}
}
