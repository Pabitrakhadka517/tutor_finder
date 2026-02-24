/// Notification Type Value Object
///
/// Encapsulates allowed notification types to ensure type safety
/// and prevent invalid notification creation. This value object
/// enforces domain rules about what notification types are valid
/// in the system.
class NotificationType {
  static const String _bookingCreated = 'BOOKING_CREATED';
  static const String _bookingUpdated = 'BOOKING_UPDATED';
  static const String _bookingCancelled = 'BOOKING_CANCELLED';
  static const String _paymentSuccess = 'PAYMENT_SUCCESS';
  static const String _paymentFailed = 'PAYMENT_FAILED';
  static const String _newReview = 'NEW_REVIEW';
  static const String _reviewUpdate = 'REVIEW_UPDATE';
  static const String _adminMessage = 'ADMIN_MESSAGE';
  static const String _systemAlert = 'SYSTEM_ALERT';
  static const String _chatMessage = 'CHAT_MESSAGE';
  static const String _profileUpdate = 'PROFILE_UPDATE';

  static const List<String> _validTypes = [
    _bookingCreated,
    _bookingUpdated,
    _bookingCancelled,
    _paymentSuccess,
    _paymentFailed,
    _newReview,
    _reviewUpdate,
    _adminMessage,
    _systemAlert,
    _chatMessage,
    _profileUpdate,
  ];

  final String value;

  const NotificationType._(this.value);

  // Factory constructors for each notification type
  static const NotificationType bookingCreated = NotificationType._(
    _bookingCreated,
  );
  static const NotificationType bookingUpdated = NotificationType._(
    _bookingUpdated,
  );
  static const NotificationType bookingCancelled = NotificationType._(
    _bookingCancelled,
  );
  static const NotificationType paymentSuccess = NotificationType._(
    _paymentSuccess,
  );
  static const NotificationType paymentFailed = NotificationType._(
    _paymentFailed,
  );
  static const NotificationType newReview = NotificationType._(_newReview);
  static const NotificationType reviewUpdate = NotificationType._(
    _reviewUpdate,
  );
  static const NotificationType adminMessage = NotificationType._(
    _adminMessage,
  );
  static const NotificationType systemAlert = NotificationType._(_systemAlert);
  static const NotificationType chatMessage = NotificationType._(_chatMessage);
  static const NotificationType profileUpdate = NotificationType._(
    _profileUpdate,
  );

  /// Create NotificationType from string value
  /// Throws ArgumentError if the type is not valid
  factory NotificationType.fromString(String value) {
    if (!_validTypes.contains(value)) {
      throw ArgumentError(
        'Invalid notification type: $value. '
        'Valid types are: ${_validTypes.join(', ')}',
      );
    }
    return NotificationType._(value);
  }

  /// Get all valid notification types
  static List<NotificationType> get allTypes => [
    bookingCreated,
    bookingUpdated,
    bookingCancelled,
    paymentSuccess,
    paymentFailed,
    newReview,
    reviewUpdate,
    adminMessage,
    systemAlert,
    chatMessage,
    profileUpdate,
  ];

  /// Check if a string represents a valid notification type
  static bool isValid(String value) => _validTypes.contains(value);

  /// Get display name for UI purposes
  String get displayName {
    switch (value) {
      case _bookingCreated:
        return 'Booking Created';
      case _bookingUpdated:
        return 'Booking Updated';
      case _bookingCancelled:
        return 'Booking Cancelled';
      case _paymentSuccess:
        return 'Payment Successful';
      case _paymentFailed:
        return 'Payment Failed';
      case _newReview:
        return 'New Review';
      case _reviewUpdate:
        return 'Review Updated';
      case _adminMessage:
        return 'Admin Message';
      case _systemAlert:
        return 'System Alert';
      case _chatMessage:
        return 'New Message';
      case _profileUpdate:
        return 'Profile Updated';
      default:
        return value;
    }
  }

  /// Get icon name for UI purposes
  String get iconName {
    switch (value) {
      case _bookingCreated:
      case _bookingUpdated:
        return 'calendar';
      case _bookingCancelled:
        return 'calendar_close';
      case _paymentSuccess:
        return 'payment_success';
      case _paymentFailed:
        return 'payment_error';
      case _newReview:
      case _reviewUpdate:
        return 'star';
      case _adminMessage:
        return 'admin';
      case _systemAlert:
        return 'warning';
      case _chatMessage:
        return 'chat';
      case _profileUpdate:
        return 'person';
      default:
        return 'notification';
    }
  }

  /// Check if this notification type requires immediate attention
  bool get isUrgent {
    return [
      _paymentFailed,
      _bookingCancelled,
      _adminMessage,
      _systemAlert,
    ].contains(value);
  }

  /// Check if this notification type should trigger a push notification
  bool get shouldPush {
    return [
      _bookingCreated,
      _bookingUpdated,
      _bookingCancelled,
      _paymentSuccess,
      _paymentFailed,
      _newReview,
      _adminMessage,
      _chatMessage,
    ].contains(value);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationType && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
