import '../../../../core/error/failures.dart';
import 'entities/location_permission_status.dart';

/// Base class for location-related failures
abstract class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

/// Failure when location permission is denied
class LocationPermissionDeniedFailure extends LocationFailure {
  final LocationPermissionStatus permissionStatus;

  const LocationPermissionDeniedFailure(
    super.message, {
    required this.permissionStatus,
  });

  @override
  List<Object?> get props => [message, permissionStatus];
}

/// Failure when location services are disabled
class LocationServiceDisabledFailure extends LocationFailure {
  const LocationServiceDisabledFailure([
    super.message = 'Location services are disabled. Please enable GPS.',
  ]);
}

/// Failure when getting GPS coordinates times out
class LocationTimeoutFailure extends LocationFailure {
  const LocationTimeoutFailure([
    super.message = 'GPS location request timed out. Please try again.',
  ]);
}

/// Failure when reverse geocoding fails
class GeocodingFailure extends LocationFailure {
  const GeocodingFailure([
    super.message = 'Failed to convert coordinates to address.',
  ]);
}

/// Failure when updating location on server fails
class LocationUpdateFailure extends LocationFailure {
  final int? statusCode;

  const LocationUpdateFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure for general location errors
class LocationGeneralFailure extends LocationFailure {
  const LocationGeneralFailure([
    super.message = 'An error occurred while getting location.',
  ]);
}

/// Failure when there's no network for geocoding
class LocationNetworkFailure extends LocationFailure {
  const LocationNetworkFailure([
    super.message = 'No internet connection for address lookup.',
  ]);
}
