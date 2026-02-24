import 'package:dartz/dartz.dart';

import '../entities/transaction_entity.dart';
import '../enums/reference_type.dart';
import '../enums/transaction_status.dart';
import '../failures/transaction_failures.dart';

/// Repository interface for transaction operations.
/// Defines contracts for all transaction data operations.
abstract class TransactionRepository {
  /// Create a new transaction
  Future<Either<TransactionFailure, TransactionEntity>> createTransaction({
    required String senderId,
    required String receiverId,
    required String referenceId,
    required ReferenceType referenceType,
    required double totalAmount,
    double? commissionRate,
    String? notes,
  });

  /// Get transaction by ID
  Future<Either<TransactionFailure, TransactionEntity>> getTransactionById(
    String transactionId,
  );

  /// Find transaction by reference (bookingId or jobId)
  Future<Either<TransactionFailure, TransactionEntity?>>
  findTransactionByReference(String referenceId);

  /// Get transactions sent by a user
  Future<Either<TransactionFailure, List<TransactionEntity>>>
  getSentTransactions({
    required String userId,
    TransactionStatus? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
  });

  /// Get transactions received by a user
  Future<Either<TransactionFailure, List<TransactionEntity>>>
  getReceivedTransactions({
    required String userId,
    TransactionStatus? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
  });

  /// Update transaction status and related fields
  Future<Either<TransactionFailure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  );

  /// Get transaction statistics for a user
  Future<Either<TransactionFailure, Map<String, dynamic>>> getTransactionStats({
    required String userId,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Search transactions with filters
  Future<Either<TransactionFailure, List<TransactionEntity>>>
  searchTransactions({
    String? senderId,
    String? receiverId,
    ReferenceType? referenceType,
    TransactionStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
  });

  /// Check if a pending transaction exists for a reference
  Future<Either<TransactionFailure, bool>> hasPendingTransaction(
    String referenceId,
  );
}
