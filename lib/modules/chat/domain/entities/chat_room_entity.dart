/// Core chat room entity containing all business rules and logic.
/// Represents a chat session between a student and tutor based on a booking.
class ChatRoomEntity {
  const ChatRoomEntity({
    required this.id,
    required this.studentId,
    required this.tutorId,
    required this.bookingId,
    required this.isActive,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageAt,
    this.updatedAt,
  });

  final String id;
  final String studentId;
  final String tutorId;
  final String bookingId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // ── Business Rules & Validations ──────────────────────────────────────

  /// Check if a user can access this chat room
  bool canUserAccess(String userId) {
    return studentId == userId || tutorId == userId;
  }

  /// Check if user is the student in this chat
  bool isStudent(String userId) {
    return studentId == userId;
  }

  /// Check if user is the tutor in this chat
  bool isTutor(String userId) {
    return tutorId == userId;
  }

  /// Get the other participant's ID (not the current user)
  String getOtherParticipantId(String currentUserId) {
    if (!canUserAccess(currentUserId)) {
      throw ArgumentError(
        'User $currentUserId is not a participant in this chat',
      );
    }
    return currentUserId == studentId ? tutorId : studentId;
  }

  /// Check if chat room is active and can receive messages
  bool get canReceiveMessages {
    return isActive;
  }

  /// Validate chat room creation requirements
  bool validateCreationRequirements() {
    // Must have different student and tutor
    if (studentId == tutorId) {
      return false;
    }

    // Must have valid IDs
    if (studentId.isEmpty || tutorId.isEmpty || bookingId.isEmpty) {
      return false;
    }

    return true;
  }

  /// Check if chat has any message activity
  bool get hasMessages {
    return lastMessage != null && lastMessageAt != null;
  }

  /// Get chat age in hours
  double get ageInHours {
    return DateTime.now().difference(createdAt).inHours.toDouble();
  }

  /// Check if chat is recent (within 24 hours)
  bool get isRecent {
    return ageInHours <= 24;
  }

  /// Get time since last message in hours
  double? get hoursSinceLastMessage {
    if (lastMessageAt == null) return null;
    return DateTime.now().difference(lastMessageAt!).inHours.toDouble();
  }

  /// Check if chat is dormant (no messages for more than 7 days)
  bool get isDormant {
    final lastActivity = hoursSinceLastMessage;
    return lastActivity != null && lastActivity > (7 * 24);
  }

  /// Deactivate chat room
  ChatRoomEntity deactivate() {
    return copyWith(isActive: false, updatedAt: DateTime.now());
  }

  /// Reactivate chat room
  ChatRoomEntity reactivate() {
    return copyWith(isActive: true, updatedAt: DateTime.now());
  }

  /// Update last message information
  ChatRoomEntity updateLastMessage(String message, DateTime timestamp) {
    return copyWith(
      lastMessage: message,
      lastMessageAt: timestamp,
      updatedAt: DateTime.now(),
    );
  }

  /// Create a new chat room
  factory ChatRoomEntity.create({
    required String id,
    required String studentId,
    required String tutorId,
    required String bookingId,
  }) {
    return ChatRoomEntity(
      id: id,
      studentId: studentId,
      tutorId: tutorId,
      bookingId: bookingId,
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  /// Copy with method for immutable updates
  ChatRoomEntity copyWith({
    String? id,
    String? studentId,
    String? tutorId,
    String? bookingId,
    String? lastMessage,
    DateTime? lastMessageAt,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatRoomEntity(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      tutorId: tutorId ?? this.tutorId,
      bookingId: bookingId ?? this.bookingId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatRoomEntity &&
            runtimeType == other.runtimeType &&
            id == other.id);
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatRoomEntity(id: $id, student: $studentId, tutor: $tutorId, booking: $bookingId)';
  }
}
