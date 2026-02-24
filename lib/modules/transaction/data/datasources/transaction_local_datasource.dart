import '../../domain/entities/transaction_entity.dart';
import '../../domain/enums/transaction_status.dart';

/// Local data source interface for transaction operations.
/// Defines contracts for all transaction caching operations.
abstract class TransactionLocalDatasource {
  /// Cache a single transaction
  Future<void> cacheTransaction(TransactionEntity transaction);

  /// Cache multiple transactions
  Future<void> cacheTransactions(List<TransactionEntity> transactions);

  /// Get cached transaction by ID
  Future<TransactionEntity?> getCachedTransaction(String transactionId);

  /// Get cached sent transactions for a user
  Future<List<TransactionEntity>> getCachedSentTransactions({
    required String userId,
    TransactionStatus? statusFilter,
  });

  /// Get cached received transactions for a user
  Future<List<TransactionEntity>> getCachedReceivedTransactions({
    required String userId,
    TransactionStatus? statusFilter,
  });

  /// Update cached transaction
  Future<void> updateCachedTransaction(TransactionEntity transaction);

  /// Remove cached transaction
  Future<void> removeCachedTransaction(String transactionId);

  /// Clear cached transactions for a user
  Future<void> clearCachedTransactionsForUser(String userId);

  /// Clear expired cache entries
  Future<void> clearExpiredCache();

  /// Check if transaction is cached and valid
  Future<bool> isTransactionCachedAndValid(String transactionId);

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats();

  /// Clear all cached transactions
  Future<void> clearAllCache();
}
