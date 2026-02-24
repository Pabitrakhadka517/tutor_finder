// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionDto _$TransactionDtoFromJson(Map<String, dynamic> json) =>
    TransactionDto(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      referenceId: json['reference_id'] as String,
      referenceType: json['reference_type'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      commissionAmount: (json['commission_amount'] as num).toDouble(),
      receiverAmount: (json['receiver_amount'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      completedAt: json['completed_at'] as String?,
      failureReason: json['failure_reason'] as String?,
      paymentGatewayTransactionId:
          json['payment_gateway_transaction_id'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$TransactionDtoToJson(TransactionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender_id': instance.senderId,
      'receiver_id': instance.receiverId,
      'reference_id': instance.referenceId,
      'reference_type': instance.referenceType,
      'total_amount': instance.totalAmount,
      'commission_amount': instance.commissionAmount,
      'receiver_amount': instance.receiverAmount,
      'status': instance.status,
      'created_at': instance.createdAt,
      'completed_at': instance.completedAt,
      'failure_reason': instance.failureReason,
      'payment_gateway_transaction_id': instance.paymentGatewayTransactionId,
      'notes': instance.notes,
    };
