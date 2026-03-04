import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_image_picker.dart';
import '../widgets/profile_form_field.dart';
import '../../location/location.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _specialityController = TextEditingController();

  File? _selectedImage;
  bool _hasInitializedFields = false;

  // Location data for GPS-detected coordinates
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specialityController.dispose();
    super.dispose();
  }

  void _fetchProfile() {
    Future.microtask(
      () => ref.read(profileNotifierProvider.notifier).getProfile(),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _populateFields() {
    final profile = ref.read(profileNotifierProvider).profile;
    if (profile == null || _hasInitializedFields) return;

    _nameController.text = profile.name;
    _phoneController.text = profile.phone;
    _addressController.text = profile.address;
    _specialityController.text = profile.speciality;
    _hasInitializedFields = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(profileNotifierProvider.notifier)
        .updateProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          speciality: _specialityController.text.trim(),
          image: _selectedImage,
          latitude: _latitude,
          longitude: _longitude,
        );

    if (mounted && !ref.read(profileNotifierProvider).isLoading) {
      final error = ref.read(profileNotifierProvider).error;
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _listenToProfileChanges();

    final state = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), elevation: 0),
      body: state.isLoading && state.profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileImageSection(state),
                    const SizedBox(height: 32),
                    _buildFormFields(),
                    const SizedBox(height: 24),
                    _buildSaveButton(state),
                  ],
                ),
              ),
            ),
    );
  }

  void _listenToProfileChanges() {
    ref.listen(profileNotifierProvider, (previous, next) {
      // Show error messages
      if (next.error != null && next.error != previous?.error) {
        _showErrorSnackBar(next.error!);
      }

      // Populate fields when profile loads
      if (next.profile != null && !next.isLoading) {
        _populateFields();
      }
    });
  }

  Widget _buildProfileImageSection(state) {
    return Center(
      child: Column(
        children: [
          ProfileImagePicker(
            profileImageUrl: state.profile?.profileImage,
            selectedImage: _selectedImage,
            onTap: _pickImage,
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to change profile picture',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        ProfileFormField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person_outline,
          validator: _validateName,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        ProfileFormField(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: _validatePhone,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        ProfileFormField(
          controller: _specialityController,
          label: 'Speciality',
          icon: Icons.school_outlined,
          validator: _validateSpeciality,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _buildLocationSection(),
      ],
    );
  }

  Widget _buildLocationSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Address text field
        ProfileFormField(
          controller: _addressController,
          label: 'Address',
          icon: Icons.location_on_outlined,
          maxLines: 3,
          validator: _validateAddress,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 12),

        // GPS Location Button
        Consumer(
          builder: (context, ref, child) {
            final locationState = ref.watch(locationNotifierProvider);
            final locationNotifier = ref.read(
              locationNotifierProvider.notifier,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Use Current Location Button
                OutlinedButton.icon(
                  onPressed: locationState.isLoading
                      ? null
                      : () => _detectCurrentLocation(locationNotifier),
                  icon: locationState.isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : Icon(
                          Icons.my_location,
                          color: theme.colorScheme.primary,
                        ),
                  label: Text(
                    locationState.isLoading
                        ? locationState.statusMessage
                        : 'Use Current Location',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // Status messages
                if (locationState.hasError)
                  _buildLocationError(locationState, locationNotifier, theme),

                if (_latitude != null && _longitude != null)
                  _buildCoordinatesInfo(theme),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _detectCurrentLocation(LocationNotifier notifier) async {
    await notifier.detectLocation(saveToServer: false);

    final state = ref.read(locationNotifierProvider);
    if (state.hasLocation && mounted) {
      setState(() {
        _addressController.text = state.location!.fullAddress;
        _latitude = state.location!.latitude;
        _longitude = state.location!.longitude;
      });
    }
  }

  Widget _buildLocationError(
    LocationState state,
    LocationNotifier notifier,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.errorMessage ?? 'Location error',
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
                child: const Text('Settings'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinatesInfo(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            'GPS: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(state) {
    return ElevatedButton(
      onPressed: state.isLoading ? null : _submit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: state.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text(
              'Save Changes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Validators
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid phone number (10-15 digits)';
    }
    return null;
  }

  String? _validateSpeciality(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Speciality is required';
    }
    if (value.trim().length < 2) {
      return 'Speciality must be at least 2 characters';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 5) {
      return 'Address must be at least 5 characters';
    }
    return null;
  }
}
