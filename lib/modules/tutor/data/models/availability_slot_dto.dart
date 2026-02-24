import 'package:json_annotation/json_annotation.dart';

part 'availability_slot_dto.g.dart';

/// Data Transfer Object for availability slot information from API.
/// Handles JSON serialization/deserialization for time slots.
@JsonSerializable()
class AvailabilitySlotDto {
  const AvailabilitySlotDto({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
    required this.dayOfWeek,
    this.studentId,
    this.lessonId,
    this.note,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'start_time')
  final String startTime;

  @JsonKey(name: 'end_time')
  final String endTime;

  @JsonKey(name: 'is_booked')
  final bool isBooked;

  @JsonKey(name: 'day_of_week')
  final int dayOfWeek;

  @JsonKey(name: 'student_id')
  final String? studentId;

  @JsonKey(name: 'lesson_id')
  final String? lessonId;

  @JsonKey(name: 'note')
  final String? note;

  /// Creates instance from JSON
  factory AvailabilitySlotDto.fromJson(Map<String, dynamic> json) =>
      _$AvailabilitySlotDtoFromJson(json);

  /// Converts instance to JSON
  Map<String, dynamic> toJson() => _$AvailabilitySlotDtoToJson(this);

  @override
  String toString() => 'AvailabilitySlotDto(id: $id, startTime: $startTime)';
}
