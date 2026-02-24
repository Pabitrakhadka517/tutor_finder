import '../enums/reference_type.dart';
import '../enums/transaction_status.dart';

/// Core transaction entity containing all business rules and logic.
/// Represents a payment transaction between a student and tutor.
class TransactionEntity {
  const TransactionEntity({
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

  final String id;
  final String senderId;
  final String receiverId;
  final String referenceId; // bookingId or jobId
  final ReferenceType referenceType;
  final double totalAmount;
  final double commissionAmount;
  final double receiverAmount;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;
  final String? paymentGatewayTransactionId;
  final String? notes;

  // ── Business Rules & Calculations ──────────────────────────────────────

  /// Default platform commission rate (10%)
  static const double defaultCommissionRate = 0.10;

  /// Calculate commission amount based on total amount and rate
  static double calculateCommission(
    double totalAmount, [
    double rate = defaultCommissionRate,
  ]) {
    if (totalAmount < 0) {
      throw ArgumentError('Total amount cannot be negative');
    }
    if (rate < 0 || rate > 1) {
      throw ArgumentError('Commission rate must be between 0 and 1');
    }
    return totalAmount * rate;
  }

  /// Calculate receiver amount after commission
  static double calculateReceiverAmount(
    double totalAmount, [
    double rate = defaultCommissionRate,
  ]) {
    return totalAmount - calculateCommission(totalAmount, rate);
  }

  /// Create a new transaction with calculated commission
  static TransactionEntity createNew({
    required String id,
    required String senderId,
    required String receiverId,
    required String referenceId,
    required ReferenceType referenceType,
    required double totalAmount,
    double commissionRate = defaultCommissionRate,
    String? notes,
  }) {
    if (totalAmount <= 0) {
      throw ArgumentError('Total amount must be greater than 0');
    }

    final commission = calculateCommission(totalAmount, commissionRate);
    final receiverAmount = totalAmount - commission;

    return TransactionEntity(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      referenceId: referenceId,
      referenceType: referenceType,
      totalAmount: totalAmount,
      commissionAmount: commission,
      receiverAmount: receiverAmount,
      status: TransactionStatus.pending,
      createdAt: DateTime.now(),
      notes: notes,
    );
  }

  /// Check if status transition is valid
  bool canTransitionTo(TransactionStatus newStatus) {
    return status.canTransitionTo(newStatus);
  }

  /// Check if transaction is pending
  bool get isPending => status == TransactionStatus.pending;

  /// Check if transaction is being processed
  bool get isProcessing => status == TransactionStatus.processing;

  /// Check if transaction is completed
  bool get isCompleted => status == TransactionStatus.completed;

  /// Check if transaction has failed
  bool get hasFailed => status == TransactionStatus.failed;

  /// Check if transaction is cancelled
  bool get isCancelled => status == TransactionStatus.cancelled;

  /// Check if transaction can be processed
  bool get isProcessable => isPending || hasFailed;

  /// Check if transaction is in a terminal state
  bool get isTerminal => status.isTerminal;

  /// Validate if transaction can be processed
  bool validateProcessable() {
    if (!isProcessable) {
      return false;
    }
    if (totalAmount <= 0) {
      return false;
    }
    if (senderId == receiverId) {
      return false;
    }
    return true;
  }

  /// Mark transaction as completed
  TransactionEntity markCompleted({String? paymentGatewayTransactionId}) {
    if (!canTransitionTo(TransactionStatus.completed)) {
      throw StateError(
        'Cannot mark transaction as completed from status: $status',
      );
    }

    return copyWith(
      status: TransactionStatus.completed,
      completedAt: DateTime.now(),
      paymentGatewayTransactionId: paymentGatewayTransactionId,
      failureReason: null, // Clear any previous failure
    );
  }

  /// Mark transaction as failed
  TransactionEntity markFailed(String reason) {
    if (!canTransitionTo(TransactionStatus.failed)) {
      throw StateError(
        'Cannot mark transaction as failed from status: $status',
      );
    }

    return copyWith(status: TransactionStatus.failed, failureReason: reason);
  }

  /// Mark transaction as processing
  TransactionEntity markProcessing() {
    if (!canTransitionTo(TransactionStatus.processing)) {
      throw StateError(
        'Cannot mark transaction as processing from status: $status',
      );
    }

    return copyWith(status: TransactionStatus.processing);
  }

  /// Mark transaction as cancelled
  TransactionEntity cancel() {
    if (!canTransitionTo(TransactionStatus.cancelled)) {
      throw StateError('Cannot cancel transaction from status: $status');
    }

    return copyWith(status: TransactionStatus.cancelled);
  }

  /// Check if this is a booking transaction
  bool get isBookingTransaction => referenceType == ReferenceType.booking;

  /// Check if this is a job transaction
  bool get isJobTransaction => referenceType == ReferenceType.job;

  /// Get transaction age in hours
  double get ageInHours {
    return DateTime.now().difference(createdAt).inHours.toDouble();
  }

  /// Get processing duration (if completed)
  Duration? get processingDuration {
    if (completedAt != null) {
      return completedAt!.difference(createdAt);
    }
    return null;
  }

  /// Copy with method for immutable updates
  TransactionEntity copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? referenceId,
    ReferenceType? referenceType,
    double? totalAmount,
    double? commissionAmount,
    double? receiverAmount,
    TransactionStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? failureReason,
    String? paymentGatewayTransactionId,
    String? notes,
  }) {
    return TransactionEntity(
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
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TransactionEntity &&
            runtimeType == other.runtimeType &&
            id == other.id);
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TransactionEntity(id: $id, status: $status, amount: $totalAmount)';
  }
}
