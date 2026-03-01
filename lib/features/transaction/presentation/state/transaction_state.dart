import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

enum PaymentFlowStatus {
  initial,
  initiating,
  redirecting,
  verifying,
  success,
  failure,
  error,
}

class TransactionState extends Equatable {
  final PaymentFlowStatus flowStatus;
  final String? error;
  final String? statusMessage;
  final List<TransactionEntity> sentTransactions;
  final List<TransactionEntity> receivedTransactions;
  final List<TransactionEntity> paymentHistory;
  final PaymentInitEntity? paymentInit;
  final bool paymentProcessed;
  final Map<String, dynamic>? lastCallbackData;

  const TransactionState({
    this.flowStatus = PaymentFlowStatus.initial,
    this.error,
    this.statusMessage,
    this.sentTransactions = const [],
    this.receivedTransactions = const [],
    this.paymentHistory = const [],
    this.paymentInit,
    this.paymentProcessed = false,
    this.lastCallbackData,
  });

  bool get isLoading =>
      flowStatus == PaymentFlowStatus.initiating ||
      flowStatus == PaymentFlowStatus.redirecting ||
      flowStatus == PaymentFlowStatus.verifying;

  TransactionState copyWith({
    PaymentFlowStatus? flowStatus,
    String? error,
    String? statusMessage,
    List<TransactionEntity>? sentTransactions,
    List<TransactionEntity>? receivedTransactions,
    List<TransactionEntity>? paymentHistory,
    PaymentInitEntity? paymentInit,
    bool? paymentProcessed,
    Map<String, dynamic>? lastCallbackData,
  }) {
    return TransactionState(
      flowStatus: flowStatus ?? this.flowStatus,
      error: error,
      statusMessage: statusMessage ?? this.statusMessage,
      sentTransactions: sentTransactions ?? this.sentTransactions,
      receivedTransactions: receivedTransactions ?? this.receivedTransactions,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      paymentInit: paymentInit ?? this.paymentInit,
      paymentProcessed: paymentProcessed ?? this.paymentProcessed,
      lastCallbackData: lastCallbackData ?? this.lastCallbackData,
    );
  }

  @override
  List<Object?> get props => [
    flowStatus,
    error,
    statusMessage,
    sentTransactions,
    receivedTransactions,
    paymentHistory,
    paymentInit,
    paymentProcessed,
    lastCallbackData,
  ];
}
