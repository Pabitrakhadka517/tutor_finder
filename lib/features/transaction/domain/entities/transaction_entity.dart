import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String bookingId;
  final String tutorId;
  final double amount;
  final String transactionId;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.bookingId,
    required this.tutorId,
    required this.amount,
    required this.transactionId,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'done' || status == 'completed';
  bool get isFailed => status == 'failed';

  @override
  List<Object?> get props => [
    id,
    bookingId,
    tutorId,
    amount,
    transactionId,
    status,
    paymentMethod,
    createdAt,
  ];
}

/// Payment init details returned from backend for eSewa
class PaymentInitEntity extends Equatable {
  final String transactionId;
  final String bookingId;
  final String tutorId;
  final double amount;
  final String productCode;
  final String transactionUuid;
  final String signedFieldNames;
  final String signature;
  final String successUrl;
  final String failureUrl;
  final String paymentMethod;

  const PaymentInitEntity({
    required this.transactionId,
    required this.bookingId,
    required this.tutorId,
    required this.amount,
    required this.productCode,
    required this.transactionUuid,
    required this.signedFieldNames,
    required this.signature,
    required this.successUrl,
    required this.failureUrl,
    this.paymentMethod = 'eSewa',
  });

  @override
  List<Object?> get props => [
    transactionId,
    bookingId,
    tutorId,
    transactionUuid,
    amount,
    productCode,
    signedFieldNames,
    signature,
    successUrl,
    failureUrl,
    paymentMethod,
  ];
}
