/// Reference type enumeration for transaction references.
/// Indicates what type of entity the transaction is for.
enum ReferenceType {
  /// Transaction for a booking/session payment
  booking('BOOKING'),

  /// Transaction for a job payment
  job('JOB');

  const ReferenceType(this.value);

  final String value;

  /// Get reference type from string value
  static ReferenceType fromString(String value) {
    for (final type in ReferenceType.values) {
      if (type.value == value.toUpperCase()) {
        return type;
      }
    }
    throw ArgumentError('Unknown reference type: $value');
  }

  /// Check if this is a booking transaction
  bool get isBooking => this == ReferenceType.booking;

  /// Check if this is a job transaction
  bool get isJob => this == ReferenceType.job;
}
