import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/config/esewa_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<PaymentInitModel> initializePayment({required String bookingId});
  Future<void> verifyPayment({
    required String transactionUUID,
    required double amount,
    required String transactionCode,
    Map<String, dynamic>? callbackData,
  });
  Future<List<TransactionModel>> fetchPaymentHistory();
  Future<List<TransactionModel>> fetchReceivedHistory();
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final ApiClient apiClient;
  TransactionRemoteDataSourceImpl({required this.apiClient});

  List<TransactionModel> _extractTransactions(dynamic payload) {
    final list =
        (payload is Map<String, dynamic>
                ? payload['transactions'] ??
                      payload['payments'] ??
                      payload['history'] ??
                      payload['data']
                : null)
            as List?;

    return (list ?? const [])
        .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  PaymentInitModel _mapLegacyInitResponse({
    required Map<String, dynamic> payload,
    required String bookingId,
  }) {
    return PaymentInitModel.fromJson({
      ...payload,
      'bookingId': payload['bookingId'] ?? bookingId,
      'tutorId': payload['tutorId'] ?? '',
      'signed_field_names':
          payload['signed_field_names'] ??
          payload['signedFieldNames'] ??
          'total_amount,transaction_uuid,product_code',
      'signature': payload['signature'] ?? '',
    });
  }

  @override
  Future<PaymentInitModel> initializePayment({
    required String bookingId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.initBookingPayment(bookingId),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentInitModel.fromJson(response.data);
      }
      throw ServerException(
        response.data['message']?.toString() ?? 'Failed to initialize payment',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (EsewaConfig.allowLegacyApiFallback && e.response?.statusCode == 404) {
        final fallbackResponse = await apiClient.dio.post(
          ApiEndpoints.paymentInitBooking,
          data: {'bookingId': bookingId},
        );

        if (fallbackResponse.statusCode == 200 ||
            fallbackResponse.statusCode == 201) {
          return _mapLegacyInitResponse(
            payload: fallbackResponse.data as Map<String, dynamic>,
            bookingId: bookingId,
          );
        }
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(message: 'Payment initialization timed out');
      }

      if (e.response?.statusCode == 401) {
        throw AuthException(message: 'Unauthorized. Please login again.');
      }

      throw ServerException(
        e.response?.data['message']?.toString() ??
            'Failed to initialize payment',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> verifyPayment({
    required String transactionUUID,
    required double amount,
    required String transactionCode,
    Map<String, dynamic>? callbackData,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.processBookingPayment(transactionUUID),
        data: {
          'amount': amount,
          'transactionCode': transactionCode,
          if (callbackData != null) 'esewaCallbackData': callbackData,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }
      throw ServerException(
        response.data['message']?.toString() ?? 'Payment verification failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (EsewaConfig.allowLegacyApiFallback && e.response?.statusCode == 404) {
        final fallbackResponse = await apiClient.dio.post(
          ApiEndpoints.paymentVerify,
          data: {
            'transactionUUID': transactionUUID,
            'amount': amount,
            'transactionCode': transactionCode,
            if (callbackData != null) 'esewaCallbackData': callbackData,
          },
        );

        if (fallbackResponse.statusCode == 200 ||
            fallbackResponse.statusCode == 201) {
          return;
        }
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(message: 'Payment verification timed out');
      }

      if (e.response?.statusCode == 401) {
        throw AuthException(message: 'Unauthorized. Please login again.');
      }

      throw ServerException(
        e.response?.data['message']?.toString() ??
            'Payment verification failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<TransactionModel>> fetchPaymentHistory() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.sentTransactions);

      if (response.statusCode == 200) {
        return _extractTransactions(response.data);
      }

      throw ServerException(
        response.data['message']?.toString() ??
            'Failed to fetch payment history',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (EsewaConfig.allowLegacyApiFallback && e.response?.statusCode == 404) {
        final fallbackResponse = await apiClient.dio.get(
          ApiEndpoints.paymentHistory,
        );
        if (fallbackResponse.statusCode == 200) {
          return _extractTransactions(fallbackResponse.data);
        }
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(message: 'Fetching payment history timed out');
      }

      if (e.response?.statusCode == 401) {
        throw AuthException(message: 'Unauthorized. Please login again.');
      }

      throw ServerException(
        e.response?.data['message']?.toString() ??
            'Failed to fetch payment history',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<TransactionModel>> fetchReceivedHistory() async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.receivedTransactions,
      );

      if (response.statusCode == 200) {
        return _extractTransactions(response.data);
      }

      throw ServerException(
        response.data['message']?.toString() ??
            'Failed to fetch received transactions',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          message: 'Fetching received transactions timed out',
        );
      }

      if (e.response?.statusCode == 401) {
        throw AuthException(message: 'Unauthorized. Please login again.');
      }

      throw ServerException(
        e.response?.data['message']?.toString() ??
            'Failed to fetch received transactions',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
