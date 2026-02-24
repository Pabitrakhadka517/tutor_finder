import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/booking_entity.dart';
import '../../domain/enums/booking_status.dart';
import '../../domain/enums/payment_status.dart';

part 'booking_dto.g.dart';

/// Data Transfer Object for booking API responses.
/// Handles serialization/deserialization with API.
@JsonSerializable()
class BookingDto {
  const BookingDto({
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
    this.studentName,
    this.tutorName,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'student_id')
  final String studentId;

  @JsonKey(name: 'tutor_id')
  final String tutorId;

  @JsonKey(name: 'start_time')
  final DateTime startTime;

  @JsonKey(name: 'end_time')
  final DateTime endTime;

  @JsonKey(name: 'price')
  final double price;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'payment_status')
  final String paymentStatus;

  @JsonKey(name: 'notes')
  final String? notes;

  @JsonKey(name: 'session_notes')
  final String? sessionNotes;

  @JsonKey(name: 'cancellation_reason')
  final String? cancellationReason;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // Additional fields that might come from API joins
  @JsonKey(name: 'student_name')
  final String? studentName;

  @JsonKey(name: 'tutor_name')
  final String? tutorName;

  /// Factory constructor for JSON deserialization
  factory BookingDto.fromJson(Map<String, dynamic> json) =>
      _$BookingDtoFromJson(json);

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() => _$BookingDtoToJson(this);

  /// Convert to domain entity
  BookingEntity toEntity() {
    return BookingEntity(
      id: id,
      studentId: studentId,
      tutorId: tutorId,
      startTime: startTime,
      endTime: endTime,
      price: price,
      status: BookingStatus.fromString(status),
      paymentStatus: PaymentStatus.fromString(paymentStatus),
      notes: notes,
      sessionNotes: sessionNotes,
      cancellationReason: cancellationReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create DTO from domain entity
  factory BookingDto.fromEntity(BookingEntity entity) {
    return BookingDto(
      id: entity.id,
      studentId: entity.studentId,
      tutorId: entity.tutorId,
      startTime: entity.startTime,
      endTime: entity.endTime,
      price: entity.price,
      status: entity.status.value,
      paymentStatus: entity.paymentStatus.value,
      notes: entity.notes,
      sessionNotes: entity.sessionNotes,
      cancellationReason: entity.cancellationReason,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  String toString() {
    return 'BookingDto(id: $id, status: $status, startTime: $startTime, endTime: $endTime)';
  }
}
