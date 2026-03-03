import '../../domain/entities/availability_slot_entity.dart';

/// Data model for AvailabilitySlot with JSON serialization
class AvailabilitySlotModel extends AvailabilitySlotEntity {
  const AvailabilitySlotModel({
    required super.id,
    required super.tutorId,
    required super.startTime,
    required super.endTime,
    super.isBooked,
  });

  factory AvailabilitySlotModel.fromJson(Map<String, dynamic> json) {
    final tutorField = json['tutorId'] ?? json['tutor'];
    final parsedTutorId = tutorField is Map<String, dynamic>
        ? (tutorField['_id'] ?? tutorField['id'] ?? '').toString()
        : (tutorField ?? '').toString();

    final rawIsBooked = json['isBooked'];
    final parsedIsBooked = rawIsBooked is bool
        ? rawIsBooked
        : rawIsBooked?.toString().toLowerCase() == 'true';

    return AvailabilitySlotModel(
      id: json['_id'] ?? json['id'] ?? '',
      tutorId: parsedTutorId,
      startTime: DateTime.parse(json['startTime']).toUtc(),
      endTime: DateTime.parse(json['endTime']).toUtc(),
      isBooked: parsedIsBooked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
    };
  }
}
