import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/api/api_endpoints.dart';
import '../providers/admin_providers.dart';

class AdminUserDetailPage extends ConsumerStatefulWidget {
  final String userId;

  const AdminUserDetailPage({super.key, required this.userId});

  @override
  ConsumerState<AdminUserDetailPage> createState() =>
      _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends ConsumerState<AdminUserDetailPage> {
  @override
  void initState() {
    super.initState();
    ref.read(adminNotifierProvider.notifier).fetchUserById(widget.userId);
  }

  Future<void> _verifyTutor(String status) async {
    final success = await ref
        .read(adminNotifierProvider.notifier)
        .verifyTutor(tutorId: widget.userId, status: status);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tutor status updated to $status'),
          backgroundColor: Colors.green,
        ),
      );
      ref.read(adminNotifierProvider.notifier).fetchUserById(widget.userId);
    }
  }

  Future<void> _deleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text(
          'Are you sure you want to delete this user? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref
          .read(adminNotifierProvider.notifier)
          .deleteUser(widget.userId);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminNotifierProvider);
    final user = adminState.selectedUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteUser,
          ),
        ],
      ),
      body: adminState.isLoading && user == null
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? Center(
                  child: Text(
                    adminState.error ?? 'User not found',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Profile section
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: user.profileImage != null
                            ? NetworkImage(
                                ApiEndpoints.getImageUrl(user.profileImage!) ??
                                    '')
                            : null,
                        child: user.profileImage == null
                            ? Text(
                                user.fullName.isNotEmpty
                                    ? user.fullName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(fontSize: 32),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _roleColor(user.role).withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _roleColor(user.role),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Details card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _detailRow(Icons.email, 'Email', user.email),
                              if (user.phone != null)
                                _detailRow(Icons.phone, 'Phone', user.phone!),
                              _detailRow(
                                Icons.account_balance_wallet,
                                'Balance',
                                'Rs. ${user.balance.toStringAsFixed(0)}',
                              ),
                              _detailRow(
                                Icons.calendar_today,
                                'Joined',
                                DateFormat('MMM dd, yyyy')
                                    .format(user.createdAt),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tutor verification actions
                      if (user.isTutor) ...[
                        const Text(
                          'Tutor Verification',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _verifyTutor('VERIFIED'),
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Verify'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _verifyTutor('PENDING'),
                                icon: const Icon(Icons.hourglass_empty),
                                label: const Text('Pending'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _verifyTutor('REJECTED'),
                                icon: const Icon(Icons.cancel),
                                label: const Text('Reject'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'tutor':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
