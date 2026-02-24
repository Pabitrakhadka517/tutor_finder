import 'package:equatable/equatable.dart';

/// Represents a time slot when a tutor is available for lessons.
/// Used for scheduling and availability management.
class AvailabilitySlotEntity extends Equatable {
  const AvailabilitySlotEntity({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
    required this.dayOfWeek,
    this.studentId,
    this.lessonId,
    this.note,
  });

  /// Unique slot identifier
  final String id;

  /// Start time of the slot
  final DateTime startTime;

  /// End time of the slot
  final DateTime endTime;

  /// Whether this slot is already booked
  final bool isBooked;

  /// Day of the week (1 = Monday, 7 = Sunday)
  final int dayOfWeek;

  /// ID of student who booked this slot (if booked)
  final String? studentId;

  /// ID of the lesson associated with this slot (if booked)
  final String? lessonId;

  /// Optional note for the slot
  final String? note;

  /// Helper getters
  Duration get duration => endTime.difference(startTime);
  bool get isAvailable => !isBooked;
  String get timeRange => '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  String get dayName => _getDayName(dayOfWeek);

  /// Formats time as HH:mm
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Gets day name from day number
  String _getDayName(int day) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[day - 1];
  }

  /// Check if this slot overlaps with another slot
  bool overlapsWith(AvailabilitySlotEntity other) {
    return startTime.isBefore(other.endTime) &&
        endTime.isAfter(other.startTime);
  }

  /// Check if this slot is in the future
  bool get isFuture => startTime.isAfter(DateTime.now());

  /// Check if this slot is today
  bool get isToday {
    final now = DateTime.now();
    return startTime.day == now.day &&
        startTime.month == now.month &&
        startTime.year == now.year;
  }

  /// Creates a copy with modified fields
  AvailabilitySlotEntity copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    bool? isBooked,
    int? dayOfWeek,
    String? studentId,
    String? lessonId,
    String? note,
  }) {
    return AvailabilitySlotEntity(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isBooked: isBooked ?? this.isBooked,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      studentId: studentId ?? this.studentId,
      lessonId: lessonId ?? this.lessonId,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [
    id,
    startTime,
    endTime,
    isBooked,
    dayOfWeek,
    studentId,
    lessonId,
    note,
  ];

  @override
  String toString() =>
      'AvailabilitySlot(id: $id, timeRange: $timeRange, isBooked: $isBooked)';
}
