import '../enums/booking_status.dart';
import '../enums/payment_status.dart';

/// Core booking entity containing all business rules and logic.
/// Represents a session booking between a student and tutor.
class BookingEntity {
  const BookingEntity({
    required this.id,
    required this.studentId,
    required this.tutorId,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    this.notes,
    this.sessionNotes,
    this.cancellationReason,
    this.updatedAt,
  });

  final String id;
  final String studentId;
  final String tutorId;
  final DateTime startTime;
  final DateTime endTime;
  final double price;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String? notes;
  final String? sessionNotes;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // ── Business Rules & Calculations ──────────────────────────────────────

  /// Calculate session duration in hours
  double get durationInHours {
    final duration = endTime.difference(startTime);
    return duration.inMinutes / 60.0;
  }

  /// Calculate session duration in minutes
  int get durationInMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  /// Calculate price based on hourly rate
  double calculatePrice(double hourlyRate) {
    return hourlyRate * durationInHours;
  }

  /// Check if time range is valid (end time after start time)
  bool get hasValidTimeRange {
    return endTime.isAfter(startTime);
  }

  /// Check if booking overlaps with another booking
  bool isOverlapping(BookingEntity other) {
    // Bookings overlap if:
    // this.startTime < other.endTime AND this.endTime > other.startTime
    return startTime.isBefore(other.endTime) &&
        endTime.isAfter(other.startTime);
  }

  /// Check if booking overlaps with a time range
  bool isOverlappingWithTimeRange(DateTime rangeStart, DateTime rangeEnd) {
    return startTime.isBefore(rangeEnd) && endTime.isAfter(rangeStart);
  }

  /// Check if status transition is valid
  bool canTransitionTo(BookingStatus newStatus) {
    return status.canTransitionTo(newStatus);
  }

  /// Check if booking can be cancelled by student
  bool get canBeCancelledByStudent {
    return status.canBeCancelled &&
        startTime.isAfter(
          DateTime.now().add(const Duration(hours: 24)),
        ); // 24h notice
  }

  /// Check if booking can be cancelled by tutor
  bool get canBeCancelledByTutor {
    return status.canBeCancelled &&
        startTime.isAfter(
          DateTime.now().add(const Duration(hours: 2)),
        ); // 2h notice
  }

  /// Check if booking can be edited (only pending bookings)
  bool get canBeEdited {
    return status == BookingStatus.pending &&
        startTime.isAfter(
          DateTime.now().add(const Duration(hours: 1)),
        ); // 1h notice
  }

  /// Check if booking can be completed
  bool get canBeCompleted {
    return status == BookingStatus.paid &&
        paymentStatus.isSuccessful &&
        DateTime.now().isAfter(endTime); // Can only complete after session ends
  }

  /// Check if booking is in the past
  bool get isPast {
    return endTime.isBefore(DateTime.now());
  }

  /// Check if booking is currently happening
  bool get isActive {
    final now = DateTime.now();
    return startTime.isBefore(now) && endTime.isAfter(now);
  }

  /// Check if booking is upcoming
  bool get isUpcoming {
    return startTime.isAfter(DateTime.now());
  }

  /// Get time until booking starts
  Duration get timeUntilStart {
    return startTime.difference(DateTime.now());
  }

  /// Get formatted duration string
  String get formattedDuration {
    final hours = durationInHours.floor();
    final minutes = (durationInMinutes % 60);

    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Get formatted price string
  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}';
  }

  /// Get booking summary for display
  String get summary {
    return 'Session on ${_formatDate(startTime)} at ${_formatTime(startTime)} - ${_formatTime(endTime)} ($formattedDuration)';
  }

  // ── Helper Methods ─────────────────────────────────────────────────────

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // ── Equality & Copy Methods ────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Create a copy with updated fields
  BookingEntity copyWith({
    String? id,
    String? studentId,
    String? tutorId,
    DateTime? startTime,
    DateTime? endTime,
    double? price,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    String? notes,
    String? sessionNotes,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      tutorId: tutorId ?? this.tutorId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      price: price ?? this.price,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      sessionNotes: sessionNotes ?? this.sessionNotes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'BookingEntity(id: $id, status: $status, startTime: $startTime, endTime: $endTime, price: $price)';
  }
}
