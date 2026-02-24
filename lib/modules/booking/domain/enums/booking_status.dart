/// Booking status enumeration representing all possible booking states.
/// Follows state machine pattern for valid transitions.
enum BookingStatus {
  /// Initial state - booking created but not yet confirmed
  pending('PENDING'),

  /// Tutor has confirmed the booking
  confirmed('CONFIRMED'),

  /// Tutor has rejected the booking
  rejected('REJECTED'),

  /// Payment has been completed
  paid('PAID'),

  /// Session has been completed
  completed('COMPLETED'),

  /// Booking has been cancelled by either party
  cancelled('CANCELLED');

  const BookingStatus(this.value);

  final String value;

  /// Valid state transitions based on business rules
  static const Map<BookingStatus, List<BookingStatus>> _transitions = {
    BookingStatus.pending: [
      BookingStatus.confirmed,
      BookingStatus.rejected,
      BookingStatus.cancelled,
    ],
    BookingStatus.confirmed: [BookingStatus.paid, BookingStatus.cancelled],
    BookingStatus.rejected: [], // Terminal state
    BookingStatus.paid: [BookingStatus.completed, BookingStatus.cancelled],
    BookingStatus.completed: [], // Terminal state
    BookingStatus.cancelled: [], // Terminal state
  };

  /// Check if transition to new status is valid
  bool canTransitionTo(BookingStatus newStatus) {
    return _transitions[this]?.contains(newStatus) ?? false;
  }

  /// Get all valid next statuses from current status
  List<BookingStatus> getValidTransitions() {
    return _transitions[this] ?? [];
  }

  /// Check if current status is terminal (no further transitions)
  bool get isTerminal => _transitions[this]?.isEmpty ?? true;

  /// Check if booking is active (not cancelled, rejected, or completed)
  bool get isActive =>
      this == BookingStatus.pending ||
      this == BookingStatus.confirmed ||
      this == BookingStatus.paid;

  /// Check if booking can be cancelled
  bool get canBeCancelled =>
      this != BookingStatus.completed &&
      this != BookingStatus.rejected &&
      this != BookingStatus.cancelled;

  /// Get status from string value
  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Invalid booking status: $value'),
    );
  }

  @override
  String toString() => value;
}
