import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/location_entity.dart';
import '../../domain/entities/location_permission_status.dart';
import '../../domain/location_failures.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/usecases/get_current_location_usecase.dart';
import '../../domain/usecases/location_permission_usecases.dart';
import '../../domain/usecases/update_location_usecase.dart';
import '../../../../../core/usecases/usecase.dart';
import '../state/location_state.dart';

/// StateNotifier for managing location detection state
/// Handles the full flow: permission → GPS → geocoding → server update
class LocationNotifier extends StateNotifier<LocationState> {
  final CheckLocationPermissionUseCase checkPermissionUseCase;
  final RequestLocationPermissionUseCase requestPermissionUseCase;
  final CheckLocationServiceUseCase checkServiceUseCase;
  final OpenLocationSettingsUseCase openLocationSettingsUseCase;
  final OpenAppSettingsUseCase openAppSettingsUseCase;
  final GetCurrentLocationUseCase getCurrentLocationUseCase;
  final UpdateLocationUseCase updateLocationUseCase;
  final ILocationRepository repository;

  LocationNotifier({
    required this.checkPermissionUseCase,
    required this.requestPermissionUseCase,
    required this.checkServiceUseCase,
    required this.openLocationSettingsUseCase,
    required this.openAppSettingsUseCase,
    required this.getCurrentLocationUseCase,
    required this.updateLocationUseCase,
    required this.repository,
  }) : super(LocationState.initial());

  /// Check the current permission status without requesting
  Future<void> checkPermission() async {
    if (!mounted) return;

    state = state.copyWith(
      status: LocationStatus.checkingPermission,
      clearError: true,
    );

    final permissionStatus = await checkPermissionUseCase();

    if (!mounted) return;

    state = state.copyWith(
      permissionStatus: permissionStatus,
      status: LocationStatus.initial,
    );
  }

  /// Main method to detect location
  /// Handles the full flow: permission check → request → get location → save
  Future<void> detectLocation({bool saveToServer = true}) async {
    if (!mounted) return;

    // Reset state and start loading
    state = state.copyWith(
      status: LocationStatus.checkingPermission,
      clearError: true,
      isSavedToServer: false,
    );

    try {
      // 1. Check permission
      var permissionStatus = await checkPermissionUseCase();

      if (!mounted) return;
      state = state.copyWith(permissionStatus: permissionStatus);

      // 2. Handle service disabled
      if (permissionStatus == LocationPermissionStatus.serviceDisabled) {
        state = state.copyWith(
          status: LocationStatus.error,
          errorMessage: permissionStatus.userMessage,
        );
        return;
      }

      // 3. Request permission if needed
      if (permissionStatus.canRequest) {
        state = state.copyWith(status: LocationStatus.requestingPermission);

        permissionStatus = await requestPermissionUseCase();

        if (!mounted) return;
        state = state.copyWith(permissionStatus: permissionStatus);
      }

      // 4. Handle permission denied
      if (!permissionStatus.isGranted) {
        state = state.copyWith(
          status: LocationStatus.error,
          errorMessage: permissionStatus.userMessage,
        );
        return;
      }

      // 5. Get current location (GPS + reverse geocoding)
      state = state.copyWith(status: LocationStatus.fetchingLocation);

      final locationResult = await getCurrentLocationUseCase(const NoParams());

      if (!mounted) return;

      await locationResult.fold(
        (failure) async {
          String errorMsg = failure.message;

          // Update permission status if it's a permission failure
          if (failure is LocationPermissionDeniedFailure) {
            state = state.copyWith(permissionStatus: failure.permissionStatus);
          }

          state = state.copyWith(
            status: LocationStatus.error,
            errorMessage: errorMsg,
          );
        },
        (location) async {
          if (!mounted) return;

          state = state.copyWith(
            location: location,
            status: LocationStatus.success,
          );

          // 6. Save to server if requested
          if (saveToServer) {
            await _saveLocationToServer(location);
          }
        },
      );
    } catch (e) {
      if (!mounted) return;

      state = state.copyWith(
        status: LocationStatus.error,
        errorMessage: 'Unexpected error: $e',
      );
    }
  }

  /// Save the current location to server
  Future<void> saveCurrentLocation() async {
    final location = state.location;
    if (location == null) return;

    await _saveLocationToServer(location);
  }

  /// Internal method to save location to server
  Future<void> _saveLocationToServer(LocationEntity location) async {
    if (!mounted) return;

    state = state.copyWith(status: LocationStatus.updatingServer);

    final result = await updateLocationUseCase(
      UpdateLocationParams(location: location),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        state = state.copyWith(
          status: LocationStatus.error,
          errorMessage:
              'Location detected but failed to save: ${failure.message}',
          isSavedToServer: false,
        );
      },
      (_) {
        state = state.copyWith(
          status: LocationStatus.success,
          isSavedToServer: true,
        );
      },
    );
  }

  /// Open device location settings
  Future<void> openLocationSettings() async {
    await openLocationSettingsUseCase();
  }

  /// Open app permission settings
  Future<void> openAppSettings() async {
    await openAppSettingsUseCase();
  }

  /// Reset to initial state
  void reset() {
    if (!mounted) return;
    state = LocationState.initial();
  }

  /// Clear error and set back to initial
  void clearError() {
    if (!mounted) return;
    state = state.copyWith(status: LocationStatus.initial, clearError: true);
  }

  /// Set a manual location (for testing or fallback)
  void setManualLocation(LocationEntity location) {
    if (!mounted) return;
    state = state.copyWith(
      location: location,
      status: LocationStatus.success,
      isSavedToServer: false,
    );
  }
}
