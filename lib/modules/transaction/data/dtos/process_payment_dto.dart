import 'package:json_annotation/json_annotation.dart';

part 'process_payment_dto.g.dart';

/// Data Transfer Object for processing a payment.
/// Used for API requests to process transaction payments.
@JsonSerializable()
class ProcessPaymentDto {
  const ProcessPaymentDto({
    required this.transactionId,
    this.paymentMethodId,
    this.metadata,
  });

  @JsonKey(name: 'transaction_id')
  final String transactionId;

  @JsonKey(name: 'payment_method_id')
  final String? paymentMethodId;

  @JsonKey(name: 'metadata')
  final Map<String, dynamic>? metadata;

  factory ProcessPaymentDto.fromJson(Map<String, dynamic> json) =>
      _$ProcessPaymentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProcessPaymentDtoToJson(this);
}
