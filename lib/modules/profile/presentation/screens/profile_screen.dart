import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/validators/profile_validators.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'profile_edit_screen.dart';

/// Basic scaffold for viewing profile information.
/// Shows user data with options to edit, change theme, etc.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => _refreshProfile(context),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => _navigateToEdit(context),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.error) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.status == ProfileStatus.themeUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Theme updated successfully')),
            );
          }
          if (state.status == ProfileStatus.imageDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile image deleted')),
            );
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => _refreshProfile(context),
            child: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    switch (state.status) {
      case ProfileStatus.initial:
      case ProfileStatus.loading when state.profile == null:
        return const Center(child: CircularProgressIndicator());

      case ProfileStatus.loaded:
      case ProfileStatus.loading:
      case ProfileStatus.updating:
      case ProfileStatus.error when state.profile != null:
      case ProfileStatus.themeUpdated:
      case ProfileStatus.imageDeleted:
        return _buildProfileView(context, state.profile!, state.status);

      case ProfileStatus.error:
        return _buildErrorView(context, state.errorMessage!);

      default:
        return const Center(child: Text('Unknown state'));
    }
  }

  Widget _buildProfileView(
    BuildContext context,
    ProfileEntity profile,
    ProfileStatus status,
  ) {
    final isLoading =
        status == ProfileStatus.loading || status == ProfileStatus.updating;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // ── Profile Image ─────────────────────────────────────────────────
          _buildProfileImage(context, profile, isLoading),
          const SizedBox(height: 20),

          // ── Basic Info ────────────────────────────────────────────────────
          _buildInfoCard(
            title: 'Basic Information',
            children: [
              _buildInfoRow('Name', profile.name),
              _buildInfoRow('Email', profile.email),
              _buildInfoRow('Role', profile.role.name.toUpperCase()),
              if (profile.phone != null) _buildInfoRow('Phone', profile.phone!),
              if (profile.speciality != null)
                _buildInfoRow('Speciality', profile.speciality!),
              if (profile.address != null)
                _buildInfoRow('Address', profile.address!),
            ],
          ),
          const SizedBox(height: 16),

          // ── Theme Preference ──────────────────────────────────────────────
          _buildThemeCard(context, profile, isLoading),
          const SizedBox(height: 16),

          // ── Tutor Info (if applicable) ────────────────────────────────────
          if (profile.isTutor) ...[
            _buildTutorInfoCard(profile),
            const SizedBox(height: 16),
          ],

          // ── Actions ───────────────────────────────────────────────────────
          _buildActionsCard(context, isLoading),
        ],
      ),
    );
  }

  Widget _buildProfileImage(
    BuildContext context,
    ProfileEntity profile,
    bool isLoading,
  ) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundImage: profile.hasProfileImage
              ? NetworkImage(profile.profileImage!)
              : null,
          child: !profile.hasProfileImage
              ? Text(
                  profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                  style: Theme.of(context).textTheme.headlineLarge,
                )
              : null,
        ),
        if (profile.hasProfileImage)
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              onPressed: isLoading ? null : () => _deleteProfileImage(context),
              icon: const Icon(Icons.delete, color: Colors.red),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(4),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    ProfileEntity profile,
    bool isLoading,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theme Preference',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Current: ${profile.theme.name}'),
                const Spacer(),
                DropdownButton<String>(
                  value: profile.theme.name,
                  onChanged: isLoading
                      ? null
                      : (newTheme) {
                          if (newTheme != null &&
                              newTheme != profile.theme.name) {
                            context.read<ProfileBloc>().add(
                              UpdateThemeRequested(theme: newTheme),
                            );
                          }
                        },
                  items: ['light', 'dark', 'system'].map((theme) {
                    return DropdownMenuItem(value: theme, child: Text(theme));
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorInfoCard(ProfileEntity profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tutor Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (profile.bio != null) _buildInfoRow('Bio', profile.bio!),
            if (profile.hourlyRate != null)
              _buildInfoRow(
                'Hourly Rate',
                '\$${profile.hourlyRate!.toStringAsFixed(2)}',
              ),
            if (profile.experienceYears != null)
              _buildInfoRow('Experience', '${profile.experienceYears!} years'),
            if (profile.subjects.isNotEmpty)
              _buildInfoRow('Subjects', profile.subjects.join(', ')),
            if (profile.languages.isNotEmpty)
              _buildInfoRow('Languages', profile.languages.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, bool isLoading) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: isLoading ? null : () => _navigateToEdit(context),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: isLoading
                  ? null
                  : () => _showChangePasswordDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _refreshProfile(context),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  Future<void> _refreshProfile(BuildContext context) async {
    context.read<ProfileBloc>().add(const RefreshProfileRequested());
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
    );
  }

  void _deleteProfileImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile Image'),
        content: const Text(
          'Are you sure you want to delete your profile image?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProfileBloc>().add(const DeleteImageRequested());
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }
}

/// Dialog for changing password
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isObscuredOld = true;
  bool _isObscuredNew = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.passwordChanged) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );
        }
      },
      child: AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _oldPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _isObscuredOld = !_isObscuredOld),
                    icon: Icon(
                      _isObscuredOld ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                obscureText: _isObscuredOld,
                validator: ProfileValidators.validateOldPassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _isObscuredNew = !_isObscuredNew),
                    icon: Icon(
                      _isObscuredNew ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                obscureText: _isObscuredNew,
                validator: ProfileValidators.validateNewPassword,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              final isLoading = state.status == ProfileStatus.updating;
              return TextButton(
                onPressed: isLoading ? null : _changePassword,
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Change'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        ChangePasswordRequested(
          oldPassword: _oldPasswordController.text,
          newPassword: _newPasswordController.text,
        ),
      );
    }
  }
}
