import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.bookingId,
    required super.tutorId,
    required super.amount,
    required super.transactionId,
    required super.status,
    required super.paymentMethod,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    String bookingId = '';
    String tutorId = '';

    if (json['booking'] is Map) {
      final b = json['booking'] as Map<String, dynamic>;
      bookingId = b['_id']?.toString() ?? b['id']?.toString() ?? '';
    } else if (json['booking'] != null) {
      bookingId = json['booking'].toString();
    }

    if (json['tutor'] is Map) {
      final t = json['tutor'] as Map<String, dynamic>;
      tutorId = t['_id']?.toString() ?? t['id']?.toString() ?? '';
    } else if (json['receiver'] is Map) {
      final receiver = json['receiver'] as Map<String, dynamic>;
      tutorId = receiver['_id']?.toString() ?? receiver['id']?.toString() ?? '';
    } else {
      tutorId =
          json['tutorId']?.toString() ?? json['receiver']?.toString() ?? '';
    }

    return TransactionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      bookingId: bookingId,
      tutorId: tutorId,
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      transactionId:
          json['transactionId']?.toString() ??
          json['transactionUuid']?.toString() ??
          json['transaction_uuid']?.toString() ??
          json['_id']?.toString() ??
          '',
      status: json['status']?.toString() ?? 'pending',
      paymentMethod:
          json['paymentMethod']?.toString() ??
          json['method']?.toString() ??
          'eSewa',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class PaymentInitModel extends PaymentInitEntity {
  const PaymentInitModel({
    required super.transactionId,
    required super.bookingId,
    required super.tutorId,
    required super.amount,
    required super.productCode,
    required super.transactionUuid,
    required super.signedFieldNames,
    required super.signature,
    required super.successUrl,
    required super.failureUrl,
    super.paymentMethod,
  });

  factory PaymentInitModel.fromJson(Map<String, dynamic> json) {
    final payload = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return PaymentInitModel(
      transactionId:
          payload['id']?.toString() ??
          payload['transactionId']?.toString() ??
          payload['transaction_id']?.toString() ??
          '',
      bookingId: payload['bookingId']?.toString() ?? '',
      tutorId: payload['tutorId']?.toString() ?? '',
      amount: (payload['amount'] is num)
          ? (payload['amount'] as num).toDouble()
          : (payload['total_amount'] is num)
          ? (payload['total_amount'] as num).toDouble()
          : (payload['tAmt'] is num)
          ? (payload['tAmt'] as num).toDouble()
          : double.tryParse(payload['amount']?.toString() ?? '0') ?? 0.0,
      productCode:
          payload['productCode']?.toString() ??
          payload['product_code']?.toString() ??
          payload['scd']?.toString() ??
          '',
      transactionUuid:
          payload['transactionUUID']?.toString() ??
          payload['transaction_uuid']?.toString() ??
          payload['transactionUuid']?.toString() ??
          payload['pid']?.toString() ??
          payload['transactionId']?.toString() ??
          '',
      signedFieldNames:
          payload['signedFieldNames']?.toString() ??
          payload['signed_field_names']?.toString() ??
          'total_amount,transaction_uuid,product_code',
      signature: payload['signature']?.toString() ?? '',
      successUrl:
          payload['successUrl']?.toString() ??
          payload['success_url']?.toString() ??
          payload['su']?.toString() ??
          '',
      failureUrl:
          payload['failureUrl']?.toString() ??
          payload['failure_url']?.toString() ??
          payload['fu']?.toString() ??
          '',
      paymentMethod:
          payload['paymentMethod']?.toString() ??
          payload['method']?.toString() ??
          'eSewa',
    );
  }
}
