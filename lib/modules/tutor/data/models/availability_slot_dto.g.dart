// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_slot_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailabilitySlotDto _$AvailabilitySlotDtoFromJson(Map<String, dynamic> json) =>
    AvailabilitySlotDto(
      id: json['id'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      isBooked: json['is_booked'] as bool,
      dayOfWeek: (json['day_of_week'] as num).toInt(),
      studentId: json['student_id'] as String?,
      lessonId: json['lesson_id'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$AvailabilitySlotDtoToJson(
        AvailabilitySlotDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'is_booked': instance.isBooked,
      'day_of_week': instance.dayOfWeek,
      'student_id': instance.studentId,
      'lesson_id': instance.lessonId,
      'note': instance.note,
    };
