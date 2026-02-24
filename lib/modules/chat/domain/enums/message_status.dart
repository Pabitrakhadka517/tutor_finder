/// Message status enumeration representing message delivery states.
/// Tracks the lifecycle of messages in real-time chat.
enum MessageStatus {
  /// Message has been sent by sender
  sent('SENT'),

  /// Message delivered to recipient's device
  delivered('DELIVERED'),

  /// Message has been read by recipient
  read('READ');

  const MessageStatus(this.value);

  final String value;

  /// Get status from string value
  static MessageStatus fromString(String value) {
    for (final status in MessageStatus.values) {
      if (status.value == value.toUpperCase()) {
        return status;
      }
    }
    throw ArgumentError('Unknown message status: $value');
  }

  /// Check if message is sent
  bool get isSent => this == MessageStatus.sent;

  /// Check if message is delivered
  bool get isDelivered => this == MessageStatus.delivered;

  /// Check if message is read
  bool get isRead => this == MessageStatus.read;

  /// Get display text for status
  String get displayText {
    switch (this) {
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.read:
        return 'Read';
    }
  }
}
