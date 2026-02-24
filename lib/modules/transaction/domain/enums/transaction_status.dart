/// Transaction status enumeration representing all possible transaction states.
/// Follows state machine pattern for valid transitions.
enum TransactionStatus {
  /// Initial state - transaction created but payment not yet processed
  pending('PENDING'),

  /// Payment is being processed by payment gateway
  processing('PROCESSING'),

  /// Payment completed successfully
  completed('COMPLETED'),

  /// Payment failed due to payment gateway issues
  failed('FAILED'),

  /// Transaction cancelled before completion
  cancelled('CANCELLED');

  const TransactionStatus(this.value);

  final String value;

  /// Valid state transitions based on business rules
  static const Map<TransactionStatus, List<TransactionStatus>> _transitions = {
    TransactionStatus.pending: [
      TransactionStatus.processing,
      TransactionStatus.cancelled,
    ],
    TransactionStatus.processing: [
      TransactionStatus.completed,
      TransactionStatus.failed,
    ],
    TransactionStatus.completed: [], // Terminal state
    TransactionStatus.failed: [
      TransactionStatus.pending, // Can retry
    ],
    TransactionStatus.cancelled: [], // Terminal state
  };

  /// Check if transition to new status is valid
  bool canTransitionTo(TransactionStatus newStatus) {
    return _transitions[this]?.contains(newStatus) ?? false;
  }

  /// Get all valid next statuses from current status
  List<TransactionStatus> getValidTransitions() {
    return _transitions[this] ?? [];
  }

  /// Check if current status is terminal (no further transitions)
  bool get isTerminal {
    final transitions = _transitions[this];
    return transitions == null || transitions.isEmpty;
  }

  /// Check if transaction is successful
  bool get isSuccessful => this == TransactionStatus.completed;

  /// Check if transaction is processable
  bool get isProcessable =>
      this == TransactionStatus.pending || this == TransactionStatus.failed;

  /// Check if transaction is in progress
  bool get isInProgress => this == TransactionStatus.processing;

  /// Get status from string value
  static TransactionStatus fromString(String value) {
    for (final status in TransactionStatus.values) {
      if (status.value == value.toUpperCase()) {
        return status;
      }
    }
    throw ArgumentError('Unknown transaction status: $value');
  }
}
