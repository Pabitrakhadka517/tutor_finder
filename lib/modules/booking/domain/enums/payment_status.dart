/// Payment status enumeration for tracking payment state.
enum PaymentStatus {
  /// Payment has not been made
  unpaid('UNPAID'),

  /// Payment has been completed successfully
  paid('PAID'),

  /// Payment has been refunded
  refunded('REFUNDED'),

  /// Payment is being processed
  processing('PROCESSING'),

  /// Payment failed
  failed('FAILED');

  const PaymentStatus(this.value);

  final String value;

  /// Valid payment transitions
  static const Map<PaymentStatus, List<PaymentStatus>> _transitions = {
    PaymentStatus.unpaid: [
      PaymentStatus.processing,
      PaymentStatus.paid,
      PaymentStatus.failed,
    ],
    PaymentStatus.processing: [PaymentStatus.paid, PaymentStatus.failed],
    PaymentStatus.paid: [PaymentStatus.refunded],
    PaymentStatus.failed: [PaymentStatus.processing, PaymentStatus.paid],
    PaymentStatus.refunded: [], // Terminal state
  };

  /// Check if transition to new payment status is valid
  bool canTransitionTo(PaymentStatus newStatus) {
    return _transitions[this]?.contains(newStatus) ?? false;
  }

  /// Check if payment is successful
  bool get isSuccessful => this == PaymentStatus.paid;

  /// Check if payment is pending
  bool get isPending =>
      this == PaymentStatus.unpaid || this == PaymentStatus.processing;

  /// Check if payment failed
  bool get isFailed => this == PaymentStatus.failed;

  /// Check if payment can be refunded
  bool get canBeRefunded => this == PaymentStatus.paid;

  /// Get status from string value
  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Invalid payment status: $value'),
    );
  }

  @override
  String toString() => value;
}
