import 'package:equatable/equatable.dart';

/// Booking status enum shared across features.
enum BookingStatus { pending, confirmed, cancelled, completed }

/// Domain entity representing a tutoring booking / session request.
class BookingEntity extends Equatable {
  final String id;
  final String studentId;
  final String tutorId;
  final String? studentName;
  final String? tutorName;
  final String subject;
  final DateTime scheduledAt;
  final int durationMinutes;
  final BookingStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BookingEntity({
    required this.id,
    required this.studentId,
    required this.tutorId,
    this.studentName,
    this.tutorName,
    required this.subject,
    required this.scheduledAt,
    this.durationMinutes = 60,
    this.status = BookingStatus.pending,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  BookingEntity copyWith({
    String? id,
    String? studentId,
    String? tutorId,
    String? studentName,
    String? tutorName,
    String? subject,
    DateTime? scheduledAt,
    int? durationMinutes,
    BookingStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      tutorId: tutorId ?? this.tutorId,
      studentName: studentName ?? this.studentName,
      tutorName: tutorName ?? this.tutorName,
      subject: subject ?? this.subject,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    studentId,
    tutorId,
    studentName,
    tutorName,
    subject,
    scheduledAt,
    durationMinutes,
    status,
    notes,
    createdAt,
    updatedAt,
  ];
}
