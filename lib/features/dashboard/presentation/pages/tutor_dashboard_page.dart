import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../booking/presentation/pages/booking_list_page.dart';
import '../../../chat/presentation/pages/chat_list_page.dart';
import '../../../notification/presentation/pages/notification_page.dart';
import '../../../review/presentation/pages/tutor_reviews_page.dart';
import '../../../study/presentation/pages/study_resources_page.dart';
import '../../../study/presentation/pages/my_resources_page.dart';
import '../../../transaction/presentation/pages/transaction_history_page.dart';
import 'wallet_page.dart';
import '../../../tutor/presentation/pages/availability_management_page.dart';
import '../../../tutor/presentation/pages/verification_submission_page.dart';
import 'tutor_students_page.dart';
import '../providers/dashboard_providers.dart';

/// Tutor-specific dashboard page
/// Displays earnings, verification status, sessions, students, and quick actions
class TutorDashboardPage extends ConsumerStatefulWidget {
  const TutorDashboardPage({super.key});

  @override
  ConsumerState<TutorDashboardPage> createState() => _TutorDashboardPageState();
}

class _TutorDashboardPageState extends ConsumerState<TutorDashboardPage> {
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
    ref.read(dashboardNotifierProvider.notifier).fetchTutorDashboard(userId);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final dashboardState = ref.watch(dashboardNotifierProvider);
    final user = authState.user;
    final stats = dashboardState.tutorStats;

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Hero Section
            _buildWelcomeHero(user?.name ?? 'Tutor', stats),

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
              _buildEarningsCard(stats),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 20),
              _buildPendingRequests(stats),
              const SizedBox(height: 20),
              _buildRecentActivity(stats),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHero(String name, dynamic stats) {
    final verificationStatus =
        stats?.verificationStatus?.toString().split('.').last ?? 'pending';
    final isVerified = verificationStatus.toLowerCase() == 'verified';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.teal.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
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
                    // Verification Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isVerified
                            ? Colors.white.withValues(alpha: 0.25)
                            : Colors.orange.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVerified
                                ? Icons.verified_rounded
                                : Icons.pending_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isVerified
                                ? 'Verified Tutor'
                                : 'Pending Verification',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Verification warning
          if (!isVerified)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade800.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Complete your profile and submit for verification to start receiving bookings.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(dynamic stats) {
    final totalStudents = stats?.totalStudentsWorkedWith ?? 0;
    final pendingBookings = stats?.pendingBookings ?? 0;
    final completedBookings = stats?.completedBookings ?? 0;
    final averageRating = stats?.averageRating ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Overview',
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
                child: _StatCard(
                  icon: Icons.people_rounded,
                  label: 'Total Students',
                  value: '$totalStudents',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.pending_actions_rounded,
                  label: 'Pending',
                  value: '$pendingBookings',
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
                  icon: Icons.star_rounded,
                  label: 'Avg Rating',
                  value: averageRating > 0
                      ? averageRating.toStringAsFixed(1)
                      : 'N/A',
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(dynamic stats) {
    final totalEarnings = stats?.totalEarnings ?? 0.0;
    final thisMonthEarnings = stats?.thisMonthEarnings ?? 0.0;
    final pendingEarnings = stats?.pendingEarnings ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade600, Colors.blue.shade700],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Earnings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TransactionHistoryPage(),
                    ),
                  ),
                  child: Text(
                    'Full Analytics →',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Rs. ${totalEarnings.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Total Earnings',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _EarningsMini(
                    label: 'This Month',
                    value: 'Rs. ${thisMonthEarnings.toStringAsFixed(0)}',
                  ),
                ),
                Expanded(
                  child: _EarningsMini(
                    label: 'Pending',
                    value: 'Rs. ${pendingEarnings.toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),
          ],
        ),
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
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: [
              _ActionTile(
                icon: Icons.calendar_today_rounded,
                label: 'Sessions',
                color: Colors.blue,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BookingListPage()),
                ),
              ),
              _ActionTile(
                icon: Icons.menu_book_rounded,
                label: 'My Resources',
                color: Colors.purple,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyResourcesPage()),
                ),
              ),
              _ActionTile(
                icon: Icons.chat_rounded,
                label: 'Messages',
                color: Colors.teal,
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ChatListPage())),
              ),
              _ActionTile(
                icon: Icons.star_rounded,
                label: 'Reviews',
                color: Colors.amber.shade700,
                onTap: () {
                  final userId = ref.read(authNotifierProvider).user?.id ?? '';
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TutorReviewsPage(tutorId: userId),
                    ),
                  );
                },
              ),
              _ActionTile(
                icon: Icons.notifications_rounded,
                label: 'Alerts',
                color: Colors.red,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                ),
              ),
              _ActionTile(
                icon: Icons.library_books_rounded,
                label: 'Study Hub',
                color: Colors.green,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StudyResourcesPage()),
                ),
              ),
              _ActionTile(
                icon: Icons.schedule_rounded,
                label: 'Availability',
                color: Colors.indigo,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AvailabilityManagementPage(),
                  ),
                ),
              ),
              _ActionTile(
                icon: Icons.verified_rounded,
                label: 'Verification',
                color: Colors.cyan,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const VerificationSubmissionPage(),
                  ),
                ),
              ),
              _ActionTile(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Earnings',
                color: Colors.orange,
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const WalletPage())),
              ),
              _ActionTile(
                icon: Icons.people_rounded,
                label: 'Students',
                color: Colors.deepPurple,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TutorStudentsPage()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequests(dynamic stats) {
    final recentBookings = stats?.recentBookings ?? [];
    final pendingBookings = recentBookings
        .where((b) => b.status.name.toLowerCase() == 'pending')
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Incoming Requests',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
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
          if (pendingBookings.isEmpty)
            _buildEmptyState(
              icon: Icons.inbox_rounded,
              title: 'No Pending Requests',
              subtitle: 'New booking requests will appear here',
            )
          else
            ...pendingBookings
                .take(3)
                .map<Widget>(
                  (booking) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.orange.shade100,
                        width: 1,
                      ),
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
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: Colors.orange.shade700,
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
                        Text(
                          'Rs. ${booking.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
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
                'Recent Earnings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
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
              title: 'No Recent Earnings',
              subtitle: 'Your earnings will appear here after sessions',
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
                          Icons.arrow_downward_rounded,
                          color: Colors.green.shade600,
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
                            color: Colors.green.shade700,
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
          Icon(icon, size: 40, color: Colors.green.shade200),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade900,
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

class _EarningsMini extends StatelessWidget {
  final String label;
  final String value;

  const _EarningsMini({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
