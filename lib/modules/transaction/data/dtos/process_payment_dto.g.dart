// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'process_payment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProcessPaymentDto _$ProcessPaymentDtoFromJson(Map<String, dynamic> json) =>
    ProcessPaymentDto(
      transactionId: json['transaction_id'] as String,
      paymentMethodId: json['payment_method_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ProcessPaymentDtoToJson(ProcessPaymentDto instance) =>
    <String, dynamic>{
      'transaction_id': instance.transactionId,
      'payment_method_id': instance.paymentMethodId,
      'metadata': instance.metadata,
    };
