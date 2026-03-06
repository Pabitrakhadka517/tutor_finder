// Review Module - Public API
// This file exports all public interfaces and entities for the Review module
// following Clean Architecture principles

// Domain Layer Exports
export 'domain/entities/review_entity.dart';
export 'domain/entities/tutor_rating_entity.dart';
export 'domain/entities/platform_stats_entity.dart';
export 'domain/value_objects/rating.dart';
export 'domain/failures/review_failures.dart';
export 'domain/failures/tutor_rating_failures.dart';
export 'domain/repositories/review_repository.dart';
export 'domain/repositories/tutor_rating_repository.dart';

// Use Cases - Business Logic
export 'domain/usecases/create_review_usecase.dart';
export 'domain/usecases/update_review_usecase.dart';
export 'domain/usecases/delete_review_usecase.dart';
export 'domain/usecases/get_tutor_reviews_usecase.dart';
export 'domain/usecases/search_reviews_usecase.dart';

// Data Layer - DTOs for external consumption
export 'data/dtos/review_dto.dart';
export 'data/dtos/tutor_rating_dto.dart';
export 'data/models/review_search_params.dart';

// Services - External integrations
export 'data/services/review_notification_service.dart';

// Dependency Injection
export 'injection_container.dart';
