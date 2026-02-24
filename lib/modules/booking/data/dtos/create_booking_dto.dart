import 'package:json_annotation/json_annotation.dart';

import '../../domain/usecases/create_booking_usecase.dart';

part 'create_booking_dto.g.dart';

/// DTO for create booking API requests.
@JsonSerializable()
class CreateBookingDto {
  const CreateBookingDto({
    required this.studentId,
    required this.tutorId,
    required this.startTime,
    required this.endTime,
    required this.hourlyRate,
    this.notes,
  });

  @JsonKey(name: 'student_id')
  final String studentId;

  @JsonKey(name: 'tutor_id')
  final String tutorId;

  @JsonKey(name: 'start_time')
  final DateTime startTime;

  @JsonKey(name: 'end_time')
  final DateTime endTime;

  @JsonKey(name: 'hourly_rate')
  final double hourlyRate;

  @JsonKey(name: 'notes')
  final String? notes;

  /// Factory constructor for JSON deserialization
  factory CreateBookingDto.fromJson(Map<String, dynamic> json) =>
      _$CreateBookingDtoFromJson(json);

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() => _$CreateBookingDtoToJson(this);

  /// Create from use case parameters
  factory CreateBookingDto.fromParams(CreateBookingParams params) {
    return CreateBookingDto(
      studentId: params.studentId,
      tutorId: params.tutorId,
      startTime: params.startTime,
      endTime: params.endTime,
      hourlyRate: params.hourlyRate,
      notes: params.notes,
    );
  }

  @override
  String toString() {
    return 'CreateBookingDto(studentId: $studentId, tutorId: $tutorId, '
        'startTime: $startTime, endTime: $endTime, hourlyRate: $hourlyRate)';
  }
}
