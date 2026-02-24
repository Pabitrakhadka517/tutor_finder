/// Base class for all chat-related failures.
/// Provides a consistent error handling approach across the chat domain.
abstract class ChatFailure implements Exception {
  const ChatFailure(this.message);

  final String message;

  /// Factory constructors for common failures
  factory ChatFailure.serverError(String message) = ChatServerFailure;
  factory ChatFailure.noConnection(String message) = ChatNetworkFailure;
  factory ChatFailure.unauthorized(String message) = ChatAuthorizationFailure;
  factory ChatFailure.accessDenied(String message) = ChatAuthorizationFailure;
  factory ChatFailure.notFound(String message) = ChatRoomNotFoundFailure;
  factory ChatFailure.invalidInput(String message) = ChatValidationFailure;
  factory ChatFailure.invalidOperation(String message) = ChatValidationFailure;

  @override
  String toString() => 'ChatFailure: $message';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatFailure &&
            runtimeType == other.runtimeType &&
            message == other.message);
  }

  @override
  int get hashCode => message.hashCode;
}

/// Failure when chat validation fails
class ChatValidationFailure extends ChatFailure {
  const ChatValidationFailure(super.message);
}

/// Failure when authorization is denied
class ChatAuthorizationFailure extends ChatFailure {
  const ChatAuthorizationFailure(super.message);
}

/// Failure when chat room is not found
class ChatRoomNotFoundFailure extends ChatFailure {
  const ChatRoomNotFoundFailure(super.message);
}

/// Failure when message is not found
class MessageNotFoundFailure extends ChatFailure {
  const MessageNotFoundFailure(super.message);
}

/// Failure when socket connection fails
class SocketConnectionFailure extends ChatFailure {
  const SocketConnectionFailure(super.message, {this.code});

  final String? code;
}

/// Failure when booking requirements are not met
class BookingRequirementFailure extends ChatFailure {
  const BookingRequirementFailure(super.message);
}

/// Failure when chat conflicts with business rules
class ChatConflictFailure extends ChatFailure {
  const ChatConflictFailure(super.message);
}

/// Failure during network operations
class ChatNetworkFailure extends ChatFailure {
  const ChatNetworkFailure(super.message);
}

/// Failure on the server side
class ChatServerFailure extends ChatFailure {
  const ChatServerFailure(super.message, {this.statusCode});

  final int? statusCode;
}

/// Unknown failure that doesn't fit other categories
class ChatUnknownFailure extends ChatFailure {
  const ChatUnknownFailure(super.message);
}
