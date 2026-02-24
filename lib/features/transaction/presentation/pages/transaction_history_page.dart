import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transaction_providers.dart';

class TransactionHistoryPage extends ConsumerStatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  ConsumerState<TransactionHistoryPage> createState() =>
      _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends ConsumerState<TransactionHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTransactions();
  }

  void _loadTransactions() {
    ref.read(transactionNotifierProvider.notifier).fetchSentTransactions();
    ref.read(transactionNotifierProvider.notifier).fetchReceivedTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Payments Made', icon: Icon(Icons.arrow_upward)),
            Tab(text: 'Income Received', icon: Icon(Icons.arrow_downward)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Sent Transactions (Payments)
          _buildTransactionList(
            transactions: txState.sentTransactions,
            isLoading: txState.isLoading,
            error: txState.error,
            isSent: true,
          ),
          // Received Transactions (Income)
          _buildTransactionList(
            transactions: txState.receivedTransactions,
            isLoading: txState.isLoading,
            error: txState.error,
            isSent: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList({
    required List<TransactionEntity> transactions,
    required bool isLoading,
    String? error,
    required bool isSent,
  }) {
    if (isLoading && transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 8),
            Text(error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTransactions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSent ? Icons.payment : Icons.account_balance_wallet,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isSent ? 'No payments made yet' : 'No income received yet',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadTransactions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return _TransactionCard(
            transaction: tx,
            isSent: isSent,
          );
        },
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionEntity transaction;
  final bool isSent;

  const _TransactionCard({
    required this.transaction,
    required this.isSent,
  });

  @override
  Widget build(BuildContext context) {
    final name = isSent
        ? (transaction.receiverName ?? 'Tutor')
        : (transaction.senderName ?? 'Student');
    final image = isSent ? transaction.receiverImage : transaction.senderImage;
    final dateStr = DateFormat('MMM dd, yyyy • hh:mm a')
        .format(transaction.createdAt.toLocal());

    Color statusColor;
    String statusText;
    switch (transaction.status) {
      case 'done':
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Completed';
        break;
      case 'failed':
        statusColor = Colors.red;
        statusText = 'Failed';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Pending';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundImage: image != null
                  ? NetworkImage(ApiEndpoints.getImageUrl(image) ?? '')
                  : null,
              child: image == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 20),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  if (transaction.bookingStartTime != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Session: ${DateFormat('MMM dd').format(transaction.bookingStartTime!)}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Amount & Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isSent ? "-" : "+"}Rs. ${transaction.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isSent ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
