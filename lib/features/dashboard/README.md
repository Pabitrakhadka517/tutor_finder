# Dashboard Module

A comprehensive dashboard implementation for the tutoring platform, following Clean Architecture principles with role-based access control for Students and Tutors.

## Overview

This module provides role-specific dashboard functionality with:
- **Student Dashboard**: Activity tracking, progress indicators, subject breakdown, upcoming sessions
- **Tutor Dashboard**: Performance metrics, earnings overview, student management, verification status
- **Clean Architecture**: Separation of concerns across domain, data, and presentation layers
- **Caching System**: Local data persistence with SharedPreferences
- **Error Handling**: User-friendly error messages and retry mechanisms

## Architecture

```
dashboard/
├── domain/                     # Business logic and rules
│   ├── entities/              # Core business entities
│   ├── failures/              # Domain-specific error types
│   ├── repository/            # Repository contracts
│   └── usecases/              # Business use cases
├── data/                      # Data access and management
│   ├── datasources/           # Remote and local data sources
│   ├── models/                # DTOs for API communication
│   └── repository/            # Repository implementations
├── presentation/              # UI layer
│   ├── controllers/           # State management
│   ├── models/                # Presentation models
│   └── widgets/               # UI components
└── dashboard_module.dart      # Dependency injection setup
```

## Features

### Student Dashboard
- **Statistics Grid**: Total sessions, completed sessions, upcoming sessions, progress percentage
- **Recent Activity**: Session history with tutor details and session status
- **Progress Tracking**: Visual progress indicators with motivational messages
- **Subject Breakdown**: Performance across different subjects

### Tutor Dashboard
- **Statistics Grid**: Total students, earnings this month, sessions conducted, rating score
- **Performance Indicators**: Overall performance score with detailed metrics
- **Verification Status**: Account verification and badge system
- **Student Management**: Recent student interactions and feedback

### Shared Components
- **Loading States**: Animated loading indicators with progress messages
- **Error Handling**: User-friendly error displays with retry functionality
- **Responsive Design**: Adaptive layouts for different screen sizes
- **Material Design**: Consistent UI following Material Design principles

## Integration

### 1. Dependencies

Ensure the following dependencies are added to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  get_it: ^7.6.0
  http: ^1.1.0
  shared_preferences: ^2.2.2
  dartz: ^0.10.1
```

### 2. Dependency Injection Setup

Add the dashboard module to your main dependency injection setup:

```dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'features/dashboard/dashboard.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core dependencies
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  getIt.registerSingletonAsync<SharedPreferences>(
    () => SharedPreferences.getInstance(),
  );

  // Configure dashboard module
  DashboardModule.configure(getIt);
  
  // Ensure all async dependencies are ready
  await getIt.allReady();
}
```

### 3. Usage in Flutter App

#### Basic Implementation

```dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'features/dashboard/dashboard.dart';

class DashboardPage extends StatefulWidget {
  final UserRole userRole;
  final String userId;

  const DashboardPage({
    Key? key,
    required this.userRole,
    required this.userId,
  }) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GetIt.instance<DashboardController>();
    _controller.initializeUserContext(widget.userRole, widget.userId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: DashboardWidget(controller: _controller),
    );
  }
}
```

#### Advanced Implementation with Route Management

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          final userRole = state.extra as UserRole? ?? UserRole.student;
          final userId = state.queryParams['userId'] ?? '';
          
          return DashboardPage(
            userRole: userRole,
            userId: userId,
          );
        },
      ),
    ],
  );
}
```

## API Integration

### Backend Endpoints

The dashboard module expects the following API endpoints:

#### Student Dashboard Data
```
GET /api/dashboard/student/{userId}
```

Response format:
```json
{
  \"totalSessions\": 45,
  \"completedSessions\": 38,
  \"upcomingSessions\": 7,
  \"progressPercentage\": 84.4,
  \"recentActivities\": [
    {
      \"id\": \"activity_123\",
      \"title\": \"Mathematics Session\",
      \"description\": \"Algebra fundamentals with John Smith\",
      \"timestamp\": \"2023-12-01T10:00:00Z\",
      \"type\": \"session_completed\",
      \"metadata\": {
        \"tutorName\": \"John Smith\",
        \"subject\": \"Mathematics\",
        \"duration\": 60
      }
    }
  ],
  \"subjectStatistics\": [
    {
      \"subject\": \"Mathematics\",
      \"sessions\": 15,
      \"percentage\": 33.3,
      \"color\": \"blue\"
    }
  ]
}
```

#### Tutor Dashboard Data
```
GET /api/dashboard/tutor/{userId}
```

Response format:
```json
{
  \"totalStudents\": 25,
  \"earningsThisMonth\": 1250.0,
  \"sessionsConducted\": 78,
  \"ratingScore\": 4.8,
  \"overallScore\": 89.5,
  \"completionRate\": 96.2,
  \"responseRate\": 98.7,
  \"verificationStatus\": \"verified\",
  \"recentActivities\": [...],
  \"subjectStatistics\": [...]
}
```

### Error Responses

```json
{
  \"error\": {
    \"code\": \"DASHBOARD_001\",
    \"message\": \"User not found\",
    \"localizedMessage\": \"We couldn't find your account. Please check your login status.\"
  }
}
```

## Configuration

### Environment Variables

Set the following environment variables for API configuration:

```dart
// config/app_config.dart
class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL', 
    defaultValue: 'http://localhost:3000',
  );
  
  static const String dashboardEndpoint = '$baseUrl/api/dashboard';
  static const Duration cacheExpiry = Duration(minutes: 15);
}
```

### Cache Configuration

The local data source uses SharedPreferences with the following cache keys:
- `dashboard_cache_student_{userId}`: Student dashboard data
- `dashboard_cache_tutor_{userId}`: Tutor dashboard data
- `dashboard_cache_timestamp_{userId}`: Cache timestamp for expiry

## Testing

### Unit Tests

```dart
// test/features/dashboard/domain/usecases/get_dashboard_data_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

void main() {
  group('GetDashboardDataUseCase', () {
    late GetDashboardDataUseCase useCase;
    late MockDashboardRepository mockRepository;

    setUp(() {
      mockRepository = MockDashboardRepository();
      useCase = GetDashboardDataUseCase(repository: mockRepository);
    });

    test('should return dashboard data when repository call is successful', () async {
      // Arrange
      final dashboard = Dashboard(/* test data */);
      when(mockRepository.getDashboardData(any, any))
          .thenAnswer((_) async => Right(dashboard));

      // Act
      final result = await useCase(GetDashboardDataParams(
        userRole: UserRole.student,
        userId: 'test_user_id',
      ));

      // Assert
      expect(result, Right(dashboard));
      verify(mockRepository.getDashboardData(UserRole.student, 'test_user_id'));
    });
  });
}
```

### Widget Tests

```dart
// test/features/dashboard/presentation/widgets/dashboard_widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('DashboardWidget', () {
    testWidgets('should display loading widget initially', (tester) async {
      // Arrange
      final controller = MockDashboardController();
      when(controller.state).thenReturn(DashboardState.loading());

      // Act
      await tester.pumpWidget(MaterialApp(
        home: DashboardWidget(controller: controller),
      ));

      // Assert
      expect(find.byType(DashboardLoadingWidget), findsOneWidget);
    });
  });
}
```

## Performance Considerations

### Caching Strategy
- **Cache Duration**: 15 minutes for dashboard data
- **Cache Invalidation**: Automatic refresh when cache expires
- **Offline Support**: Displays cached data when network is unavailable

### Optimization Tips
- **Lazy Loading**: Use pagination for large activity lists
- **Image Optimization**: Compress and cache user profile images
- **Network Efficiency**: Batch API calls when possible
- **Memory Management**: Dispose controllers properly to prevent memory leaks

## Troubleshooting

### Common Issues

1. **\"DashboardController not found\" Error**
   - Ensure `DashboardModule.configure()` is called before using the controller
   - Check that GetIt dependencies are properly registered

2. **\"Failed to load dashboard data\" Error**
   - Verify API endpoint URLs in configuration
   - Check network connectivity
   - Validate user authentication tokens

3. **Cache Not Working**
   - Ensure SharedPreferences is properly initialized
   - Check cache key format and expiry logic
   - Verify storage permissions on device

### Debug Mode

Enable debug logging for detailed troubleshooting:

```dart
// In development environment
class DashboardRemoteDataSource {
  static const bool debugMode = true;
  
  Future<DashboardDto> getDashboardData(UserRole role, String userId) async {
    if (debugMode) {
      print('Fetching dashboard data for $role user: $userId');
    }
    // ... implementation
  }
}
```

## Contributing

When contributing to the dashboard module:

1. Follow Clean Architecture principles
2. Add unit tests for new use cases
3. Update widget tests for UI changes
4. Document any new API contracts
5. Follow the existing code style and naming conventions

## Future Enhancements

- **Real-time Updates**: WebSocket integration for live data updates
- **Advanced Analytics**: More detailed performance metrics and insights
- **Customizable Dashboards**: Allow users to customize widget layouts
- **Export Functionality**: PDF/CSV export for dashboard data
- **Push Notifications**: Real-time notifications for important events

---

For more information, refer to the individual component documentation in their respective directories.