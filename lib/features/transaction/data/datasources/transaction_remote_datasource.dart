import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<PaymentInitModel> initBookingPayment(String bookingId);
  Future<void> processBookingPayment({
    required String transactionId,
    required String transactionCode,
  });
  Future<List<TransactionModel>> getSentTransactions();
  Future<List<TransactionModel>> getReceivedTransactions();
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final ApiClient apiClient;
  TransactionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PaymentInitModel> initBookingPayment(String bookingId) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.initBookingPayment(bookingId),
      );

      if (response.statusCode == 200) {
        return PaymentInitModel.fromJson(response.data);
      }
      throw ServerException( response.data['message'] ?? 'Failed to init payment',
      );
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to init payment',
      );
    }
  }

  @override
  Future<void> processBookingPayment({
    required String transactionId,
    required String transactionCode,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.processBookingPayment(transactionId),
        data: {'transactionCode': transactionCode},
      );

      if (response.statusCode == 200) {
        return;
      }
      throw ServerException( response.data['message'] ?? 'Failed to process payment',
      );
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to process payment',
      );
    }
  }

  @override
  Future<List<TransactionModel>> getSentTransactions() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.sentTransactions);

      if (response.statusCode == 200) {
        final list = response.data['transactions'] as List? ?? [];
        return list
            .map((t) => TransactionModel.fromJson(t as Map<String, dynamic>))
            .toList();
      }
      throw ServerException( 'Failed to fetch sent transactions');
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to fetch sent transactions',
      );
    }
  }

  @override
  Future<List<TransactionModel>> getReceivedTransactions() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.receivedTransactions);

      if (response.statusCode == 200) {
        final list = response.data['transactions'] as List? ?? [];
        return list
            .map((t) => TransactionModel.fromJson(t as Map<String, dynamic>))
            .toList();
      }
      throw ServerException( 'Failed to fetch received transactions');
    } on DioException catch (e) {
      throw ServerException( e.response?.data['message'] ?? 'Failed to fetch received transactions',
      );
    }
  }
}
