// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_transaction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTransactionDto _$CreateTransactionDtoFromJson(
        Map<String, dynamic> json) =>
    CreateTransactionDto(
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      referenceId: json['reference_id'] as String,
      referenceType: json['reference_type'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      commissionRate: (json['commission_rate'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CreateTransactionDtoToJson(
        CreateTransactionDto instance) =>
    <String, dynamic>{
      'sender_id': instance.senderId,
      'receiver_id': instance.receiverId,
      'reference_id': instance.referenceId,
      'reference_type': instance.referenceType,
      'total_amount': instance.totalAmount,
      'commission_rate': instance.commissionRate,
      'notes': instance.notes,
    };
