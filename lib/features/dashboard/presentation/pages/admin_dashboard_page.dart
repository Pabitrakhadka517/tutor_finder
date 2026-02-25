import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../admin/presentation/pages/admin_users_page.dart';
import '../../../admin/presentation/pages/announcements_page.dart';
import '../../../admin/presentation/providers/admin_providers.dart';
import '../../../notification/presentation/pages/notification_page.dart';
import '../providers/dashboard_providers.dart';

/// Admin-specific dashboard page
/// Displays platform overview, user stats, revenue, and management quick actions
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    ref.read(dashboardNotifierProvider.notifier).fetchAdminDashboard();
    // Also load admin-specific stats
    ref.read(adminNotifierProvider.notifier).fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardNotifierProvider);
    final adminState = ref.watch(adminNotifierProvider);
    final stats = dashboardState.adminStats;
    final platformStats = adminState.stats;

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Header
            _buildAdminHeader(),

            const SizedBox(height: 20),

            if (dashboardState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (dashboardState.errorMessage != null)
              _buildErrorCard(dashboardState.errorMessage!)
            else ...[
              // User Stats Cards
              _buildUserStatsSection(stats, platformStats),
              const SizedBox(height: 20),

              // Revenue Cards
              _buildRevenueSection(stats, platformStats),
              const SizedBox(height: 20),

              // Management Quick Actions
              _buildManagementActions(),
              const SizedBox(height: 20),

              // Platform Health
              _buildPlatformHealth(stats, platformStats),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdminHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade700, Colors.purple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Platform Overview',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Admin Control Panel',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh Analytics'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatsSection(dynamic stats, dynamic platformStats) {
    final totalUsers = stats?.totalUsers ?? platformStats?.totalUsers ?? 0;
    final totalTutors = stats?.totalTutors ?? platformStats?.totalTutors ?? 0;
    final totalStudents =
        stats?.totalStudents ?? platformStats?.totalStudents ?? 0;
    final pendingVerifications =
        stats?.pendingVerifications ?? platformStats?.pendingVerifications ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AdminStatCard(
                  icon: Icons.people_rounded,
                  label: 'Total Users',
                  value: '$totalUsers',
                  color: Colors.blue,
                  iconBg: Colors.blue.shade50,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AdminStatCard(
                  icon: Icons.school_rounded,
                  label: 'Tutors',
                  value: '$totalTutors',
                  color: Colors.green,
                  iconBg: Colors.green.shade50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AdminStatCard(
                  icon: Icons.person_rounded,
                  label: 'Students',
                  value: '$totalStudents',
                  color: Colors.orange,
                  iconBg: Colors.orange.shade50,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AdminStatCard(
                  icon: Icons.pending_rounded,
                  label: 'Pending Verify',
                  value: '$pendingVerifications',
                  color: Colors.red,
                  iconBg: Colors.red.shade50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueSection(dynamic stats, dynamic platformStats) {
    final totalRevenue =
        stats?.totalRevenue ?? platformStats?.totalRevenue ?? 0.0;
    final totalCommission =
        stats?.totalCommission ?? platformStats?.totalCommission ?? 0.0;
    final totalBookings =
        stats?.totalBookings ?? platformStats?.totalBookings ?? 0;
    final totalCompletedSessions = stats?.totalCompletedSessions ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue & Transactions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 12),
          // Revenue hero card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade600, Colors.teal.shade400],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Platform Revenue',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rs. ${totalRevenue is double ? totalRevenue.toStringAsFixed(0) : totalRevenue}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AdminStatCard(
                  icon: Icons.monetization_on_rounded,
                  label: 'Commission',
                  value:
                      'Rs. ${totalCommission is double ? totalCommission.toStringAsFixed(0) : totalCommission}',
                  color: Colors.purple,
                  iconBg: Colors.purple.shade50,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AdminStatCard(
                  icon: Icons.book_rounded,
                  label: 'Total Bookings',
                  value: '$totalBookings',
                  color: Colors.indigo,
                  iconBg: Colors.indigo.shade50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AdminStatCard(
            icon: Icons.check_circle_rounded,
            label: 'Completed Sessions',
            value: '$totalCompletedSessions',
            color: Colors.green,
            iconBg: Colors.green.shade50,
          ),
        ],
      ),
    );
  }

  Widget _buildManagementActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 12),
          _ManagementTile(
            icon: Icons.people_outline_rounded,
            title: 'User Management',
            subtitle: 'View, edit, and manage all users',
            color: Colors.blue,
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AdminUsersPage())),
          ),
          const SizedBox(height: 10),
          _ManagementTile(
            icon: Icons.campaign_rounded,
            title: 'Announcements',
            subtitle: 'Broadcast messages to users',
            color: Colors.orange,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AnnouncementsPage()),
            ),
          ),
          const SizedBox(height: 10),
          _ManagementTile(
            icon: Icons.notifications_active_rounded,
            title: 'Notifications',
            subtitle: 'View platform notifications',
            color: Colors.red,
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const NotificationPage())),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformHealth(dynamic stats, dynamic platformStats) {
    final totalBookings =
        stats?.totalBookings ?? platformStats?.totalBookings ?? 0;
    final completedSessions = stats?.totalCompletedSessions ?? 0;
    final completionRate = totalBookings > 0
        ? (completedSessions / totalBookings * 100)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Health',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _HealthMetric(
                  label: 'Session Completion Rate',
                  value: '${completionRate.toStringAsFixed(1)}%',
                  progress: completionRate / 100,
                  color: completionRate >= 70
                      ? Colors.green
                      : completionRate >= 40
                      ? Colors.orange
                      : Colors.red,
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    _HealthIndicator(
                      icon: Icons.check_circle_rounded,
                      label: 'System Status',
                      status: 'Operational',
                      color: Colors.green,
                    ),
                    const SizedBox(width: 16),
                    _HealthIndicator(
                      icon: Icons.speed_rounded,
                      label: 'Performance',
                      status: 'Good',
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.shade400),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
              ),
            ),
            TextButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color iconBg;

  const _AdminStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagementTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ManagementTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _HealthMetric extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final Color color;

  const _HealthMetric({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _HealthIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final Color color;

  const _HealthIndicator({
    required this.icon,
    required this.label,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
