import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../booking/presentation/pages/booking_list_page.dart';
import '../../../chat/presentation/pages/chat_list_page.dart';
import '../../../notification/presentation/pages/notification_page.dart';
import '../../../study/presentation/pages/study_resources_page.dart';
import '../../../transaction/presentation/pages/transaction_history_page.dart';
import '../../../tutor/presentation/pages/tutor_list_page.dart';
import 'wallet_page.dart';
import '../providers/dashboard_providers.dart';

/// Student-specific dashboard page
/// Displays student stats, upcoming sessions, quick actions, and recent activity
class StudentDashboardPage extends ConsumerStatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  ConsumerState<StudentDashboardPage> createState() =>
      _StudentDashboardPageState();
}

class _StudentDashboardPageState extends ConsumerState<StudentDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authState = ref.read(authNotifierProvider);
    final userId = authState.user?.id ?? '';
    ref.read(dashboardNotifierProvider.notifier).fetchStudentDashboard(userId);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final dashboardState = ref.watch(dashboardNotifierProvider);
    final user = authState.user;
    final stats = dashboardState.studentStats;

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Hero Section
            _buildWelcomeHero(user?.name ?? 'Student'),

            const SizedBox(height: 20),

            // Stats Cards
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
              _buildStatsGrid(stats),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 20),
              _buildUpcomingSessions(stats),
              const SizedBox(height: 20),
              _buildRecentActivity(stats),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHero(String name) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
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
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ready to learn something new today?',
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
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TutorListPage()),
                  ),
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Find a Tutor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TransactionHistoryPage(),
                    ),
                  ),
                  icon: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 18,
                  ),
                  label: const Text('Wallet'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(dynamic stats) {
    final totalBookings = stats?.totalBookings ?? 0;
    final upcomingBookings = stats?.upcomingBookings ?? 0;
    final completedBookings = stats?.completedBookings ?? 0;
    final totalSpent = stats?.totalSpent ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.book_rounded,
                  label: 'Total Sessions',
                  value: '$totalBookings',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.upcoming_rounded,
                  label: 'Upcoming',
                  value: '$upcomingBookings',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_rounded,
                  label: 'Completed',
                  value: '$completedBookings',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Total Spent',
                  value: 'Rs. ${totalSpent.toStringAsFixed(0)}',
                  color: Colors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickActionChip(
                  icon: Icons.search_rounded,
                  label: 'Find Tutors',
                  color: Colors.blue,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TutorListPage()),
                  ),
                ),
                const SizedBox(width: 10),
                _QuickActionChip(
                  icon: Icons.calendar_today_rounded,
                  label: 'My Bookings',
                  color: Colors.green,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BookingListPage()),
                  ),
                ),
                const SizedBox(width: 10),
                _QuickActionChip(
                  icon: Icons.menu_book_rounded,
                  label: 'Study Materials',
                  color: Colors.purple,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const StudyResourcesPage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _QuickActionChip(
                  icon: Icons.chat_rounded,
                  label: 'Messages',
                  color: Colors.indigo,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChatListPage()),
                  ),
                ),
                const SizedBox(width: 10),
                _QuickActionChip(
                  icon: Icons.notifications_rounded,
                  label: 'Notifications',
                  color: Colors.amber.shade700,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationPage()),
                  ),
                ),
                const SizedBox(width: 10),
                _QuickActionChip(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Wallet',
                  color: Colors.teal,
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const WalletPage())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSessions(dynamic stats) {
    final recentBookings = stats?.recentBookings ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Sessions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BookingListPage()),
                ),
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (recentBookings.isEmpty)
            _buildEmptyState(
              icon: Icons.calendar_today_rounded,
              title: 'No Upcoming Sessions',
              subtitle: 'Book a tutor to get started!',
            )
          else
            ...recentBookings
                .take(3)
                .map<Widget>(
                  (booking) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.subject,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(booking.scheduledDate),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusBadge(booking.status.name),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(dynamic stats) {
    final recentTransactions = stats?.recentTransactions ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TransactionHistoryPage(),
                  ),
                ),
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (recentTransactions.isEmpty)
            _buildEmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'No Recent Transactions',
              subtitle: 'Your transaction history will appear here',
            )
          else
            ...recentTransactions
                .take(5)
                .map<Widget>(
                  (tx) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tx.type.name == 'payment'
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          color: tx.type.name == 'payment'
                              ? Colors.red
                              : Colors.green,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tx.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          'Rs. ${tx.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: tx.type.name == 'payment'
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.blue.shade200),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'completed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Reusable stat card widget
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// Quick action chip widget
class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
