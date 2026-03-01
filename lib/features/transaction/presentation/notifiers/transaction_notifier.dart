import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/payment_usecases.dart';
import '../state/transaction_state.dart';

class TransactionNotifier extends StateNotifier<TransactionState> {
  final InitializePaymentUseCase initializePaymentUseCase;
  final VerifyPaymentUseCase verifyPaymentUseCase;
  final FetchPaymentHistoryUseCase fetchPaymentHistoryUseCase;
  final FetchReceivedTransactionsUseCase fetchReceivedTransactionsUseCase;

  TransactionNotifier({
    required this.initializePaymentUseCase,
    required this.verifyPaymentUseCase,
    required this.fetchPaymentHistoryUseCase,
    required this.fetchReceivedTransactionsUseCase,
  }) : super(const TransactionState());

  /// Initialize payment and get signed eSewa payload from backend.
  Future<bool> initBookingPayment(String bookingId) async {
    state = state.copyWith(
      flowStatus: PaymentFlowStatus.initiating,
      error: null,
      statusMessage: null,
      paymentProcessed: false,
    );
    debugPrint('[PaymentAudit] init start bookingId=$bookingId');

    final result = await initializePaymentUseCase(
      InitializePaymentParams(bookingId: bookingId),
    );

    return result.fold(
      (failure) {
        debugPrint('[PaymentAudit] init failed message=${failure.message}');
        state = state.copyWith(
          flowStatus: PaymentFlowStatus.error,
          error: failure.message,
        );
        return false;
      },
      (paymentInit) {
        debugPrint(
          '[PaymentAudit] init success txUUID=${paymentInit.transactionUuid} amount=${paymentInit.amount}',
        );
        state = state.copyWith(
          flowStatus: PaymentFlowStatus.redirecting,
          paymentInit: paymentInit,
          statusMessage: 'Payment initialized',
        );
        return true;
      },
    );
  }

  /// Verify payment callback with backend before marking success.
  Future<bool> verifyBookingPayment({
    required String transactionUUID,
    required double amount,
    required String transactionCode,
    Map<String, dynamic>? callbackData,
  }) async {
    state = state.copyWith(
      flowStatus: PaymentFlowStatus.verifying,
      error: null,
      statusMessage: 'Verifying payment...',
      lastCallbackData: callbackData,
    );
    debugPrint(
      '[PaymentAudit] verify start txUUID=$transactionUUID amount=$amount code=$transactionCode',
    );

    final result = await verifyPaymentUseCase(
      VerifyPaymentParams(
        transactionUUID: transactionUUID,
        amount: amount,
        transactionCode: transactionCode,
        callbackData: callbackData,
      ),
    );

    return result.fold(
      (failure) {
        debugPrint('[PaymentAudit] verify failed message=${failure.message}');
        state = state.copyWith(
          flowStatus: PaymentFlowStatus.failure,
          error: failure.message,
          statusMessage: 'Payment verification failed',
          paymentProcessed: false,
        );
        return false;
      },
      (_) {
        debugPrint('[PaymentAudit] verify success txUUID=$transactionUUID');
        state = state.copyWith(
          flowStatus: PaymentFlowStatus.success,
          paymentProcessed: true,
          statusMessage: 'Payment verified successfully',
        );
        return true;
      },
    );
  }

  /// Parse callback payload from URI query params.
  /// First tries `data` (base64 JSON), then falls back to direct query params.
  Map<String, dynamic> parseCallbackPayload(Map<String, String> queryParams) {
    try {
      if (queryParams['data'] != null && queryParams['data']!.isNotEmpty) {
        final decoded = utf8.decode(base64.decode(queryParams['data']!));
        final jsonData = jsonDecode(decoded);
        if (jsonData is Map<String, dynamic>) {
          debugPrint('[PaymentAudit] callback parsed via data payload');
          return jsonData;
        }
      }
    } catch (e) {
      debugPrint('[PaymentAudit] callback data param parse failed: $e');
    }

    final fallback = <String, dynamic>{
      for (final entry in queryParams.entries) entry.key: entry.value,
    };
    debugPrint('[PaymentAudit] callback parsed via direct query params');
    return fallback;
  }

  Future<void> fetchSentTransactions() async {
    state = state.copyWith(
      flowStatus: PaymentFlowStatus.initiating,
      error: null,
    );

    final result = await fetchPaymentHistoryUseCase(const NoParams());
    result.fold(
      (failure) {
        state = state.copyWith(
          flowStatus: PaymentFlowStatus.error,
          error: failure.message,
        );
      },
      (transactions) {
        state = state.copyWith(
          flowStatus: PaymentFlowStatus.initial,
          sentTransactions: transactions,
          paymentHistory: transactions,
        );
      },
    );
  }

  Future<void> fetchReceivedTransactions() async {
    state = state.copyWith(
      flowStatus: PaymentFlowStatus.initiating,
      error: null,
    );

    final result = await fetchReceivedTransactionsUseCase(const NoParams());
    result.fold(
      (failure) {
        state = state.copyWith(
          flowStatus: PaymentFlowStatus.error,
          error: failure.message,
        );
      },
      (transactions) {
        state = state.copyWith(
          flowStatus: PaymentFlowStatus.initial,
          receivedTransactions: transactions,
        );
      },
    );
  }

  Future<bool> processBookingPayment({
    required String transactionId,
    required String transactionCode,
    Map<String, dynamic>? esewaCallbackData,
  }) {
    return verifyBookingPayment(
      transactionUUID: transactionId,
      amount: state.paymentInit?.amount ?? 0,
      transactionCode: transactionCode,
      callbackData: esewaCallbackData,
    );
  }

  void clearPaymentState() {
    state = const TransactionState();
  }
}
