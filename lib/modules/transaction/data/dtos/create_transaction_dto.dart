import 'package:json_annotation/json_annotation.dart';

part 'create_transaction_dto.g.dart';

/// Data Transfer Object for creating a new transaction.
/// Used for API requests to create transactions.
@JsonSerializable()
class CreateTransactionDto {
  const CreateTransactionDto({
    required this.senderId,
    required this.receiverId,
    required this.referenceId,
    required this.referenceType,
    required this.totalAmount,
    this.commissionRate,
    this.notes,
  });

  @JsonKey(name: 'sender_id')
  final String senderId;

  @JsonKey(name: 'receiver_id')
  final String receiverId;

  @JsonKey(name: 'reference_id')
  final String referenceId;

  @JsonKey(name: 'reference_type')
  final String referenceType;

  @JsonKey(name: 'total_amount')
  final double totalAmount;

  @JsonKey(name: 'commission_rate')
  final double? commissionRate;

  @JsonKey(name: 'notes')
  final String? notes;

  factory CreateTransactionDto.fromJson(Map<String, dynamic> json) =>
      _$CreateTransactionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTransactionDtoToJson(this);
}
