import '../../domain/entities/location_entity.dart';
import '../../domain/entities/location_permission_status.dart';

/// Abstract data source for device location services
/// Handles GPS coordinates and permission management
abstract class LocationDeviceDataSource {
  /// Check current permission status
  Future<LocationPermissionStatus> checkPermission();

  /// Request location permission
  Future<LocationPermissionStatus> requestPermission();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled();

  /// Open device location settings
  Future<bool> openLocationSettings();

  /// Open app permission settings
  Future<bool> openAppSettings();

  /// Get current GPS coordinates
  /// Throws exception on failure
  Future<({double latitude, double longitude})> getCurrentCoordinates({
    Duration timeout = const Duration(seconds: 10),
  });

  /// Convert coordinates to human-readable address
  /// Throws exception on failure
  Future<LocationEntity> reverseGeocode({
    required double latitude,
    required double longitude,
  });
}
