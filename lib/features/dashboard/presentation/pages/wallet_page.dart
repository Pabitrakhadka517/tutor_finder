import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transaction/presentation/pages/transaction_history_page.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/dashboard_providers.dart';

/// Wallet page showing balance and quick links to transaction history
class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final authState = ref.read(authNotifierProvider);
    final userId = authState.user?.id ?? '';
    final role = authState.user?.role.name.toUpperCase() ?? 'STUDENT';
    if (role == 'STUDENT') {
      ref
          .read(dashboardNotifierProvider.notifier)
          .fetchStudentDashboard(userId);
    } else if (role == 'TUTOR') {
      ref.read(dashboardNotifierProvider.notifier).fetchTutorDashboard(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashState = ref.watch(dashboardNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final isTutor = authState.user?.isTutor == true;

    // Get balance data from dashboard stats
    final totalEarnings = isTutor
        ? (dashState.tutorStats?.totalEarnings ?? 0.0)
        : 0.0;
    final pendingEarnings = isTutor
        ? (dashState.tutorStats?.pendingEarnings ?? 0.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade700, Colors.purple.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Earnings',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rs.${totalEarnings.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isTutor && pendingEarnings > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Rs.${pendingEarnings.toStringAsFixed(0)} pending',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _WalletAction(
                    icon: Icons.history,
                    label: 'Transaction\nHistory',
                    color: Colors.blue,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TransactionHistoryPage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _WalletAction(
                    icon: Icons.refresh,
                    label: 'Refresh\nBalance',
                    color: Colors.green,
                    onTap: _loadData,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Info section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'About Payments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _infoItem('Payments are processed via eSewa'),
                  _infoItem('Tutors receive 90% of session fees'),
                  _infoItem('Earnings are updated after session completion'),
                  _infoItem('View all transactions in the history page'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('  •  ', style: TextStyle(color: Colors.grey.shade500)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _WalletAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
