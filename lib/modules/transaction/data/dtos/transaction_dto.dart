import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/enums/reference_type.dart';
import '../../domain/enums/transaction_status.dart';

part 'transaction_dto.g.dart';

/// Data Transfer Object for Transaction API responses.
/// Handles serialization/deserialization with the backend.
@JsonSerializable(explicitToJson: true)
class TransactionDto {
  const TransactionDto({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.referenceId,
    required this.referenceType,
    required this.totalAmount,
    required this.commissionAmount,
    required this.receiverAmount,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
    this.paymentGatewayTransactionId,
    this.notes,
  });

  @JsonKey(name: 'id')
  final String id;

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

  @JsonKey(name: 'commission_amount')
  final double commissionAmount;

  @JsonKey(name: 'receiver_amount')
  final double receiverAmount;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'completed_at')
  final String? completedAt;

  @JsonKey(name: 'failure_reason')
  final String? failureReason;

  @JsonKey(name: 'payment_gateway_transaction_id')
  final String? paymentGatewayTransactionId;

  @JsonKey(name: 'notes')
  final String? notes;

  factory TransactionDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionDtoToJson(this);

  /// Convert DTO to domain entity
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      referenceId: referenceId,
      referenceType: ReferenceType.fromString(referenceType),
      totalAmount: totalAmount,
      commissionAmount: commissionAmount,
      receiverAmount: receiverAmount,
      status: TransactionStatus.fromString(status),
      createdAt: DateTime.parse(createdAt),
      completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
      failureReason: failureReason,
      paymentGatewayTransactionId: paymentGatewayTransactionId,
      notes: notes,
    );
  }

  /// Create DTO from domain entity
  factory TransactionDto.fromEntity(TransactionEntity entity) {
    return TransactionDto(
      id: entity.id,
      senderId: entity.senderId,
      receiverId: entity.receiverId,
      referenceId: entity.referenceId,
      referenceType: entity.referenceType.value,
      totalAmount: entity.totalAmount,
      commissionAmount: entity.commissionAmount,
      receiverAmount: entity.receiverAmount,
      status: entity.status.value,
      createdAt: entity.createdAt.toIso8601String(),
      completedAt: entity.completedAt?.toIso8601String(),
      failureReason: entity.failureReason,
      paymentGatewayTransactionId: entity.paymentGatewayTransactionId,
      notes: entity.notes,
    );
  }
}
