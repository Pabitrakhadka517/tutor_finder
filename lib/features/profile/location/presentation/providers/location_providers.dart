import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/api/api_client.dart';
import '../../data/datasources/location_device_data_source.dart';
import '../../data/datasources/location_device_data_source_impl.dart';
import '../../data/datasources/location_remote_data_source.dart';
import '../../data/datasources/location_remote_data_source_impl.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/usecases/get_current_location_usecase.dart';
import '../../domain/usecases/location_permission_usecases.dart';
import '../../domain/usecases/update_location_usecase.dart';
import '../notifiers/location_notifier.dart';
import '../state/location_state.dart';

// ===================== Data Sources =====================

/// Provider for device location data source (GPS, permissions)
final locationDeviceDataSourceProvider = Provider<LocationDeviceDataSource>((
  ref,
) {
  return LocationDeviceDataSourceImpl();
});

/// Provider for remote location data source (API)
final locationRemoteDataSourceProvider = Provider<LocationRemoteDataSource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  return LocationRemoteDataSourceImpl(apiClient: apiClient);
});

// ===================== Repository =====================

/// Provider for location repository
final locationRepositoryProvider = Provider<ILocationRepository>((ref) {
  return LocationRepositoryImpl(
    deviceDataSource: ref.read(locationDeviceDataSourceProvider),
    remoteDataSource: ref.read(locationRemoteDataSourceProvider),
  );
});

// ===================== Use Cases =====================

/// Provider for check permission use case
final checkLocationPermissionUseCaseProvider =
    Provider<CheckLocationPermissionUseCase>((ref) {
      return CheckLocationPermissionUseCase(
        ref.read(locationRepositoryProvider),
      );
    });

/// Provider for request permission use case
final requestLocationPermissionUseCaseProvider =
    Provider<RequestLocationPermissionUseCase>((ref) {
      return RequestLocationPermissionUseCase(
        ref.read(locationRepositoryProvider),
      );
    });

/// Provider for check service use case
final checkLocationServiceUseCaseProvider =
    Provider<CheckLocationServiceUseCase>((ref) {
      return CheckLocationServiceUseCase(ref.read(locationRepositoryProvider));
    });

/// Provider for open location settings use case
final openLocationSettingsUseCaseProvider =
    Provider<OpenLocationSettingsUseCase>((ref) {
      return OpenLocationSettingsUseCase(ref.read(locationRepositoryProvider));
    });

/// Provider for open app settings use case
final openAppSettingsUseCaseProvider = Provider<OpenAppSettingsUseCase>((ref) {
  return OpenAppSettingsUseCase(ref.read(locationRepositoryProvider));
});

/// Provider for get current location use case
final getCurrentLocationUseCaseProvider = Provider<GetCurrentLocationUseCase>((
  ref,
) {
  return GetCurrentLocationUseCase(ref.read(locationRepositoryProvider));
});

/// Provider for update location use case
final updateLocationUseCaseProvider = Provider<UpdateLocationUseCase>((ref) {
  return UpdateLocationUseCase(ref.read(locationRepositoryProvider));
});

// ===================== Notifier =====================

/// StateNotifierProvider for location state management
final locationNotifierProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
      return LocationNotifier(
        checkPermissionUseCase: ref.read(
          checkLocationPermissionUseCaseProvider,
        ),
        requestPermissionUseCase: ref.read(
          requestLocationPermissionUseCaseProvider,
        ),
        checkServiceUseCase: ref.read(checkLocationServiceUseCaseProvider),
        openLocationSettingsUseCase: ref.read(
          openLocationSettingsUseCaseProvider,
        ),
        openAppSettingsUseCase: ref.read(openAppSettingsUseCaseProvider),
        getCurrentLocationUseCase: ref.read(getCurrentLocationUseCaseProvider),
        updateLocationUseCase: ref.read(updateLocationUseCaseProvider),
        repository: ref.read(locationRepositoryProvider),
      );
    });

// ===================== Convenience Providers =====================

/// Provider for current detected address (convenience)
final currentLocationAddressProvider = Provider<String?>((ref) {
  final state = ref.watch(locationNotifierProvider);
  return state.hasLocation ? state.location!.fullAddress : null;
});

/// Provider for checking if location is loading
final isLocationLoadingProvider = Provider<bool>((ref) {
  return ref.watch(locationNotifierProvider).isLoading;
});

/// Provider for location error message
final locationErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(locationNotifierProvider);
  return state.hasError ? state.errorMessage : null;
});
