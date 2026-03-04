import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/location_permission_status.dart';
import '../notifiers/location_notifier.dart';
import '../providers/location_providers.dart';
import '../state/location_state.dart';

/// A button widget for detecting current GPS location
/// Handles all states: loading, success, error, permission denied
class LocationDetectorButton extends ConsumerWidget {
  /// Callback when location is successfully detected
  final void Function(String address, double latitude, double longitude)?
  onLocationDetected;

  /// Whether to automatically save to server
  final bool saveToServer;

  /// Custom button text
  final String? buttonText;

  /// Whether to show the detected address below the button
  final bool showDetectedAddress;

  const LocationDetectorButton({
    super.key,
    this.onLocationDetected,
    this.saveToServer = true,
    this.buttonText,
    this.showDetectedAddress = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationNotifierProvider);
    final notifier = ref.read(locationNotifierProvider.notifier);

    // Listen for successful location detection
    ref.listen<LocationState>(locationNotifierProvider, (previous, next) {
      if (next.status == LocationStatus.success && next.hasLocation) {
        onLocationDetected?.call(
          next.location!.address,
          next.location!.latitude,
          next.location!.longitude,
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main button
        _buildButton(context, state, notifier),

        // Spacing
        if (showDetectedAddress || state.hasError) const SizedBox(height: 8),

        // Show detected address
        if (showDetectedAddress && state.hasLocation && !state.hasError)
          _buildAddressDisplay(context, state),

        // Show error message with action
        if (state.hasError) _buildErrorDisplay(context, state, notifier),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context,
    LocationState state,
    LocationNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final isLoading = state.isLoading;

    return ElevatedButton.icon(
      onPressed: isLoading
          ? null
          : () => notifier.detectLocation(saveToServer: saveToServer),
      icon: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimary,
                ),
              ),
            )
          : Icon(state.hasLocation ? Icons.refresh : Icons.my_location),
      label: Text(
        isLoading
            ? state.statusMessage
            : (buttonText ??
                  (state.hasLocation
                      ? 'Refresh Location'
                      : 'Use Current Location')),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAddressDisplay(BuildContext context, LocationState state) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.location!.fullAddress,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (state.isSavedToServer)
                  Text(
                    'Saved to profile',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          if (state.isSavedToServer)
            Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
              size: 18,
            ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay(
    BuildContext context,
    LocationState state,
    LocationNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final shouldOpenSettings = state.shouldOpenSettings;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.errorMessage ?? 'An error occurred',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          if (shouldOpenSettings) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (state.permissionStatus ==
                    LocationPermissionStatus.serviceDisabled)
                  TextButton.icon(
                    onPressed: () => notifier.openLocationSettings(),
                    icon: const Icon(Icons.settings, size: 18),
                    label: const Text('Enable GPS'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => notifier.openAppSettings(),
                    icon: const Icon(Icons.settings, size: 18),
                    label: const Text('Open Settings'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
