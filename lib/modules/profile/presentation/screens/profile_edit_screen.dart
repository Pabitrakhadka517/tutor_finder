import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/update_profile_usecase.dart' as usecase;
import '../../domain/validators/profile_validators.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// Screen for editing user profile information.
/// Supports text fields, image picker, and tutor-specific fields.
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialityController = TextEditingController();
  final _addressController = TextEditingController();

  // Tutor fields
  final _bioController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _experienceController = TextEditingController();
  final _subjectsController = TextEditingController();
  final _languagesController = TextEditingController();

  File? _selectedImage;
  ProfileEntity? _currentProfile;

  @override
  void initState() {
    super.initState();
    // Pre-populate fields with current profile data
    final state = context.read<ProfileBloc>().state;
    if (state.profile != null) {
      _setProfileData(state.profile!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specialityController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    _hourlyRateController.dispose();
    _experienceController.dispose();
    _subjectsController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  void _setProfileData(ProfileEntity profile) {
    _currentProfile = profile;
    _nameController.text = profile.name;
    _phoneController.text = profile.phone ?? '';
    _specialityController.text = profile.speciality ?? '';
    _addressController.text = profile.address ?? '';

    if (profile.isTutor) {
      _bioController.text = profile.bio ?? '';
      _hourlyRateController.text = profile.hourlyRate?.toString() ?? '';
      _experienceController.text = profile.experienceYears?.toString() ?? '';
      _subjectsController.text = profile.subjects.join(', ');
      _languagesController.text = profile.languages.join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              final isUpdating = state.status == ProfileStatus.updating;
              return TextButton(
                onPressed: isUpdating ? null : _saveProfile,
                child: isUpdating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              );
            },
          ),
        ],
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.loaded &&
              _currentProfile != state.profile) {
            // Profile was updated successfully
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          }
          if (state.status == ProfileStatus.error) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // ── Profile Image ─────────────────────────────────────────────
                _buildImagePicker(),
                const SizedBox(height: 24),

                // ── Basic Information ─────────────────────────────────────────
                _buildSectionHeader('Basic Information'),
                _buildBasicFields(),
                const SizedBox(height: 24),

                // ── Tutor Fields (if applicable) ──────────────────────────────
                if (_currentProfile?.isTutor == true) ...[
                  _buildSectionHeader('Tutor Information'),
                  _buildTutorFields(),
                  const SizedBox(height: 24),
                ],

                // ── Save Button ───────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      final isUpdating = state.status == ProfileStatus.updating;
                      return ElevatedButton(
                        onPressed: isUpdating ? null : _saveProfile,
                        child: isUpdating
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Updating...'),
                                ],
                              )
                            : const Text('Save Changes'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: _getImageProvider(),
              child: _getImageProvider() == null
                  ? Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text[0].toUpperCase()
                          : '?',
                      style: Theme.of(context).textTheme.headlineLarge,
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
        if (_selectedImage != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _selectedImage = null),
            child: const Text('Remove selected image'),
          ),
        ],
      ],
    );
  }

  ImageProvider? _getImageProvider() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (_currentProfile?.hasProfileImage == true) {
      return NetworkImage(_currentProfile!.profileImage!);
    }
    return null;
  }

  Widget _buildBasicFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name *',
            hintText: 'Enter your full name',
          ),
          validator: ProfileValidators.validateName,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone',
            hintText: 'Enter your phone number',
          ),
          keyboardType: TextInputType.phone,
          validator: ProfileValidators.validatePhone,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _specialityController,
          decoration: const InputDecoration(
            labelText: 'Speciality',
            hintText: 'Your area of expertise',
          ),
          validator: ProfileValidators.validateSpeciality,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Address',
            hintText: 'Your address',
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildTutorFields() {
    return Column(
      children: [
        TextFormField(
          controller: _bioController,
          decoration: const InputDecoration(
            labelText: 'Bio',
            hintText: 'Tell us about yourself',
          ),
          maxLines: 3,
          validator: ProfileValidators.validateBio,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _hourlyRateController,
          decoration: const InputDecoration(
            labelText: 'Hourly Rate (\$)',
            hintText: 'Your hourly rate',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final rate = double.tryParse(value);
              return ProfileValidators.validateHourlyRate(rate);
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _experienceController,
          decoration: const InputDecoration(
            labelText: 'Experience (years)',
            hintText: 'Years of teaching experience',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final years = int.tryParse(value);
              return ProfileValidators.validateExperienceYears(years);
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _subjectsController,
          decoration: const InputDecoration(
            labelText: 'Subjects',
            hintText: 'Math, Physics, Chemistry (comma separated)',
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final subjects = value.split(',').map((s) => s.trim()).toList();
              return ProfileValidators.validateSubjects(subjects);
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _languagesController,
          decoration: const InputDecoration(
            labelText: 'Languages',
            hintText: 'English, Spanish, French (comma separated)',
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final languages = value.split(',').map((s) => s.trim()).toList();
              return ProfileValidators.validateLanguages(languages);
            }
            return null;
          },
        ),
      ],
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      final file = File(image.path);
      final error = ProfileValidators.validateImageFile(file);

      if (error != null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
        return;
      }

      setState(() => _selectedImage = file);
    }
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Parse tutor fields
    usecase.TutorFields? tutorFields;
    if (_currentProfile?.isTutor == true) {
      double? hourlyRate;
      int? experienceYears;
      if (_hourlyRateController.text.isNotEmpty) {
        hourlyRate = double.tryParse(_hourlyRateController.text);
      }
      if (_experienceController.text.isNotEmpty) {
        experienceYears = int.tryParse(_experienceController.text);
      }

      final subjects = _subjectsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final languages = _languagesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      tutorFields = usecase.TutorFields(
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        hourlyRate: hourlyRate,
        experienceYears: experienceYears,
        subjects: subjects.isEmpty ? null : subjects,
        languages: languages.isEmpty ? null : languages,
      );
    }

    context.read<ProfileBloc>().add(
      UpdateProfileRequested(
        name: _nameController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        speciality: _specialityController.text.isEmpty
            ? null
            : _specialityController.text,
        address: _addressController.text.isEmpty
            ? null
            : _addressController.text,
        profileImagePath: _selectedImage?.path,
        tutorFields: tutorFields,
      ),
    );
  }
}
