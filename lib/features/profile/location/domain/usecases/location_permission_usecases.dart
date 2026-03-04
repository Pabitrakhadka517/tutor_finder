import '../entities/location_permission_status.dart';
import '../repositories/location_repository.dart';

/// Use case to check current location permission status
class CheckLocationPermissionUseCase {
  final ILocationRepository repository;

  CheckLocationPermissionUseCase(this.repository);

  Future<LocationPermissionStatus> call() {
    return repository.checkPermission();
  }
}

/// Use case to request location permission from user
class RequestLocationPermissionUseCase {
  final ILocationRepository repository;

  RequestLocationPermissionUseCase(this.repository);

  Future<LocationPermissionStatus> call() {
    return repository.requestPermission();
  }
}

/// Use case to check if location service is enabled
class CheckLocationServiceUseCase {
  final ILocationRepository repository;

  CheckLocationServiceUseCase(this.repository);

  Future<bool> call() {
    return repository.isLocationServiceEnabled();
  }
}

/// Use case to open location settings
class OpenLocationSettingsUseCase {
  final ILocationRepository repository;

  OpenLocationSettingsUseCase(this.repository);

  Future<bool> call() {
    return repository.openLocationSettings();
  }
}

/// Use case to open app settings
class OpenAppSettingsUseCase {
  final ILocationRepository repository;

  OpenAppSettingsUseCase(this.repository);

  Future<bool> call() {
    return repository.openAppSettings();
  }
}
