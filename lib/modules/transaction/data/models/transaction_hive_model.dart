import 'package:hive/hive.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/enums/reference_type.dart';
import '../../domain/enums/transaction_status.dart';

part 'transaction_hive_model.g.dart';

/// Hive model for local storage of transaction data.
/// Includes caching metadata for efficient data management.
@HiveType(typeId: 2) // Make sure this doesn't conflict with other models
class TransactionHiveModel {
  TransactionHiveModel({
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
    DateTime? cachedAt,
  }) : cachedAt = cachedAt ?? DateTime.now();

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String senderId;

  @HiveField(2)
  final String receiverId;

  @HiveField(3)
  final String referenceId;

  @HiveField(4)
  final String referenceType;

  @HiveField(5)
  final double totalAmount;

  @HiveField(6)
  final double commissionAmount;

  @HiveField(7)
  final double receiverAmount;

  @HiveField(8)
  final String status;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime? completedAt;

  @HiveField(11)
  final String? failureReason;

  @HiveField(12)
  final String? paymentGatewayTransactionId;

  @HiveField(13)
  final String? notes;

  @HiveField(14)
  DateTime cachedAt;

  /// Default cache expiration duration (1 hour)
  static const Duration defaultCacheExpiration = Duration(hours: 1);

  /// Check if the cached data has expired
  bool isExpired([Duration? expiration]) {
    final expirationDuration = expiration ?? defaultCacheExpiration;
    return DateTime.now().difference(cachedAt) > expirationDuration;
  }

  /// Update cache timestamp
  void updateCacheTimestamp() {
    cachedAt = DateTime.now();
  }

  /// Convert Hive model to domain entity
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
      createdAt: createdAt,
      completedAt: completedAt,
      failureReason: failureReason,
      paymentGatewayTransactionId: paymentGatewayTransactionId,
      notes: notes,
    );
  }

  /// Create Hive model from domain entity
  factory TransactionHiveModel.fromEntity(TransactionEntity entity) {
    return TransactionHiveModel(
      id: entity.id,
      senderId: entity.senderId,
      receiverId: entity.receiverId,
      referenceId: entity.referenceId,
      referenceType: entity.referenceType.value,
      totalAmount: entity.totalAmount,
      commissionAmount: entity.commissionAmount,
      receiverAmount: entity.receiverAmount,
      status: entity.status.value,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
      failureReason: entity.failureReason,
      paymentGatewayTransactionId: entity.paymentGatewayTransactionId,
      notes: entity.notes,
    );
  }

  /// Copy with method for immutable updates
  TransactionHiveModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? referenceId,
    String? referenceType,
    double? totalAmount,
    double? commissionAmount,
    double? receiverAmount,
    String? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? failureReason,
    String? paymentGatewayTransactionId,
    String? notes,
    DateTime? cachedAt,
  }) {
    return TransactionHiveModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      totalAmount: totalAmount ?? this.totalAmount,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      receiverAmount: receiverAmount ?? this.receiverAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
      paymentGatewayTransactionId:
          paymentGatewayTransactionId ?? this.paymentGatewayTransactionId,
      notes: notes ?? this.notes,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }
}
