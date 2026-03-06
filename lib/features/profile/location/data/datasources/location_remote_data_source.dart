import '../../domain/entities/location_entity.dart';

/// Abstract data source for remote location API operations
abstract class LocationRemoteDataSource {
  /// Update user's location on the server
  /// Throws exception on failure
  Future<void> updateLocation(LocationEntity location);
}
