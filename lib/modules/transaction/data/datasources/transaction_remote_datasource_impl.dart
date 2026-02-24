import 'package:dio/dio.dart';

import '../../domain/enums/reference_type.dart';
import '../../domain/enums/transaction_status.dart';
import '../../domain/failures/transaction_failures.dart';
import '../dtos/create_transaction_dto.dart';
import '../dtos/process_payment_dto.dart';
import '../dtos/transaction_dto.dart';
import '../dtos/transaction_list_response_dto.dart';
import '../../utils/transaction_api_endpoints.dart';
import 'transaction_remote_datasource.dart';

/// Implementation of remote data source using Dio HTTP client.
/// Handles API communication with comprehensive error handling.
class TransactionRemoteDatasourceImpl implements TransactionRemoteDatasource {
  const TransactionRemoteDatasourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<TransactionDto> createTransaction(
    CreateTransactionDto createDto,
  ) async {
    try {
      final response = await dio.post(
        TransactionApiEndpoints.createTransaction,
        data: createDto.toJson(),
      );

      return TransactionDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw TransactionUnknownFailure('Failed to create transaction: $e');
    }
  }

  @override
  Future<TransactionDto> getTransactionById(String transactionId) async {
    try {
      final response = await dio.get(
        TransactionApiEndpoints.getTransactionById(transactionId),
      );

      return TransactionDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw TransactionUnknownFailure('Failed to get transaction: $e');
    }
  }

  @override
  Future<TransactionDto?> findTransactionByReference(String referenceId) async {
    try {
      final response = await dio.get(
        TransactionApiEndpoints.findByReference(referenceId),
      );

      if (response.data == null) return null;
      return TransactionDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _mapDioException(e);
    } catch (e) {
      throw TransactionUnknownFailure(
        'Failed to find transaction by reference: $e',
      );
    }
  }

  @override
  Future<TransactionListResponseDto> getSentTransactions({
    required String userId,
    TransactionStatus? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = {
        'user_id': userId,
        if (statusFilter != null) 'status': statusFilter.value,
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      };

      final response = await dio.get(
        TransactionApiEndpoints.getSentTransactions,
        queryParameters: queryParams,
      );

      return TransactionListResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw TransactionUnknownFailure('Failed to get sent transactions: $e');
    }
  }

  @override
  Future<TransactionListResponseDto> getReceivedTransactions({
    required String userId,
    TransactionStatus? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = {
        'user_id': userId,
        if (statusFilter != null) 'status': statusFilter.value,
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      };

      final response = await dio.get(
        TransactionApiEndpoints.getReceivedTransactions,
        queryParameters: queryParams,
      );

      return TransactionListResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw TransactionUnknownFailure(
        'Failed to get received transactions: $e',
      );
    }
  }

  @override
  Future<TransactionDto> updateTransaction({
    required String transactionId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await dio.put(
        TransactionApiEndpoints.updateTransaction(transactionId),
        data: updates,
      );

      return TransactionDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw TransactionUnknownFailure('Failed to update transaction: $e');
    }
  }

  @override
  Future<TransactionDto> processPayment(
    ProcessPaymentDto processPaymentDto,
  ) async {
    try {
      final response = await dio.post(
        TransactionApiEndpoints.processPayment,
        data: processPaymentDto.toJson(),
      );

      return TransactionDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw TransactionUnknownFailure('Failed to process payment: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getTransactionStats({
    required String userId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = {
        'user_id': userId,
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
      };

      final response = await dio.get(
        TransactionApiEndpoints.getTransactionStats,
        queryParameters: queryParams,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw TransactionUnknownFailure('Failed to get transaction stats: $e');
    }
  }

  @override
  Future<TransactionListResponseDto> searchTransactions({
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
      final queryParams = <String, String>{};
      if (senderId != null) queryParams['sender_id'] = senderId;
      if (receiverId != null) queryParams['receiver_id'] = receiverId;
      if (referenceType != null)
        queryParams['reference_type'] = referenceType.value;
      if (status != null) queryParams['status'] = status.value;
      if (fromDate != null)
        queryParams['from_date'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['to_date'] = toDate.toIso8601String();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final response = await dio.get(
        TransactionApiEndpoints.searchTransactions,
        queryParameters: queryParams,
      );

      return TransactionListResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw TransactionUnknownFailure('Failed to search transactions: $e');
    }
  }

  @override
  Future<bool> hasPendingTransaction(String referenceId) async {
    try {
      final response = await dio.get(
        TransactionApiEndpoints.checkPendingTransaction(referenceId),
      );

      return response.data['has_pending'] as bool;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw TransactionUnknownFailure(
        'Failed to check pending transaction: $e',
      );
    }
  }

  /// Map Dio exceptions to domain failures
  TransactionFailure _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TransactionNetworkFailure(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.connectionError:
        return const TransactionNetworkFailure(
          'No internet connection. Please check your network.',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Unknown server error';

        return switch (statusCode ?? 0) {
          400 => TransactionValidationFailure('Invalid request: $message'),
          401 => const TransactionAuthorizationFailure(
            'Authentication required. Please log in.',
          ),
          403 => const TransactionAuthorizationFailure(
            'Access denied. You don\'t have permission.',
          ),
          404 => TransactionNotFoundFailure('Transaction not found: $message'),
          409 => TransactionConflictFailure('Transaction conflict: $message'),
          422 => TransactionValidationFailure('Validation error: $message'),
          >= 500 => TransactionServerFailure(
            'Server error: $message',
            statusCode: statusCode,
          ),
          _ => TransactionServerFailure(
            'HTTP error: $message',
            statusCode: statusCode,
          ),
        };

      case DioExceptionType.cancel:
        return const TransactionUnknownFailure('Request was cancelled');

      case DioExceptionType.unknown:
        return TransactionUnknownFailure('Network error: ${e.message}');

      default:
        return TransactionUnknownFailure('Unknown error: ${e.message}');
    }
  }
}
