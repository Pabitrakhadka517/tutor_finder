import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/admin_entities.dart';
import '../providers/admin_providers.dart';
import 'admin_user_detail_page.dart';
import 'announcements_page.dart';

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  String? _roleFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    ref.read(adminNotifierProvider.notifier).fetchUsers(role: _roleFilter);
    ref.read(adminNotifierProvider.notifier).fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign),
            tooltip: 'Announcements',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnnouncementsPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Platform Stats Cards
          if (adminState.stats != null) _buildStatsSection(adminState.stats!),

          // Role Filter Chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildFilterChip('All', null),
                _buildFilterChip('Students', 'student'),
                _buildFilterChip('Tutors', 'tutor'),
                _buildFilterChip('Admins', 'admin'),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: adminState.isLoading && adminState.users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : adminState.error != null && adminState.users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(adminState.error!,
                                style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : adminState.users.isEmpty
                        ? const Center(child: Text('No users found'))
                        : RefreshIndicator(
                            onRefresh: () async => _loadData(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: adminState.users.length,
                              itemBuilder: (context, index) {
                                return _UserCard(
                                  user: adminState.users[index],
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AdminUserDetailPage(
                                        userId: adminState.users[index].id,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),

          // Pagination
          if (adminState.totalPages > 1)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: adminState.currentPage > 1
                        ? () => ref
                            .read(adminNotifierProvider.notifier)
                            .fetchUsers(
                              page: adminState.currentPage - 1,
                              role: _roleFilter,
                            )
                        : null,
                  ),
                  Text(
                    'Page ${adminState.currentPage} of ${adminState.totalPages}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: adminState.currentPage < adminState.totalPages
                        ? () => ref
                            .read(adminNotifierProvider.notifier)
                            .loadNextPage()
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? role) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _roleFilter == role,
        onSelected: (_) {
          setState(() => _roleFilter = role);
          ref.read(adminNotifierProvider.notifier).fetchUsers(role: role);
        },
      ),
    );
  }

  Widget _buildStatsSection(PlatformStatsEntity stats) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _StatCard(
            icon: Icons.people,
            label: 'Users',
            value: '${stats.totalUsers}',
            color: Colors.blue,
          ),
          _StatCard(
            icon: Icons.school,
            label: 'Tutors',
            value: '${stats.totalTutors}',
            color: Colors.green,
          ),
          _StatCard(
            icon: Icons.calendar_today,
            label: 'Bookings',
            value: '${stats.totalBookings}',
            color: Colors.orange,
          ),
          _StatCard(
            icon: Icons.attach_money,
            label: 'Revenue',
            value: 'Rs.${stats.totalRevenue.toStringAsFixed(0)}',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AdminUserEntity user;
  final VoidCallback onTap;

  const _UserCard({required this.user, required this.onTap});

  Color _roleColor() {
    switch (user.role) {
      case 'admin':
        return Colors.red;
      case 'tutor':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _roleColor().withAlpha(25),
          child: Text(
            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
            style: TextStyle(color: _roleColor(), fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(user.email, style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _roleColor().withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            user.role.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _roleColor(),
            ),
          ),
        ),
      ),
    );
  }
}
