import 'package:equatable/equatable.dart';

/// Domain entity representing an availability slot
class AvailabilitySlotEntity extends Equatable {
  final String id;
  final String tutorId;
  final DateTime startTime;
  final DateTime endTime;
  final bool isBooked;

  const AvailabilitySlotEntity({
    required this.id,
    required this.tutorId,
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
  });

  @override
  List<Object?> get props => [id, tutorId, startTime, endTime, isBooked];
}
