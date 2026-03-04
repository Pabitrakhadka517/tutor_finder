import '../../../../../core/error/failures.dart';
import '../../../../../core/utils/either.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/location_permission_status.dart';
import '../../domain/location_failures.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_device_data_source.dart';
import '../datasources/location_remote_data_source.dart';

/// Implementation of ILocationRepository
/// Coordinates between device data source (GPS) and remote data source (API)
class LocationRepositoryImpl implements ILocationRepository {
  final LocationDeviceDataSource deviceDataSource;
  final LocationRemoteDataSource remoteDataSource;

  LocationRepositoryImpl({
    required this.deviceDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<LocationPermissionStatus> checkPermission() {
    return deviceDataSource.checkPermission();
  }

  @override
  Future<LocationPermissionStatus> requestPermission() {
    return deviceDataSource.requestPermission();
  }

  @override
  Future<bool> isLocationServiceEnabled() {
    return deviceDataSource.isLocationServiceEnabled();
  }

  @override
  Future<bool> openLocationSettings() {
    return deviceDataSource.openLocationSettings();
  }

  @override
  Future<bool> openAppSettings() {
    return deviceDataSource.openAppSettings();
  }

  @override
  Future<Either<Failure, LocationEntity>> getCurrentLocation() async {
    try {
      // 1. Check permission first
      final permissionStatus = await deviceDataSource.checkPermission();

      if (permissionStatus == LocationPermissionStatus.serviceDisabled) {
        return Either.left(const LocationServiceDisabledFailure());
      }

      if (!permissionStatus.isGranted) {
        return Either.left(
          LocationPermissionDeniedFailure(
            permissionStatus.userMessage,
            permissionStatus: permissionStatus,
          ),
        );
      }

      // 2. Get GPS coordinates
      final coords = await deviceDataSource.getCurrentCoordinates(
        timeout: const Duration(seconds: 15),
      );

      // 3. Reverse geocode to get address
      final location = await deviceDataSource.reverseGeocode(
        latitude: coords.latitude,
        longitude: coords.longitude,
      );

      return Either.right(location);
    } on LocationFailure catch (e) {
      return Either.left(e);
    } catch (e) {
      return Either.left(LocationGeneralFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateLocationOnServer(
    LocationEntity location,
  ) async {
    try {
      await remoteDataSource.updateLocation(location);
      return Either.right(null);
    } on LocationUpdateFailure catch (e) {
      return Either.left(e);
    } catch (e) {
      return Either.left(LocationUpdateFailure('Failed to save location: $e'));
    }
  }
}
