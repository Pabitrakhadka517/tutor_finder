import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/routes/app_routes.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../profile/presentation/pages/edit_profile_page.dart';

/// Settings page with user preferences and account management
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _chatNotifications = true;
  bool _bookingReminders = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0.5,
      ),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          _buildListTile(
            icon: Icons.person_outline,
            title: user?.fullName ?? 'User',
            subtitle: user?.email ?? '',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const EditProfilePage())),
          ),
          _buildListTile(
            icon: Icons.badge_outlined,
            title: 'Role',
            subtitle: (user?.role.name ?? 'student').toUpperCase(),
          ),

          const Divider(height: 1),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            secondary: Icon(
              Icons.notifications_outlined,
              color: Colors.blue.shade600,
            ),
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive app notifications'),
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
            activeThumbColor: Colors.blue,
          ),
          SwitchListTile(
            secondary: Icon(Icons.email_outlined, color: Colors.green.shade600),
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive email updates'),
            value: _emailNotifications,
            onChanged: (val) => setState(() => _emailNotifications = val),
            activeThumbColor: Colors.blue,
          ),
          SwitchListTile(
            secondary: Icon(Icons.chat_outlined, color: Colors.purple.shade600),
            title: const Text('Chat Notifications'),
            subtitle: const Text('New message alerts'),
            value: _chatNotifications,
            onChanged: (val) => setState(() => _chatNotifications = val),
            activeThumbColor: Colors.blue,
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.alarm_outlined,
              color: Colors.orange.shade600,
            ),
            title: const Text('Booking Reminders'),
            subtitle: const Text('Session start reminders'),
            value: _bookingReminders,
            onChanged: (val) => setState(() => _bookingReminders = val),
            activeThumbColor: Colors.blue,
          ),

          const Divider(height: 1),

          // Support Section
          _buildSectionHeader('Support'),
          _buildListTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'FAQs and support articles',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showInfoDialog(
              'Help Center',
              'For support, please contact us at support@learnmentor.com',
            ),
          ),
          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showInfoDialog(
              'Privacy Policy',
              'Your data is secure with LearnMentor. We do not share your personal information with third parties.',
            ),
          ),
          _buildListTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showInfoDialog(
              'Terms of Service',
              'By using LearnMentor you agree to our terms and conditions.',
            ),
          ),

          const Divider(height: 1),

          // About Section
          _buildSectionHeader('About'),
          _buildListTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0',
          ),

          const Divider(height: 1),

          // Account Actions
          _buildSectionHeader('Account Actions'),
          _buildListTile(
            icon: Icons.logout,
            title: 'Sign Out',
            iconColor: Colors.red,
            titleColor: Colors.red,
            onTap: () => _confirmLogout(),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey.shade700),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor ?? Colors.grey.shade800,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: Colors.grey.shade500))
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authNotifierProvider.notifier).logout();
              if (!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.roleSelection,
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
