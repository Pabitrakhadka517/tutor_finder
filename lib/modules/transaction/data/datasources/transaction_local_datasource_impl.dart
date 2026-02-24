import 'package:hive/hive.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/enums/transaction_status.dart';
import '../models/transaction_hive_model.dart';
import 'transaction_local_datasource.dart';

/// Implementation of local data source using Hive.
/// Handles local storage and caching of transaction data.
class TransactionLocalDatasourceImpl implements TransactionLocalDatasource {
  const TransactionLocalDatasourceImpl({required this.transactionBox});

  final Box<TransactionHiveModel> transactionBox;

  @override
  Future<void> cacheTransaction(TransactionEntity transaction) async {
    try {
      final hiveModel = TransactionHiveModel.fromEntity(transaction);
      await transactionBox.put(transaction.id, hiveModel);
    } catch (e) {
      throw Exception('Failed to cache transaction: $e');
    }
  }

  @override
  Future<void> cacheTransactions(List<TransactionEntity> transactions) async {
    try {
      final Map<String, TransactionHiveModel> transactionMap = {};
      for (final transaction in transactions) {
        transactionMap[transaction.id] = TransactionHiveModel.fromEntity(
          transaction,
        );
      }
      await transactionBox.putAll(transactionMap);
    } catch (e) {
      throw Exception('Failed to cache transactions: $e');
    }
  }

  @override
  Future<TransactionEntity?> getCachedTransaction(String transactionId) async {
    try {
      final hiveModel = transactionBox.get(transactionId);
      if (hiveModel == null) return null;

      // Check if expired
      if (hiveModel.isExpired()) {
        await transactionBox.delete(transactionId);
        return null;
      }

      return hiveModel.toEntity();
    } catch (e) {
      // If error, remove corrupted data and return null
      await transactionBox.delete(transactionId);
      return null;
    }
  }

  @override
  Future<List<TransactionEntity>> getCachedSentTransactions({
    required String userId,
    TransactionStatus? statusFilter,
  }) async {
    try {
      final List<TransactionEntity> results = [];
      final List<String> toDelete = [];

      for (final hiveModel in transactionBox.values) {
        // Check if expired
        if (hiveModel.isExpired()) {
          toDelete.add(hiveModel.id);
          continue;
        }

        // Check if this is a sent transaction (user is sender)
        if (hiveModel.senderId != userId) {
          continue;
        }

        // Check status filter
        if (statusFilter != null && hiveModel.status != statusFilter.value) {
          continue;
        }

        try {
          results.add(hiveModel.toEntity());
        } catch (e) {
          // If conversion fails, mark for deletion
          toDelete.add(hiveModel.id);
        }
      }

      // Clean up expired/corrupted data
      await transactionBox.deleteAll(toDelete);

      // Sort by created date (newest first)
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return results;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<TransactionEntity>> getCachedReceivedTransactions({
    required String userId,
    TransactionStatus? statusFilter,
  }) async {
    try {
      final List<TransactionEntity> results = [];
      final List<String> toDelete = [];

      for (final hiveModel in transactionBox.values) {
        // Check if expired
        if (hiveModel.isExpired()) {
          toDelete.add(hiveModel.id);
          continue;
        }

        // Check if this is a received transaction (user is receiver)
        if (hiveModel.receiverId != userId) {
          continue;
        }

        // Check status filter
        if (statusFilter != null && hiveModel.status != statusFilter.value) {
          continue;
        }

        try {
          results.add(hiveModel.toEntity());
        } catch (e) {
          // If conversion fails, mark for deletion
          toDelete.add(hiveModel.id);
        }
      }

      // Clean up expired/corrupted data
      await transactionBox.deleteAll(toDelete);

      // Sort by created date (newest first)
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return results;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> updateCachedTransaction(TransactionEntity transaction) async {
    try {
      final existing = transactionBox.get(transaction.id);
      if (existing != null) {
        // Update existing with new data but preserve cache timestamp if recent
        final updated = TransactionHiveModel.fromEntity(transaction);
        if (!existing.isExpired(const Duration(minutes: 5))) {
          updated.cachedAt = existing.cachedAt;
        }
        await transactionBox.put(transaction.id, updated);
      } else {
        // Create new cache entry
        await cacheTransaction(transaction);
      }
    } catch (e) {
      throw Exception('Failed to update cached transaction: $e');
    }
  }

  @override
  Future<void> removeCachedTransaction(String transactionId) async {
    try {
      await transactionBox.delete(transactionId);
    } catch (e) {
      throw Exception('Failed to remove cached transaction: $e');
    }
  }

  @override
  Future<void> clearCachedTransactionsForUser(String userId) async {
    try {
      final toDelete = <String>[];

      for (final hiveModel in transactionBox.values) {
        if (hiveModel.senderId == userId || hiveModel.receiverId == userId) {
          toDelete.add(hiveModel.id);
        }
      }

      await transactionBox.deleteAll(toDelete);
    } catch (e) {
      throw Exception('Failed to clear cached transactions for user: $e');
    }
  }

  @override
  Future<void> clearExpiredCache() async {
    try {
      final toDelete = <String>[];

      for (final hiveModel in transactionBox.values) {
        if (hiveModel.isExpired()) {
          toDelete.add(hiveModel.id);
        }
      }

      await transactionBox.deleteAll(toDelete);
    } catch (e) {
      throw Exception('Failed to clear expired cache: $e');
    }
  }

  @override
  Future<bool> isTransactionCachedAndValid(String transactionId) async {
    try {
      final hiveModel = transactionBox.get(transactionId);
      return hiveModel != null && !hiveModel.isExpired();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      int total = 0;
      int expired = 0;
      int sent = 0;
      int received = 0;
      int completed = 0;
      int pending = 0;

      for (final hiveModel in transactionBox.values) {
        total++;

        if (hiveModel.isExpired()) {
          expired++;
          continue;
        }

        final entity = hiveModel.toEntity();
        if (entity.status == TransactionStatus.completed) {
          completed++;
        } else if (entity.status == TransactionStatus.pending) {
          pending++;
        }
      }

      return {
        'total_cached': total,
        'expired': expired,
        'valid': total - expired,
        'completed': completed,
        'pending': pending,
      };
    } catch (e) {
      return {
        'total_cached': 0,
        'expired': 0,
        'valid': 0,
        'completed': 0,
        'pending': 0,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      await transactionBox.clear();
    } catch (e) {
      throw Exception('Failed to clear all cache: $e');
    }
  }
}
