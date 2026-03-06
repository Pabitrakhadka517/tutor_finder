import '../../../../../core/error/failures.dart';
import '../../../../../core/utils/either.dart';
import '../entities/location_entity.dart';
import '../entities/location_permission_status.dart';

/// Repository interface for location operations
/// Following SOLID principles - Interface Segregation
abstract class ILocationRepository {
  /// Check current location permission status
  Future<LocationPermissionStatus> checkPermission();

  /// Request location permission from the user
  Future<LocationPermissionStatus> requestPermission();

  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled();

  /// Open device location settings
  Future<bool> openLocationSettings();

  /// Open app permission settings
  Future<bool> openAppSettings();

  /// Get current GPS coordinates and reverse geocode to address
  /// Returns Either failure or LocationEntity
  Future<Either<Failure, LocationEntity>> getCurrentLocation();

  /// Update location on the server
  /// [location] - The location data to send to the server
  Future<Either<Failure, void>> updateLocationOnServer(LocationEntity location);
}
