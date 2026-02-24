import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String? jobId;
  final String? bookingId;
  final String senderId;
  final String receiverId;
  final String? senderName;
  final String? receiverName;
  final String? senderEmail;
  final String? receiverEmail;
  final String? senderImage;
  final String? receiverImage;
  final double amount;
  final double commission;
  final double receiverAmount;
  final String productCode;
  final String transactionUuid;
  final String? transactionCode;
  final String status; // pending, done/completed, failed
  final DateTime? bookingStartTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionEntity({
    required this.id,
    this.jobId,
    this.bookingId,
    required this.senderId,
    required this.receiverId,
    this.senderName,
    this.receiverName,
    this.senderEmail,
    this.receiverEmail,
    this.senderImage,
    this.receiverImage,
    required this.amount,
    this.commission = 0,
    this.receiverAmount = 0,
    required this.productCode,
    required this.transactionUuid,
    this.transactionCode,
    required this.status,
    this.bookingStartTime,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'done' || status == 'completed';
  bool get isFailed => status == 'failed';

  @override
  List<Object?> get props => [id, status, amount, transactionUuid];
}

/// Payment init details returned from backend for eSewa
class PaymentInitEntity extends Equatable {
  final String transactionId;
  final double amount;
  final String productCode;
  final String transactionUuid;
  final String successUrl;
  final String failureUrl;

  const PaymentInitEntity({
    required this.transactionId,
    required this.amount,
    required this.productCode,
    required this.transactionUuid,
    required this.successUrl,
    required this.failureUrl,
  });

  @override
  List<Object?> get props => [transactionId, transactionUuid, amount];
}
