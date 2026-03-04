import 'package:equatable/equatable.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/location_permission_status.dart';

/// Represents the current state of location detection
enum LocationStatus {
  /// Initial state, no action taken yet
  initial,

  /// Checking permission status
  checkingPermission,

  /// Waiting for user to grant permission
  requestingPermission,

  /// Fetching GPS coordinates
  fetchingLocation,

  /// Converting coordinates to address
  reverseGeocoding,

  /// Sending location to server
  updatingServer,

  /// Location successfully detected
  success,

  /// An error occurred
  error,
}

/// State class for location feature
class LocationState extends Equatable {
  /// Current status of the location operation
  final LocationStatus status;

  /// Current permission status
  final LocationPermissionStatus permissionStatus;

  /// Detected location (null if not yet detected)
  final LocationEntity? location;

  /// Error message (null if no error)
  final String? errorMessage;

  /// Whether the location has been saved to server
  final bool isSavedToServer;

  const LocationState({
    this.status = LocationStatus.initial,
    this.permissionStatus = LocationPermissionStatus.notDetermined,
    this.location,
    this.errorMessage,
    this.isSavedToServer = false,
  });

  /// Initial state factory
  factory LocationState.initial() => const LocationState();

  /// Check if currently loading (any ongoing operation)
  bool get isLoading =>
      status == LocationStatus.checkingPermission ||
      status == LocationStatus.requestingPermission ||
      status == LocationStatus.fetchingLocation ||
      status == LocationStatus.reverseGeocoding ||
      status == LocationStatus.updatingServer;

  /// Check if permission needs to be requested
  bool get needsPermission =>
      permissionStatus == LocationPermissionStatus.notDetermined ||
      permissionStatus == LocationPermissionStatus.denied;

  /// Check if user should open settings
  bool get shouldOpenSettings =>
      permissionStatus == LocationPermissionStatus.deniedForever ||
      permissionStatus == LocationPermissionStatus.serviceDisabled;

  /// Check if there's an error
  bool get hasError => status == LocationStatus.error && errorMessage != null;

  /// Check if location was successfully detected
  bool get hasLocation => location != null && location!.isValid;

  /// Get a user-friendly status message
  String get statusMessage {
    switch (status) {
      case LocationStatus.initial:
        return 'Tap to detect your location';
      case LocationStatus.checkingPermission:
        return 'Checking permissions...';
      case LocationStatus.requestingPermission:
        return 'Please grant location permission';
      case LocationStatus.fetchingLocation:
        return 'Getting GPS coordinates...';
      case LocationStatus.reverseGeocoding:
        return 'Finding address...';
      case LocationStatus.updatingServer:
        return 'Saving location...';
      case LocationStatus.success:
        return 'Location detected successfully';
      case LocationStatus.error:
        return errorMessage ?? 'An error occurred';
    }
  }

  /// Create a copy with updated values
  LocationState copyWith({
    LocationStatus? status,
    LocationPermissionStatus? permissionStatus,
    LocationEntity? location,
    String? errorMessage,
    bool? isSavedToServer,
    bool clearError = false,
    bool clearLocation = false,
  }) {
    return LocationState(
      status: status ?? this.status,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      location: clearLocation ? null : (location ?? this.location),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSavedToServer: isSavedToServer ?? this.isSavedToServer,
    );
  }

  @override
  List<Object?> get props => [
    status,
    permissionStatus,
    location,
    errorMessage,
    isSavedToServer,
  ];
}
