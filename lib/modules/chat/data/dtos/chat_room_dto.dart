import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/chat_room_entity.dart';

part 'chat_room_dto.g.dart';

/// Data Transfer Object for chat room data.
/// Used for API communication and JSON serialization.
@JsonSerializable()
class ChatRoomDto {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'student_id')
  final String studentId;

  @JsonKey(name: 'tutor_id')
  final String tutorId;

  @JsonKey(name: 'booking_id')
  final String? bookingId;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'updated_at')
  final String updatedAt;

  @JsonKey(name: 'last_message')
  final String? lastMessage;

  @JsonKey(name: 'last_message_at')
  final String? lastMessageAt;

  ChatRoomDto({
    required this.id,
    required this.studentId,
    required this.tutorId,
    this.bookingId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.lastMessageAt,
  });

  /// Create from JSON
  factory ChatRoomDto.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomDtoFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$ChatRoomDtoToJson(this);

  /// Convert to domain entity
  ChatRoomEntity toEntity() {
    return ChatRoomEntity(
      id: id,
      studentId: studentId,
      tutorId: tutorId,
      bookingId: bookingId ?? '',
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt != null
          ? DateTime.parse(lastMessageAt!)
          : null,
    );
  }

  /// Create from domain entity
  factory ChatRoomDto.fromEntity(ChatRoomEntity entity) {
    return ChatRoomDto(
      id: entity.id,
      studentId: entity.studentId,
      tutorId: entity.tutorId,
      bookingId: entity.bookingId,
      isActive: entity.isActive,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt:
          entity.updatedAt?.toIso8601String() ??
          entity.createdAt.toIso8601String(),
      lastMessage: entity.lastMessage,
      lastMessageAt: entity.lastMessageAt?.toIso8601String(),
    );
  }

  /// Create DTO for API creation request
  factory ChatRoomDto.forCreation({
    required String studentId,
    required String tutorId,
    required String bookingId,
  }) {
    final now = DateTime.now().toIso8601String();
    return ChatRoomDto(
      id: '', // Will be set by server
      studentId: studentId,
      tutorId: tutorId,
      bookingId: bookingId,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatRoomDto &&
        other.id == id &&
        other.studentId == studentId &&
        other.tutorId == tutorId &&
        other.bookingId == bookingId &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.lastMessage == lastMessage &&
        other.lastMessageAt == lastMessageAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        studentId.hashCode ^
        tutorId.hashCode ^
        (bookingId?.hashCode ?? 0) ^
        isActive.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        (lastMessage?.hashCode ?? 0) ^
        (lastMessageAt?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'ChatRoomDto(id: $id, studentId: $studentId, tutorId: $tutorId, bookingId: $bookingId, isActive: $isActive)';
  }

  /// Create a copy with updated fields
  ChatRoomDto copyWith({
    String? id,
    String? studentId,
    String? tutorId,
    String? bookingId,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    String? lastMessage,
    String? lastMessageAt,
  }) {
    return ChatRoomDto(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      tutorId: tutorId ?? this.tutorId,
      bookingId: bookingId ?? this.bookingId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }
}
