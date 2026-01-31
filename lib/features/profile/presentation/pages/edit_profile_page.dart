import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_image_picker.dart';
import '../widgets/profile_form_field.dart';

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
        ProfileFormField(
          controller: _addressController,
          label: 'Address',
          icon: Icons.location_on_outlined,
          maxLines: 3,
          validator: _validateAddress,
          textInputAction: TextInputAction.done,
        ),
      ],
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
