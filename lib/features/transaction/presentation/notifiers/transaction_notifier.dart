import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/transaction_repository.dart';
import '../state/transaction_state.dart';

class TransactionNotifier extends StateNotifier<TransactionState> {
  final TransactionRepository repository;

  TransactionNotifier({required this.repository})
    : super(const TransactionState());

  /// Init booking payment - get eSewa payment details
  Future<bool> initBookingPayment(String bookingId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      paymentProcessed: false,
    );

    final result = await repository.initBookingPayment(bookingId);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (paymentInit) {
        state = state.copyWith(isLoading: false, paymentInit: paymentInit);
        return true;
      },
    );
  }

  /// Process/verify payment after eSewa callback
  Future<bool> processBookingPayment({
    required String transactionId,
    required String transactionCode,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.processBookingPayment(
      transactionId: transactionId,
      transactionCode: transactionCode,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, paymentProcessed: true);
        return true;
      },
    );
  }

  /// Fetch sent transactions (payments made)
  Future<void> fetchSentTransactions() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.getSentTransactions();
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (transactions) => state = state.copyWith(
        isLoading: false,
        sentTransactions: transactions,
      ),
    );
  }

  /// Fetch received transactions (income)
  Future<void> fetchReceivedTransactions() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.getReceivedTransactions();
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (transactions) => state = state.copyWith(
        isLoading: false,
        receivedTransactions: transactions,
      ),
    );
  }

  void clearPaymentState() {
    state = state.copyWith(paymentProcessed: false);
  }
}
