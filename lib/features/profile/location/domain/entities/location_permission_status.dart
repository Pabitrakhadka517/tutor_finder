/// Enum representing all possible location permission states
enum LocationPermissionStatus {
  /// Permission has not been requested yet
  notDetermined,

  /// Permission was denied (can be requested again)
  denied,

  /// Permission was permanently denied (must open settings)
  deniedForever,

  /// Permission was granted
  granted,

  /// Permission is restricted (by parental controls, etc.)
  restricted,

  /// Location services are disabled on the device
  serviceDisabled,
}

/// Extension methods for LocationPermissionStatus
extension LocationPermissionStatusX on LocationPermissionStatus {
  /// Returns true if location can be accessed
  bool get isGranted => this == LocationPermissionStatus.granted;

  /// Returns true if permission was denied (but can request again)
  bool get isDenied => this == LocationPermissionStatus.denied;

  /// Returns true if permission is permanently denied
  bool get isPermanentlyDenied =>
      this == LocationPermissionStatus.deniedForever;

  /// Returns true if location service is disabled
  bool get isServiceDisabled =>
      this == LocationPermissionStatus.serviceDisabled;

  /// Returns true if permission can be requested
  bool get canRequest =>
      this == LocationPermissionStatus.notDetermined ||
      this == LocationPermissionStatus.denied;

  /// Returns a user-friendly message for the status
  String get userMessage {
    switch (this) {
      case LocationPermissionStatus.notDetermined:
        return 'Location permission not requested yet';
      case LocationPermissionStatus.denied:
        return 'Location permission denied. Tap to try again.';
      case LocationPermissionStatus.deniedForever:
        return 'Location permission permanently denied. Please enable it in Settings.';
      case LocationPermissionStatus.granted:
        return 'Location access granted';
      case LocationPermissionStatus.restricted:
        return 'Location access is restricted on this device';
      case LocationPermissionStatus.serviceDisabled:
        return 'Location services are disabled. Please enable GPS.';
    }
  }
}
