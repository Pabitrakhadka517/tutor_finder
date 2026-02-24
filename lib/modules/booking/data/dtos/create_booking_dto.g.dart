// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_booking_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateBookingDto _$CreateBookingDtoFromJson(Map<String, dynamic> json) =>
    CreateBookingDto(
      studentId: json['student_id'] as String,
      tutorId: json['tutor_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      hourlyRate: (json['hourly_rate'] as num).toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CreateBookingDtoToJson(CreateBookingDto instance) =>
    <String, dynamic>{
      'student_id': instance.studentId,
      'tutor_id': instance.tutorId,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'hourly_rate': instance.hourlyRate,
      'notes': instance.notes,
    };
