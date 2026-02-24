import 'package:dartz/dartz.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/enums/reference_type.dart';
import '../../domain/enums/transaction_status.dart';
import '../../domain/failures/transaction_failures.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../dtos/create_transaction_dto.dart';

/// Repository implementation for transaction operations.
/// Implements cache-first strategy with comprehensive error handling.
class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final TransactionRemoteDatasource remoteDataSource;
  final TransactionLocalDatasource localDataSource;

  @override
  Future<Either<TransactionFailure, TransactionEntity>> createTransaction({
    required String senderId,
    required String receiverId,
    required String referenceId,
    required ReferenceType referenceType,
    required double totalAmount,
    double? commissionRate,
    String? notes,
  }) async {
    try {
      // Create DTO for API request
      final createDto = CreateTransactionDto(
        senderId: senderId,
        receiverId: receiverId,
        referenceId: referenceId,
        referenceType: referenceType.value,
        totalAmount: totalAmount,
        commissionRate: commissionRate,
        notes: notes,
      );

      // Make API call
      final transactionDto = await remoteDataSource.createTransaction(
        createDto,
      );

      // Convert to entity
      final transaction = transactionDto.toEntity();

      // Cache the new transaction
      try {
        await localDataSource.cacheTransaction(transaction);
      } catch (cacheError) {
        // Don't fail the whole operation for cache errors
        print('Warning: Failed to cache new transaction: $cacheError');
      }

      return Right(transaction);
    } on TransactionFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        TransactionUnknownFailure('Failed to create transaction: $e'),
      );
    }
  }

  @override
  Future<Either<TransactionFailure, TransactionEntity>> getTransactionById(
    String transactionId,
  ) async {
    // Try cache first
    try {
      final cachedTransaction = await localDataSource.getCachedTransaction(
        transactionId,
      );
      if (cachedTransaction != null) {
        return Right(cachedTransaction);
      }
    } catch (cacheError) {
      print('Cache read error: $cacheError');
    }

    // Fetch from API
    try {
      final transactionDto = await remoteDataSource.getTransactionById(
        transactionId,
      );
      final transaction = transactionDto.toEntity();

      // Cache the transaction
      try {
        await localDataSource.cacheTransaction(transaction);
      } catch (cacheError) {
        print('Warning: Failed to cache transaction: $cacheError');
      }

      return Right(transaction);
    } on TransactionFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(TransactionUnknownFailure('Failed to get transaction: $e'));
    }
  }

  @override
  Future<Either<TransactionFailure, TransactionEntity?>>
  findTransactionByReference(String referenceId) async {
    try {
      final transactionDto = await remoteDataSource.findTransactionByReference(
        referenceId,
      );

      if (transactionDto == null) {
        return const Right(null);
      }

      final transaction = transactionDto.toEntity();

      // Cache the transaction
      try {
        await localDataSource.cacheTransaction(transaction);
      } catch (cacheError) {
        print('Warning: Failed to cache transaction: $cacheError');
      }

      return Right(transaction);
    } on TransactionFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(TransactionUnknownFailure('Failed to find transaction: $e'));
    }
  }

  @override
  Future<Either<TransactionFailure, List<TransactionEntity>>>
  getSentTransactions({
    required String userId,
    TransactionStatus? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
  }) async {
    // Try cache first for recent data (if no date filters)
    if (fromDate == null && toDate == null && offset == null) {
      try {
        final cachedTransactions = await localDataSource
            .getCachedSentTransactions(
              userId: userId,
              statusFilter: statusFilter,
            );

        if (cachedTransactions.isNotEmpty) {
          return Right(cachedTransactions);
        }
      } catch (cacheError) {
        print('Cache read error: $cacheError');
      }
    }

    // Fetch from API
    try {
      final response = await remoteDataSource.getSentTransactions(
        userId: userId,
        statusFilter: statusFilter,
        fromDate: fromDate,
        toDate: toDate,
        limit: limit,
        offset: offset,
      );

      final transactions = response.transactions
          .map((dto) => dto.toEntity())
          .toList();

      // Cache the transactions (if this is the first page)
      if (offset == null || offset == 0) {
        try {
          await localDataSource.cacheTransactions(transactions);
        } catch (cacheError) {
          print('Warning: Failed to cache transactions: $cacheError');
        }
      }

      return Right(transactions);
    } on TransactionFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        TransactionUnknownFailure('Failed to get sent transactions: $e'),
      );
    }
  }

  @override
  Future<Either<TransactionFailure, List<TransactionEntity>>>
  getReceivedTransactions({
    required String userId,
    TransactionStatus? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
  }) async {
    // Try cache first for recent data (if no date filters)
    if (fromDate == null && toDate == null && offset == null) {
      try {
        final cachedTransactions = await localDataSource
            .getCachedReceivedTransactions(
              userId: userId,
              statusFilter: statusFilter,
            );

        if (cachedTransactions.isNotEmpty) {
          return Right(cachedTransactions);
        }
      } catch (cacheError) {
        print('Cache read error: $cacheError');
      }
    }

    // Fetch from API
    try {
      final response = await remoteDataSource.getReceivedTransactions(
        userId: userId,
        statusFilter: statusFilter,
        fromDate: fromDate,
        toDate: toDate,
        limit: limit,
        offset: offset,
      );

      final transactions = response.transactions
          .map((dto) => dto.toEntity())
          .toList();

      // Cache the transactions (if this is the first page)
      if (offset == null || offset == 0) {
        try {
          await localDataSource.cacheTransactions(transactions);
        } catch (cacheError) {
          print('Warning: Failed to cache transactions: $cacheError');
        }
      }

      return Right(transactions);
    } on TransactionFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        TransactionUnknownFailure('Failed to get received transactions: $e'),
      );
    }
  }

  @override
  Future<Either<TransactionFailure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      // Prepare update data (only send changed fields)
      final updates = {
        'status': transaction.status.value,
        if (transaction.completedAt != null)
          'completed_at': transaction.completedAt!.toIso8601String(),
        if (transaction.failureReason != null)
          'failure_reason': transaction.failureReason,
        if (transaction.paymentGatewayTransactionId != null)
          'payment_gateway_transaction_id':
              transaction.paymentGatewayTransactionId,
      };

      final transactionDto = await remoteDataSource.updateTransaction(
        transactionId: transaction.id,
        updates: updates,
      );

      final updatedTransaction = transactionDto.toEntity();

      // Update cache
      try {
        await localDataSource.updateCachedTransaction(updatedTransaction);
      } catch (cacheError) {
        print('Warning: Failed to update cached transaction: $cacheError');
      }

      return Right(updatedTransaction);
    } on TransactionFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        TransactionUnknownFailure('Failed to update transaction: $e'),
      );
    }
  }

  @override
  Future<Either<TransactionFailure, Map<String, dynamic>>> getTransactionStats({
    required String userId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final stats = await remoteDataSource.getTransactionStats(
        userId: userId,
        fromDate: fromDate,
        toDate: toDate,
      );

      return Right(stats);
    } on TransactionFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        TransactionUnknownFailure('Failed to get transaction stats: $e'),
      );
    }
  }

  @override
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
  }) async {
    try {
      final response = await remoteDataSource.searchTransactions(
        senderId: senderId,
        receiverId: receiverId,
        referenceType: referenceType,
        status: status,
        fromDate: fromDate,
        toDate: toDate,
        limit: limit,
        offset: offset,
      );

      final transactions = response.transactions
          .map((dto) => dto.toEntity())
          .toList();
      return Right(transactions);
    } on TransactionFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        TransactionUnknownFailure('Failed to search transactions: $e'),
      );
    }
  }

  @override
  Future<Either<TransactionFailure, bool>> hasPendingTransaction(
    String referenceId,
  ) async {
    try {
      final hasPending = await remoteDataSource.hasPendingTransaction(
        referenceId,
      );
      return Right(hasPending);
    } on TransactionFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        TransactionUnknownFailure('Failed to check pending transaction: $e'),
      );
    }
  }
}
