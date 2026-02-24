# Review Module - Tutor Rating & Review System

## Overview

The Review Module implements a comprehensive tutor rating and review system following Clean Architecture principles. This module allows students to leave reviews and ratings for tutors after completing sessions, automatically calculates aggregate ratings, and provides powerful search and discovery features.

## Architecture

This module follows **Clean Architecture** with **Domain-Driven Design (DDD)** principles:

```
lib/features/review/
├── domain/                     # Business Logic Layer
│   ├── entities/              # Core business entities
│   ├── value_objects/         # Domain primitives
│   ├── repositories/          # Repository interfaces
│   ├── usecases/             # Business use cases
│   └── failures/             # Domain error types
├── data/                      # Data Layer
│   ├── datasources/          # Remote & local data sources
│   ├── repositories/         # Repository implementations
│   ├── dtos/                 # Data transfer objects
│   ├── models/               # Data models
│   └── services/             # External service integrations
└── injection_container.dart   # Dependency injection setup
```

## Key Features

### Core Functionality
- ✅ **Review Creation**: Students can create reviews with 1-5 star ratings and optional comments
- ✅ **Review Management**: Update and delete reviews with ownership validation
- ✅ **Tutor Rating Calculation**: Automatic aggregate rating calculation with distribution tracking
- ✅ **Review Discovery**: Advanced search and filtering capabilities
- ✅ **Booking Validation**: One review per booking constraint enforcement
- ✅ **Notification System**: NEW_REVIEW trigger with push notification support

### Business Rules
- ✅ **Rating Validation**: Ratings must be integers between 1 and 5
- ✅ **Comment Length**: Comments limited to 1000 characters
- ✅ **Ownership Validation**: Only review authors can modify their reviews
- ✅ **Booking Constraint**: Each booking can only have one review
- ✅ **Atomic Operations**: Rating calculations are atomic and consistent

### Technical Features
- ✅ **Caching Strategy**: 30-minute cache for optimal performance
- ✅ **Offline Support**: Local storage with network connectivity checks
- ✅ **Error Handling**: Comprehensive error types with proper recovery
- ✅ **Pagination**: Efficient pagination for large datasets
- ✅ **Real-time Updates**: Notifications for rating milestones

## Domain Entities

### ReviewEntity
Core business entity representing a student's review of a tutor.

```dart
class ReviewEntity {
  final String id;
  final String bookingId;
  final String tutorId;
  final String studentId;
  final Rating rating;          // Value object (1-5)
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### TutorRatingEntity
Aggregate entity managing tutor's overall rating statistics.

```dart
class TutorRatingEntity {
  final String tutorId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final DateTime lastUpdated;
}
```

### PlatformStatsEntity
Platform-wide rating statistics for analytics and discovery.

```dart
class PlatformStatsEntity {
  final double averageRating;
  final int totalReviews;
  final int totalTutors;
  final Map<int, int> ratingDistribution;
  final DateTime lastUpdated;
}
```

## Value Objects

### Rating
Encapsulates rating validation and business rules.

```dart
class Rating {
  final int value;  // 1-5 inclusive
  
  // Ensures ratings are always valid
  // Provides value equality semantics
  // Immutable by design
}
```

## Use Cases

### CreateReviewUseCase
**Purpose**: Create new review with full business logic orchestration

**Flow**:
1. Validate no existing review for booking
2. Create review entity with domain validation
3. Persist review to repository
4. Trigger tutor rating recalculation
5. Send NEW_REVIEW notifications

```dart
final result = await createReviewUseCase(CreateReviewParams(
  bookingId: 'booking-123',
  tutorId: 'tutor-456',
  studentId: 'student-789',
  rating: 5,
  comment: 'Excellent tutor!',
));
```

### UpdateReviewUseCase
**Purpose**: Update existing review with ownership validation

**Flow**:
1. Validate review existence and ownership
2. Update review entity
3. Recalculate tutor rating if rating changed
4. Send update notifications

### SearchReviewsUseCase
**Purpose**: Advanced search with filtering and pagination

**Filters**:
- Tutor/Student ID filtering
- Rating range filtering (min/max)
- Text search in comments
- Date range filtering
- Subject filtering
- Sorting by rating/date

```dart
final reviews = await searchReviewsUseCase(SearchReviewsParams(
  tutorId: 'tutor-123',
  minRating: 4,
  query: 'excellent',
  sortBy: 'createdAt',
  sortOrder: 'desc',
  page: 1,
  limit: 20,
));
```

## API Endpoints

### Review Endpoints
```
POST   /reviews                    # Create review
GET    /reviews/{id}               # Get specific review
PUT    /reviews/{id}               # Update review
DELETE /reviews/{id}               # Delete review
GET    /reviews/booking/{bookingId} # Get review by booking
GET    /reviews/tutor/{tutorId}    # Get tutor's reviews
GET    /reviews/student/{studentId} # Get student's reviews
GET    /reviews/search             # Search reviews
GET    /reviews/recent             # Get recent reviews
GET    /reviews/booking/{bookingId}/exists # Check review exists
```

### Tutor Rating Endpoints
```
GET    /tutor-ratings/{tutorId}           # Get tutor rating
PUT    /tutor-ratings/{tutorId}           # Update tutor rating
POST   /tutor-ratings/{tutorId}/recalculate # Recalculate rating
GET    /tutor-ratings/top-rated           # Get top-rated tutors
GET    /tutor-ratings/most-reviewed       # Get most-reviewed tutors
GET    /tutor-ratings/platform/stats      # Get platform statistics
```

## Notification System

### NEW_REVIEW Trigger
When a new review is created:

```dart
// In-app notification
await notificationService.sendNotification(
  userId: review.tutorId,
  type: 'NEW_REVIEW',
  title: 'New Review Received',
  body: 'You have received a new 5-star review',
  data: {
    'reviewId': review.id,
    'rating': review.rating.value.toString(),
    'navigation': '/reviews/${review.id}',
  },
);

// Push notification
await notificationService.sendPushNotification(
  userId: review.tutorId,
  title: 'New Review',
  body: 'You received a 5-star review',
);
```

### Rating Milestones
Special notifications for rating achievements (4.0, 4.5, 5.0 stars).

## Caching Strategy

### Local Storage
- **Review Cache**: 30 minutes TTL
- **Rating Cache**: 30 minutes TTL
- **Search Cache**: 30 minutes TTL
- **Platform Stats**: 30 minutes TTL

### Cache Keys
```dart
// Individual reviews
'review_cache_{reviewId}'

// Review collections
'reviews_cache_tutor_{tutorId}_{page}_{limit}'
'reviews_cache_student_{studentId}_{page}_{limit}'
'reviews_cache_search_{searchHash}'

// Tutor ratings
'tutor_rating_cache_{tutorId}'
'tutor_ratings_cache_top_rated_{limit}'

// Platform stats
'platform_stats_cache'
```

## Error Handling

### Domain Failures
```dart
sealed class ReviewFailure {
  const factory ReviewFailure.validationError(String message);
  const factory ReviewFailure.notFoundError(String message);
  const factory ReviewFailure.conflictError(String message);
  const factory ReviewFailure.forbiddenError(String message);
  const factory ReviewFailure.networkError(String message);
  const factory ReviewFailure.cacheError(String message);
  const factory ReviewFailure.serverError(String message);
  const factory ReviewFailure.unauthorizedError(String message);
  const factory ReviewFailure.unknownError(String message);
}
```

### Network Error Mapping
```dart
// 400 -> ValidationError
// 401 -> UnauthorizedError
// 403 -> ForbiddenError
// 404 -> NotFoundError
// 409 -> ConflictError
// 422 -> ValidationError
// 429 -> RateLimitError
// 500 -> ServerError
```

## Testing Strategy

### Unit Tests
- ✅ Value object validation (Rating)
- ✅ Entity creation and business rules
- ✅ Use case orchestration logic
- ✅ Repository error handling
- ✅ DTO serialization/deserialization

### Integration Tests
- ✅ Repository with real data sources
- ✅ Notification service integration
- ✅ Cache management
- ✅ Network error scenarios

### Widget Tests
- ✅ Review creation form validation
- ✅ Rating display components
- ✅ Search and filter UI

## Usage Examples

### Creating a Review
```dart
// Inject use case
final createReviewUseCase = GetIt.instance<CreateReviewUseCase>();

// Create review
final result = await createReviewUseCase(CreateReviewParams(
  bookingId: sessionBooking.id,
  tutorId: selectedTutor.id,
  studentId: currentUser.id,
  rating: 5,
  comment: 'Great session! Highly recommended.',
));

result.fold(
  (failure) => showErrorMessage(failure.message),
  (review) => showSuccessMessage('Review created successfully'),
);
```

### Searching Reviews
```dart
// Advanced search
final searchUseCase = GetIt.instance<SearchReviewsUseCase>();

final result = await searchUseCase(SearchReviewsParams(
  tutorId: tutor.id,
  minRating: 4,
  query: 'excellent teacher',
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime.now(),
  sortBy: 'createdAt',
  sortOrder: 'desc',
));
```

### Getting Tutor Ratings
```dart
final getTutorRatingUseCase = GetIt.instance<GetTutorRatingUseCase>();

final result = await getTutorRatingUseCase(GetTutorRatingParams(
  tutorId: tutor.id,
));

result.fold(
  (failure) => handleError(failure),
  (rating) => displayTutorRating(rating),
);
```

## Security Considerations

### Authorization
- Students can only create/update/delete their own reviews
- Tutors can view reviews but not modify them
- Admins have full CRUD access
- Booking ownership validation required

### Data Validation
- Server-side validation for all inputs
- Rating constraints (1-5) enforced
- Comment length limits enforced
- SQL injection prevention
- XSS protection for comments

## Performance Optimizations

### Database Indexing
```sql
-- Reviews table indexes
CREATE INDEX idx_reviews_tutor_id ON reviews(tutor_id);
CREATE INDEX idx_reviews_student_id ON reviews(student_id);
CREATE INDEX idx_reviews_booking_id ON reviews(booking_id);
CREATE INDEX idx_reviews_created_at ON reviews(created_at);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- Tutor ratings table indexes
CREATE INDEX idx_tutor_ratings_average ON tutor_ratings(average_rating DESC);
CREATE INDEX idx_tutor_ratings_total_reviews ON tutor_ratings(total_reviews DESC);
```

### Query Optimization
- Pagination for large result sets
- Efficient rating calculation queries
- Search index for text queries
- Cached aggregate calculations

### Frontend Optimizations
- Lazy loading for review lists
- Image optimization for tutor avatars
- Virtual scrolling for large lists
- Optimistic UI updates

## Monitoring and Analytics

### Metrics to Track
- Review creation rate
- Average rating trends
- Response/comment rates
- Search query patterns
- Notification engagement rates

### Health Checks
- Database connection status
- Cache hit ratios
- API response times
- Error rates by endpoint
- Notification delivery rates

## Future Enhancements

### Planned Features
- [ ] Review reply system (tutor responses)
- [ ] Image/photo attachments to reviews
- [ ] Review helpfulness voting
- [ ] Anonymous review option
- [ ] Review moderation system
- [ ] Machine learning for fake review detection
- [ ] Sentiment analysis for reviews
- [ ] Review templates/quick ratings
- [ ] Bulk review import/export
- [ ] Review analytics dashboard

### Technical Improvements
- [ ] GraphQL API support
- [ ] Real-time review updates via WebSocket
- [ ] Advanced caching with Redis
- [ ] Elasticsearch integration for search
- [ ] Review data archiving
- [ ] A/B testing framework integration

## Dependencies

### Core Dependencies
```yaml
dependencies:
  dartz: ^0.10.1              # Functional programming
  injectable: ^2.3.2          # Dependency injection
  dio: ^5.3.2                 # HTTP client
  shared_preferences: ^2.2.2  # Local storage
  json_annotation: ^4.8.1     # JSON serialization
```

### Dev Dependencies
```yaml
dev_dependencies:
  injectable_generator: ^2.4.1  # Code generation
  json_serializable: ^6.7.1    # JSON code generation
  mockito: ^5.4.2               # Mocking for tests
  flutter_test:                 # Testing framework
```

## Contributing

### Code Style
- Follow Clean Architecture principles
- Use meaningful variable and method names
- Add comprehensive documentation
- Include unit tests for all business logic
- Follow Dart/Flutter style guidelines

### Pull Request Process
1. Create feature branch from develop
2. Implement feature with tests
3. Update documentation
4. Submit PR with detailed description
5. Address code review feedback
6. Merge after approval

## Support

For questions or issues regarding the Review Module:
- Check the inline code documentation
- Review the test cases for usage examples
- Consult the Clean Architecture guidelines
- Contact the development team

---

**Module Version**: 1.0.0  
**Last Updated**: 2024  
**Maintained By**: Flutter Development Team