import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/location_permission_status.dart';
import '../notifiers/location_notifier.dart';
import '../providers/location_providers.dart';
import '../state/location_state.dart';

/// A form field widget for location input with GPS detection
/// Can be used in profile forms to replace manual address input
class LocationFormField extends ConsumerStatefulWidget {
  /// Text controller for the address field
  final TextEditingController? controller;

  /// Callback when location is detected
  final void Function(String address, double latitude, double longitude)?
  onLocationChanged;

  /// Initial address value
  final String? initialAddress;

  /// Whether to allow manual editing
  final bool allowManualEdit;

  /// Label text for the field
  final String labelText;

  /// Hint text for the field
  final String hintText;

  /// Whether to save to server automatically
  final bool autoSaveToServer;

  /// Validation function
  final String? Function(String?)? validator;

  const LocationFormField({
    super.key,
    this.controller,
    this.onLocationChanged,
    this.initialAddress,
    this.allowManualEdit = true,
    this.labelText = 'Location',
    this.hintText = 'Enter your location or use GPS',
    this.autoSaveToServer = false,
    this.validator,
  });

  @override
  ConsumerState<LocationFormField> createState() => _LocationFormFieldState();
}

class _LocationFormFieldState extends ConsumerState<LocationFormField> {
  late TextEditingController _controller;
  bool _isControllerOwned = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.initialAddress);
      _isControllerOwned = true;
    }
  }

  @override
  void dispose() {
    if (_isControllerOwned) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationNotifierProvider);
    final notifier = ref.read(locationNotifierProvider.notifier);
    final theme = Theme.of(context);

    // Listen for location changes
    ref.listen<LocationState>(locationNotifierProvider, (previous, next) {
      if (next.status == LocationStatus.success && next.hasLocation) {
        final address = next.location!.fullAddress;
        _controller.text = address;
        widget.onLocationChanged?.call(
          address,
          next.location!.latitude,
          next.location!.longitude,
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location text field
        TextFormField(
          controller: _controller,
          enabled: widget.allowManualEdit,
          readOnly: state
              .isLoading, // Use readOnly instead of enabled to avoid IME loop
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon: _buildSuffixIcon(state, notifier, theme),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: state.isLoading
                ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)
                : theme.colorScheme.surface,
          ),
          validator: widget.validator,
          maxLines: 2,
          minLines: 1,
        ),

        // Status or error message
        if (state.isLoading || state.hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildStatusRow(state, notifier, theme),
          ),

        // Success indicator
        if (state.status == LocationStatus.success && state.isSavedToServer)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Location saved',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSuffixIcon(
    LocationState state,
    LocationNotifier notifier,
    ThemeData theme,
  ) {
    if (state.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
      );
    }

    return IconButton(
      onPressed: () =>
          notifier.detectLocation(saveToServer: widget.autoSaveToServer),
      icon: Icon(Icons.my_location, color: theme.colorScheme.primary),
      tooltip: 'Detect current location',
    );
  }

  Widget _buildStatusRow(
    LocationState state,
    LocationNotifier notifier,
    ThemeData theme,
  ) {
    if (state.isLoading) {
      return Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            state.statusMessage,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      );
    }

    if (state.hasError) {
      return Row(
        children: [
          Icon(Icons.error_outline, size: 14, color: theme.colorScheme.error),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              state.errorMessage ?? 'Error',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          if (state.shouldOpenSettings)
            TextButton(
              onPressed: () {
                if (state.permissionStatus ==
                    LocationPermissionStatus.serviceDisabled) {
                  notifier.openLocationSettings();
                } else {
                  notifier.openAppSettings();
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 30),
              ),
              child: Text(
                'Settings',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
