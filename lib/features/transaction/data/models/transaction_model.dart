import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    super.jobId,
    super.bookingId,
    required super.senderId,
    required super.receiverId,
    super.senderName,
    super.receiverName,
    super.senderEmail,
    super.receiverEmail,
    super.senderImage,
    super.receiverImage,
    required super.amount,
    super.commission,
    super.receiverAmount,
    required super.productCode,
    required super.transactionUuid,
    super.transactionCode,
    required super.status,
    super.bookingStartTime,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Parse sender (can be object or string)
    String senderId = '';
    String? senderName;
    String? senderEmail;
    String? senderImage;
    if (json['sender'] is Map) {
      final s = json['sender'] as Map<String, dynamic>;
      senderId = s['_id']?.toString() ?? s['id']?.toString() ?? '';
      senderName = s['fullName']?.toString() ?? s['name']?.toString();
      senderEmail = s['email']?.toString();
      senderImage = s['profileImage']?.toString();
    } else {
      senderId = json['sender']?.toString() ?? '';
    }

    // Parse receiver (can be object or string)
    String receiverId = '';
    String? receiverName;
    String? receiverEmail;
    String? receiverImage;
    if (json['receiver'] is Map) {
      final r = json['receiver'] as Map<String, dynamic>;
      receiverId = r['_id']?.toString() ?? r['id']?.toString() ?? '';
      receiverName = r['fullName']?.toString() ?? r['name']?.toString();
      receiverEmail = r['email']?.toString();
      receiverImage = r['profileImage']?.toString();
    } else {
      receiverId = json['receiver']?.toString() ?? '';
    }

    // Parse booking for startTime
    DateTime? bookingStartTime;
    String? bookingId;
    if (json['booking'] is Map) {
      final b = json['booking'] as Map<String, dynamic>;
      bookingId = b['_id']?.toString() ?? b['id']?.toString();
      bookingStartTime = DateTime.tryParse(b['startTime']?.toString() ?? '');
    } else if (json['booking'] != null) {
      bookingId = json['booking'].toString();
    }

    // Parse job
    String? jobId;
    if (json['job'] is Map) {
      jobId = (json['job'] as Map<String, dynamic>)['_id']?.toString();
    } else if (json['job'] != null) {
      jobId = json['job'].toString();
    }

    return TransactionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      jobId: jobId,
      bookingId: bookingId,
      senderId: senderId,
      receiverId: receiverId,
      senderName: senderName,
      receiverName: receiverName,
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
      senderImage: senderImage,
      receiverImage: receiverImage,
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      commission: (json['commission'] is num) ? (json['commission'] as num).toDouble() : 0.0,
      receiverAmount: (json['receiverAmount'] is num) ? (json['receiverAmount'] as num).toDouble() : 0.0,
      productCode: json['productCode']?.toString() ?? 'EPAYTEST',
      transactionUuid: json['transactionUuid']?.toString() ?? '',
      transactionCode: json['transactionCode']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      bookingStartTime: bookingStartTime,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class PaymentInitModel extends PaymentInitEntity {
  const PaymentInitModel({
    required super.transactionId,
    required super.amount,
    required super.productCode,
    required super.transactionUuid,
    required super.successUrl,
    required super.failureUrl,
  });

  factory PaymentInitModel.fromJson(Map<String, dynamic> json) {
    return PaymentInitModel(
      transactionId: json['transactionId']?.toString() ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      productCode: json['product_code']?.toString() ?? 'EPAYTEST',
      transactionUuid: json['transaction_uuid']?.toString() ?? '',
      successUrl: json['success_url']?.toString() ?? '',
      failureUrl: json['failure_url']?.toString() ?? '',
    );
  }
}
