import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<TransactionEntity> sentTransactions;
  final List<TransactionEntity> receivedTransactions;
  final PaymentInitEntity? paymentInit;
  final bool paymentProcessed;

  const TransactionState({
    this.isLoading = false,
    this.error,
    this.sentTransactions = const [],
    this.receivedTransactions = const [],
    this.paymentInit,
    this.paymentProcessed = false,
  });

  TransactionState copyWith({
    bool? isLoading,
    String? error,
    List<TransactionEntity>? sentTransactions,
    List<TransactionEntity>? receivedTransactions,
    PaymentInitEntity? paymentInit,
    bool? paymentProcessed,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sentTransactions: sentTransactions ?? this.sentTransactions,
      receivedTransactions: receivedTransactions ?? this.receivedTransactions,
      paymentInit: paymentInit ?? this.paymentInit,
      paymentProcessed: paymentProcessed ?? this.paymentProcessed,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        sentTransactions,
        receivedTransactions,
        paymentInit,
        paymentProcessed,
      ];
}
