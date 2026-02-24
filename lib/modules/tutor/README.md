# Tutor Discovery Module - Clean Architecture Implementation

## Overview

This is a complete Flutter Clean Architecture implementation for the Tutor Discovery Module. The module enables users to search, filter, and discover tutors with comprehensive functionality including pagination, availability management, and verification systems.

## Architecture Overview

### Clean Architecture Layers

The implementation follows Uncle Bob's Clean Architecture principles with three distinct layers:

1. **Domain Layer** (`/domain/`) - Business logic and entities
2. **Data Layer** (`/data/`) - Data sources and repository implementations  
3. **Presentation Layer** (`/presentation/`) - UI and state management

```
lib/modules/tutor/
├── domain/
│   ├── entities/
│   ├── failures/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── datasources/
│   ├── dtos/
│   ├── models/
│   └── repositories/
├── presentation/
│   ├── bloc/
│   ├── screens/
│   └── widgets/
├── utils/
└── tutor_module.dart
```

## Key Features

✅ **BLoC State Management** - Reactive UI with comprehensive event/state handling  
✅ **Dio HTTP Client** - API calls with error handling and interceptors  
✅ **Hive Local Storage** - Offline caching with expiration logic  
✅ **Dartz Either Pattern** - Functional error handling throughout  
✅ **json_serializable** - Code-generated DTO serialization  
✅ **get_it Dependency Injection** - Service locator pattern  
✅ **Comprehensive Search & Filtering** - Advanced search with multiple parameters  
✅ **Pagination Support** - Infinite scroll with merge pagination  
✅ **Tutor Availability Management** - Calendar-based scheduling  
✅ **Verification System** - Tutor status verification workflow  
✅ **Offline-First Strategy** - Cache-first with network fallback

## Module Setup

### 1. Initialize the Module

```dart
// In your main.dart or app initialization
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'modules/tutor/tutor_module.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize tutor module
  await TutorModule.init(GetIt.instance);
  
  runApp(MyApp());
}
```

### 2. Provide BLoC to Widget Tree

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'modules/tutor/tutor_module.dart';
import 'modules/tutor/presentation/screens/tutor_search_screen.dart';

// Using BlocProvider
BlocProvider(
  create: (context) => TutorBlocProvider.create(),
  child: TutorSearchScreen(),
)

// Or using MultiBlocProvider for multiple BLoCs
MultiBlocProvider(
  providers: [
    BlocProvider(create: (context) => TutorBlocProvider.create()),
    // ... other BLoCs
  ],
  child: YourAppWidget(),
)
```

## API Integration

### Base Configuration

Configure your API base URL and other settings via environment variables:

```dart
// Environment variables
const API_BASE_URL = 'https://api.tutorfinder.com/v1'
```

### Expected API Endpoints

The module expects the following REST API endpoints:

```
GET    /tutors/search              # Search tutors with filters
GET    /tutors/{id}                # Get tutor details  
GET    /tutors/{id}/availability   # Get tutor availability
POST   /tutors/me/availability     # Update availability (tutor only)
POST   /tutors/me/verify           # Verify tutor status
```

### API Query Parameters

Search endpoint supports comprehensive filtering:

```
GET /tutors/search?
  q=mathematics
  &subjects=Mathematics,Physics
  &min_price=20
  &max_price=100
  &min_rating=4.0
  &min_experience=2
  &location=New York
  &languages=English,Spanish
  &verified_only=true
  &available_only=true
  &page=1
  &limit=20
  &sort_by=rating
  &sort_order=desc
```

## Domain Layer Details

### Core Entities

**TutorEntity** - Main tutor data model
```dart
class TutorEntity {
  final String id;
  final String fullName;
  final String email;
  final List<String> subjects;
  final double rating;
  final int reviewCount;
  final String education;
  final String location;
  final int experienceYears;
  final double hourlyRate;
  final String currency;
  final bool isAvailable;
  final VerificationStatus verificationStatus;
  final String biography;
  final List<String> languages;
  final String? profileImage;
}
```

**TutorSearchParams** - Search and filtering parameters
```dart
class TutorSearchParams {
  final String searchQuery;
  final List<String> subjects;
  final List<String> languages;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final int? minExperienceYears;
  final String? location;
  final bool verifiedOnly;
  final bool onlineOnly;
  final bool inPersonOnly;
  final bool availableOnly;
  final String? sortBy;
  final String? sortOrder;
}
```

**AvailabilitySlotEntity** - Time slot scheduling
```dart
class AvailabilitySlotEntity {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final bool isBooked;
  final String? note;  
}
```

### Use Cases

Each use case implements a single business operation:

- `SearchTutors` - Search and filter tutors with pagination
- `GetTutorDetail` - Fetch comprehensive tutor information  
- `GetTutorAvailability` - Retrieve availability for specific dates
- `UpdateTutorAvailability` - Manage tutor schedules (tutor only)
- `VerifyTutorStatus` - Handle verification workflows

## Data Layer Details

### Repository Pattern

**TutorRepositoryImpl** implements cache-first strategy:

1. Check local Hive cache first
2. Return cached data if valid and not expired
3. Fetch from API if cache miss or expired  
4. Update local cache with fresh data
5. Handle network errors gracefully

```dart
@override
Future<Either<Failure, TutorListResultEntity>> searchTutors(
  TutorSearchParams params, {
  int page = 1,
  int limit = 20,
}) async {
  try {
    // Try cache first
    final cacheKey = TutorQueryBuilder.createSearchCacheKey(params, page);
    final cachedResult = await localDatasource.getSearchResults(cacheKey);
    
    if (cachedResult != null && !cachedResult.isExpired) {
      return Right(cachedResult);
    }
    
    // Fetch from API
    final apiResult = await remoteDatasource.searchTutors(params, page: page, limit: limit);
    
    // Cache the result
    await localDatasource.cacheSearchResults(cacheKey, apiResult);
    
    return Right(apiResult);
  } catch (error) {
    return Left(_mapErrorToFailure(error));
  }
}
```

### Caching Strategy

**Tutor Data Caching** (Hive):
- Individual tutor profiles cached for 1 hour
- Search results cached for 15 minutes  
- Availability data cached for 5 minutes
- Automatic cache invalidation and cleanup

**Cache Keys**:
```dart
// Search results
"search&q=math&subjects=Mathematics&page=1"

// Tutor details  
"detail&tutor=123&availability=true"

// Availability
"availability&tutor=123&date=2024-01-15"
```

## Presentation Layer Details

### BLoC State Management

**TutorBloc** handles all tutor-related state:

```dart
// Events
sealed class TutorEvent {
  LoadTutorsRequested();           // Initial load
  SearchQueryChanged(String);      // Text search with debouncing
  ApplyFiltersRequested(params);   // Apply search filters  
  LoadMoreTutorsRequested();       // Pagination
  LoadTutorDetailRequested(id);    // Detail view
  LoadTutorAvailabilityRequested(id, date);
  UpdateAvailabilityRequested(slots);
  VerifyTutorRequested(id);
}

// States  
sealed class TutorState {
  TutorInitial();                  // Starting state
  TutorLoading();                  // Loading indicator
  TutorLoaded(tutors, hasNext);    // Success with data
  TutorLoadingMore(current);       // Pagination loading
  TutorDetailLoaded(tutor);        // Detail view state
  TutorAvailabilityLoaded(slots);  // Availability data
  TutorError(message, type);       // Error handling
}
```

**Key BLoC Features**:
- Debounced search (500ms delay)
- Pagination with merge logic
- Comprehensive error mapping
- Loading states for better UX
- State preservation during operations

### UI Screens

**TutorSearchScreen** - Main discovery interface
- Search bar with real-time filtering
- Advanced filter bottom sheet
- Infinite scroll pagination  
- Pull-to-refresh functionality
- Empty states and error handling

**TutorDetailScreen** - Comprehensive tutor profile
- Collapsing toolbar with profile image
- Detailed information display
- Availability calendar integration
- Booking functionality (ready for implementation)

**AvailabilityManagementScreen** - Schedule management
- Calendar-based slot creation
- Drag-and-drop time editing
- Bulk operations support
- Conflict detection and resolution

## Testing Strategy

### Unit Tests Structure

```dart
test/modules/tutor/
├── domain/
│   ├── entities/
│   ├── usecases/
│   └── repositories/
├── data/
│   ├── datasources/
│   ├── dtos/
│   ├── models/ 
│   └── repositories/
└── presentation/
    ├── bloc/
    └── widgets/
```

### Test Examples

**Use Case Testing**:
```dart
group('SearchTutors', () {
  late SearchTutors useCase;
  late MockTutorRepository mockRepository;

  setUp(() {
    mockRepository = MockTutorRepository();
    useCase = SearchTutors(mockRepository);
  });

  test('should return tutor list when repository call is successful', () async {
    // Arrange
    final params = TutorSearchParams(searchQuery: 'math');
    final expectedResult = TutorListResultEntity(tutors: [], hasNextPage: false);
    when(() => mockRepository.searchTutors(params)).thenAnswer((_) async => Right(expectedResult));

    // Act  
    final result = await useCase(params);

    // Assert
    expect(result, Right(expectedResult));
    verify(() => mockRepository.searchTutors(params)).called(1);
  });
});
```

**BLoC Testing**:
```dart
group('TutorBloc', () {
  late TutorBloc bloc;
  late MockSearchTutors mockSearchTutors;

  setUp(() {
    mockSearchTutors = MockSearchTutors();
    bloc = TutorBloc(searchTutors: mockSearchTutors);
  });

  blocTest<TutorBloc, TutorState>(
    'should emit [TutorLoading, TutorLoaded] when search is successful',
    build: () {
      when(() => mockSearchTutors(any())).thenAnswer((_) async => Right(tutorList));
      return bloc;
    },
    act: (bloc) => bloc.add(LoadTutorsRequested()),
    expect: () => [isA<TutorLoading>(), isA<TutorLoaded>()],
  );
});
```

## Error Handling

### Failure Types

```dart
sealed class Failure {
  ServerFailure(String message, int? statusCode);
  NetworkFailure(String message);  
  CacheFailure(String message);
  ValidationFailure(String message, List<String> errors);
  UnknownFailure(String message);
}
```

### Error Mapping Strategy

- **Network errors** → User-friendly connectivity messages
- **API errors** → Specific error codes with fallback messages  
- **Validation errors** → Field-specific error highlighting
- **Cache errors** → Graceful fallback to network requests

## Performance Optimizations

### Caching Strategy
- **Memory caching** for frequently accessed data
- **Disk caching** with automatic expiration
- **Intelligent prefetching** for predictable user flows
- **Cache warming** on app startup

### Pagination Optimization
- **Lazy loading** with intersection observer pattern
- **Result merging** to prevent duplicate data
- **Memory-efficient** list management
- **Preemptive fetching** near scroll boundaries

### Image Loading
- **Cached network images** with placeholder management
- **Progressive loading** for better perceived performance
- **Memory-efficient** bitmap handling

## Security Considerations

### Data Protection
- **No sensitive data** stored in plain text
- **Encrypted local storage** for user tokens
- **API authentication** with token refresh logic
- **Input validation** and sanitization

### Network Security
- **Certificate pinning** for API calls
- **Request signing** for sensitive operations
- **Rate limiting** compliance
- **HTTPS enforcement**

## Monitoring and Analytics

### Performance Tracking
- **API response times** and error rates
- **Cache hit/miss ratios** for optimization
- **User engagement** metrics
- **Error frequency** and crash reporting

### Business Metrics  
- **Search conversion** rates
- **Filter usage** patterns
- **Booking funnel** analytics (when implemented)
- **User retention** tracking

## Future Enhancements

### Planned Features
- [ ] **Real-time availability** updates via WebSocket
- [ ] **Advanced scheduling** with recurring slots
- [ ] **Video calling** integration
- [ ] **Payment processing** for bookings  
- [ ] **Review and rating** system
- [ ] **Push notifications** for booking updates
- [ ] **Offline-first** booking queue
- [ ] **Multi-language** support with i18n

### Architectural Improvements
- [ ] **GraphQL** migration for flexible data fetching
- [ ] **State persistence** across app restarts  
- [ ] **Background sync** for offline operations
- [ ] **Advanced caching** with dependency tracking
- [ ] **Micro-frontend** architecture preparation
- [ ] **Performance monitoring** integration
- [ ] **A/B testing** framework

## Contributing

### Code Standards
- Follow **Clean Architecture** principles
- Use **BLoC pattern** for state management
- Implement **comprehensive error handling**
- Write **unit and widget tests** for all features
- Follow **Flutter/Dart** style guidelines
- Document **complex business logic**

### Pull Request Process
1. Create feature branch from `develop`
2. Implement feature with tests
3. Update documentation
4. Submit PR with detailed description
5. Address review feedback
6. Merge after approval

---

**Architecture**: Clean Architecture with BLoC  
**State Management**: flutter_bloc  
**HTTP Client**: dio  
**Local Storage**: hive  
**Dependency Injection**: get_it  
**Error Handling**: dartz Either pattern  
**Code Generation**: json_serializable + hive_generator