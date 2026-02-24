import 'package:dartz/dartz.dart';

import '../entities/transaction_entity.dart';
import '../enums/transaction_status.dart';
import '../failures/transaction_failures.dart';
import '../repositories/transaction_repository.dart';

/// Use case to get transactions received by a user.
/// Retrieves all incoming payments with optional filtering.
class GetReceivedTransactionsUseCase {
  const GetReceivedTransactionsUseCase({required this.transactionRepository});

  final TransactionRepository transactionRepository;

  /// Get received transactions for a user
  Future<Either<TransactionFailure, List<TransactionEntity>>> call({
    required String userId,
    TransactionStatus? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
  }) async {
    // Validate date range
    if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
      return const Left(
        TransactionValidationFailure('From date cannot be after to date'),
      );
    }

    // Validate pagination parameters
    if (limit != null && limit <= 0) {
      return const Left(
        TransactionValidationFailure('Limit must be greater than 0'),
      );
    }

    if (offset != null && offset < 0) {
      return const Left(
        TransactionValidationFailure('Offset cannot be negative'),
      );
    }

    // Get received transactions from repository
    return await transactionRepository.getReceivedTransactions(
      userId: userId,
      statusFilter: statusFilter,
      fromDate: fromDate,
      toDate: toDate,
      limit: limit,
      offset: offset,
    );
  }
}
