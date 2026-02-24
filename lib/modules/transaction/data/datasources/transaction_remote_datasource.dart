import '../../domain/enums/reference_type.dart';
import '../../domain/enums/transaction_status.dart';
import '../dtos/create_transaction_dto.dart';
import '../dtos/process_payment_dto.dart';
import '../dtos/transaction_dto.dart';
import '../dtos/transaction_list_response_dto.dart';

/// Remote data source interface for transaction operations.
/// Defines contracts for all transaction API operations.
abstract class TransactionRemoteDatasource {
  /// Create a new transaction
  Future<TransactionDto> createTransaction(CreateTransactionDto createDto);

  /// Get transaction by ID
  Future<TransactionDto> getTransactionById(String transactionId);

  /// Find transaction by reference ID (bookingId or jobId)
  Future<TransactionDto?> findTransactionByReference(String referenceId);

  /// Get sent transactions for a user
  Future<TransactionListResponseDto> getSentTransactions({
    required String userId,
    TransactionStatus? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
  });

  /// Get received transactions for a user
  Future<TransactionListResponseDto> getReceivedTransactions({
    required String userId,
    TransactionStatus? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
  });

  /// Update transaction
  Future<TransactionDto> updateTransaction({
    required String transactionId,
    required Map<String, dynamic> updates,
  });

  /// Process payment for a transaction
  Future<TransactionDto> processPayment(ProcessPaymentDto processPaymentDto);

  /// Get transaction statistics
  Future<Map<String, dynamic>> getTransactionStats({
    required String userId,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Search transactions with filters
  Future<TransactionListResponseDto> searchTransactions({
    String? senderId,
    String? receiverId,
    ReferenceType? referenceType,
    TransactionStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
  });

  /// Check if a pending transaction exists for reference
  Future<bool> hasPendingTransaction(String referenceId);
}
