# Location Feature Documentation

This document describes the GPS location detection feature for the profile update functionality.

## Overview

The location feature allows users to automatically detect their current GPS location and update their profile with an accurate address. The feature follows **Clean Architecture** principles with Riverpod state management.

## Architecture

```
features/profile/location/
├── domain/
│   ├── entities/
│   │   ├── location_entity.dart         # Core location data model
│   │   └── location_permission_status.dart  # Permission states enum
│   ├── repositories/
│   │   └── location_repository.dart     # Repository interface
│   ├── usecases/
│   │   ├── get_current_location_usecase.dart
│   │   ├── update_location_usecase.dart
│   │   └── location_permission_usecases.dart
│   └── location_failures.dart           # Location-specific failures
├── data/
│   ├── models/
│   │   └── location_model.dart          # JSON serialization model
│   ├── datasources/
│   │   ├── location_device_data_source.dart       # GPS interface
│   │   ├── location_device_data_source_impl.dart  # GPS implementation
│   │   ├── location_remote_data_source.dart       # API interface
│   │   └── location_remote_data_source_impl.dart  # API implementation
│   └── repositories/
│       └── location_repository_impl.dart  # Repository implementation
├── presentation/
│   ├── state/
│   │   └── location_state.dart          # State model
│   ├── notifiers/
│   │   └── location_notifier.dart       # StateNotifier
│   ├── providers/
│   │   └── location_providers.dart      # Riverpod providers
│   └── widgets/
│       ├── location_detector_button.dart  # Standalone button widget
│       └── location_form_field.dart       # Form field widget
└── location.dart                          # Barrel file for exports
```

## Dependencies

Add these packages to `pubspec.yaml`:

```yaml
dependencies:
  geolocator: ^13.0.2
  geocoding: ^3.0.0
  permission_handler: ^11.3.1
```

## Platform Configuration

### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to help tutors and students find each other nearby.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to your location to help tutors and students find each other nearby.</string>
```

## Usage

### Import

```dart
import 'package:tutor_finder/features/profile/location/location.dart';
```

### Using LocationDetectorButton

Simple standalone button that handles everything:

```dart
LocationDetectorButton(
  onLocationDetected: (address, latitude, longitude) {
    // Handle the detected location
    print('Detected: $address ($latitude, $longitude)');
  },
  saveToServer: true,  // Auto-save to backend
  showDetectedAddress: true,
)
```

### Using LocationFormField in Forms

Replace manual address input with GPS-enabled field:

```dart
LocationFormField(
  controller: _addressController,
  labelText: 'Your Location',
  hintText: 'Detect or enter location',
  allowManualEdit: true,  // Allow user to also type manually
  autoSaveToServer: false, // Don't auto-save, save with form
  onLocationChanged: (address, lat, lng) {
    // Store coordinates for form submission
    setState(() {
      _latitude = lat;
      _longitude = lng;
    });
  },
  validator: (value) => value?.isEmpty == true ? 'Location required' : null,
)
```

### Direct Provider Usage

For custom implementations:

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationNotifierProvider);
    final locationNotifier = ref.read(locationNotifierProvider.notifier);

    return Column(
      children: [
        if (locationState.isLoading)
          CircularProgressIndicator(),
        
        if (locationState.hasError)
          Text('Error: ${locationState.errorMessage}'),
        
        if (locationState.hasLocation)
          Text('Location: ${locationState.location!.fullAddress}'),
        
        ElevatedButton(
          onPressed: () => locationNotifier.detectLocation(),
          child: Text('Detect Location'),
        ),
      ],
    );
  }
}
```

## Permission Handling

The feature automatically handles:

1. **Permission not requested** → Requests permission
2. **Permission denied** → Shows retry option
3. **Permission permanently denied** → Shows "Open Settings" button
4. **Location services disabled** → Shows "Enable GPS" button

## API Payload

When location is detected and sent to server:

```json
{
  "address": "Ahmedabad, Gujarat, India",
  "location": {
    "latitude": 23.0225,
    "longitude": 72.5714,
    "address": "Ahmedabad, Gujarat, India",
    "city": "Ahmedabad",
    "state": "Gujarat",
    "country": "India",
    "postalCode": "380001"
  }
}
```

## State Properties

| Property | Type | Description |
|----------|------|-------------|
| `status` | `LocationStatus` | Current operation status |
| `permissionStatus` | `LocationPermissionStatus` | Permission state |
| `location` | `LocationEntity?` | Detected location data |
| `errorMessage` | `String?` | Error message if any |
| `isSavedToServer` | `bool` | Whether saved to backend |
| `isLoading` | `bool` | Computed: any operation ongoing |
| `hasError` | `bool` | Computed: error state |
| `hasLocation` | `bool` | Computed: valid location exists |

## Edge Cases Handled

- ✅ Permission denied (can retry)
- ✅ Permission permanently denied (opens settings)
- ✅ Location services disabled (opens GPS settings)
- ✅ GPS timeout (shows retry option)
- ✅ No internet during reverse geocoding
- ✅ Geocoding failure (shows coordinates as fallback)
- ✅ Server update failure (shows error, keeps location)
- ✅ Widget disposed during async operation (mounted check)

## Testing

The architecture supports easy testing:

```dart
// Mock the device data source
class MockLocationDeviceDataSource implements LocationDeviceDataSource {
  @override
  Future<LocationPermissionStatus> checkPermission() async {
    return LocationPermissionStatus.granted;
  }
  // ... implement other methods
}

// Override provider in tests
final container = ProviderContainer(
  overrides: [
    locationDeviceDataSourceProvider.overrideWithValue(
      MockLocationDeviceDataSource(),
    ),
  ],
);
```
