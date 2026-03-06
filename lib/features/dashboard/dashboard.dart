// Dashboard feature barrel file
// This file exports all public interfaces and entities for the dashboard feature

// Domain layer exports
export 'domain/entities/dashboard_entity.dart';
export 'domain/entities/dashboard.dart';
export 'domain/entities/dashboard_statistics.dart';
export 'domain/entities/activity_item.dart';
export 'domain/failures/dashboard_failure.dart';
export 'domain/repositories/dashboard_repository.dart';
export 'domain/value_objects/user_role.dart';
export 'domain/usecases/usecases.dart';
export 'domain/usecases/get_student_dashboard_usecase.dart';
export 'domain/usecases/get_tutor_dashboard_usecase.dart';
export 'domain/usecases/refresh_dashboard_usecase.dart';
export 'domain/usecases/dashboard_analytics_usecase.dart';

// Data layer exports
export 'data/models/dashboard_dto.dart';
export 'data/models/dashboard_cache_dto.dart';
export 'data/models/dashboard_statistics_dto.dart';
export 'data/models/activity_item_dto.dart';
export 'data/datasources/dashboard_remote_datasource.dart';
export 'data/datasources/dashboard_local_datasource.dart';
export 'data/repositories/dashboard_repository_impl.dart';

// Presentation layer exports
export 'presentation/controllers/dashboard_controller.dart';
export 'presentation/models/dashboard_presentation_model.dart';
export 'presentation/widgets/dashboard_widget.dart';
export 'presentation/widgets/student_dashboard_view.dart';
export 'presentation/widgets/tutor_dashboard_view.dart';
export 'presentation/widgets/dashboard_statistics_grid.dart';
export 'presentation/widgets/recent_activity_widget.dart';
export 'presentation/widgets/progress_indicator_widget.dart';
export 'presentation/widgets/performance_indicator_widget.dart';
export 'presentation/widgets/subject_breakdown_widget.dart';
export 'presentation/widgets/dashboard_loading_widget.dart';
export 'presentation/widgets/dashboard_error_widget.dart';

// Module configuration
export 'dashboard_module.dart';
