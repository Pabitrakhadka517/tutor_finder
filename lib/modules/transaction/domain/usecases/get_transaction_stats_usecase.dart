import 'package:dartz/dartz.dart';

import '../failures/transaction_failures.dart';
import '../repositories/transaction_repository.dart';

/// Use case to get transaction statistics for a user.
/// Provides analytics and insights about user's transaction history.
class GetTransactionStatsUseCase {
  const GetTransactionStatsUseCase({required this.transactionRepository});

  final TransactionRepository transactionRepository;

  /// Get transaction statistics for a user
  Future<Either<TransactionFailure, TransactionStats>> call({
    required String userId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // Validate date range
    if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
      return const Left(
        TransactionValidationFailure('From date cannot be after to date'),
      );
    }

    // Get statistics from repository
    final statsResult = await transactionRepository.getTransactionStats(
      userId: userId,
      fromDate: fromDate,
      toDate: toDate,
    );

    if (statsResult.isLeft()) {
      return Left(
        statsResult.fold((l) => l, (r) => throw StateError('Unreachable')),
      );
    }

    final stats = statsResult.getOrElse(
      () => throw StateError('Handled above'),
    );

    // Transform raw data into structured stats
    return Right(TransactionStats.fromMap(stats));
  }
}

/// Structured transaction statistics
class TransactionStats {
  const TransactionStats({
    required this.totalSent,
    required this.totalReceived,
    required this.totalSentAmount,
    required this.totalReceivedAmount,
    required this.totalCommissionPaid,
    required this.averageTransactionAmount,
    required this.completedTransactions,
    required this.pendingTransactions,
    required this.failedTransactions,
    required this.bookingTransactions,
    required this.jobTransactions,
  });

  final int totalSent;
  final int totalReceived;
  final double totalSentAmount;
  final double totalReceivedAmount;
  final double totalCommissionPaid;
  final double averageTransactionAmount;
  final int completedTransactions;
  final int pendingTransactions;
  final int failedTransactions;
  final int bookingTransactions;
  final int jobTransactions;

  factory TransactionStats.fromMap(Map<String, dynamic> map) {
    return TransactionStats(
      totalSent: (map['total_sent'] ?? 0) as int,
      totalReceived: (map['total_received'] ?? 0) as int,
      totalSentAmount: (map['total_sent_amount'] ?? 0.0) as double,
      totalReceivedAmount: (map['total_received_amount'] ?? 0.0) as double,
      totalCommissionPaid: (map['total_commission_paid'] ?? 0.0) as double,
      averageTransactionAmount:
          (map['average_transaction_amount'] ?? 0.0) as double,
      completedTransactions: (map['completed_transactions'] ?? 0) as int,
      pendingTransactions: (map['pending_transactions'] ?? 0) as int,
      failedTransactions: (map['failed_transactions'] ?? 0) as int,
      bookingTransactions: (map['booking_transactions'] ?? 0) as int,
      jobTransactions: (map['job_transactions'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total_sent': totalSent,
      'total_received': totalReceived,
      'total_sent_amount': totalSentAmount,
      'total_received_amount': totalReceivedAmount,
      'total_commission_paid': totalCommissionPaid,
      'average_transaction_amount': averageTransactionAmount,
      'completed_transactions': completedTransactions,
      'pending_transactions': pendingTransactions,
      'failed_transactions': failedTransactions,
      'booking_transactions': bookingTransactions,
      'job_transactions': jobTransactions,
    };
  }

  /// Calculate net balance (received - sent - commission)
  double get netBalance =>
      totalReceivedAmount - totalSentAmount - totalCommissionPaid;

  /// Calculate success rate as percentage
  double get successRate {
    final total = completedTransactions + failedTransactions;
    return total > 0 ? (completedTransactions / total) * 100 : 0;
  }

  /// Check if user is primarily a sender or receiver
  bool get isPrimarilySender => totalSentAmount > totalReceivedAmount;
}
