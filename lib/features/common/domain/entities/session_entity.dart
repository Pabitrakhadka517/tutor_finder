import 'package:equatable/equatable.dart';

/// Status of a live tutoring session.
enum SessionStatus { scheduled, inProgress, completed, cancelled }

/// Domain entity representing an actual tutoring session (after a booking
/// is confirmed and the session takes place).
class SessionEntity extends Equatable {
  final String id;
  final String bookingId;
  final String studentId;
  final String tutorId;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionStatus status;
  final String? meetingUrl;
  final String? recordingUrl;
  final String? sessionNotes;
  final DateTime createdAt;

  const SessionEntity({
    required this.id,
    required this.bookingId,
    required this.studentId,
    required this.tutorId,
    required this.startTime,
    this.endTime,
    this.status = SessionStatus.scheduled,
    this.meetingUrl,
    this.recordingUrl,
    this.sessionNotes,
    required this.createdAt,
  });

  /// Whether the session is currently in progress.
  bool get isLive => status == SessionStatus.inProgress;

  /// Duration (available after session ends).
  Duration? get duration => endTime?.difference(startTime);

  SessionEntity copyWith({
    String? id,
    String? bookingId,
    String? studentId,
    String? tutorId,
    DateTime? startTime,
    DateTime? endTime,
    SessionStatus? status,
    String? meetingUrl,
    String? recordingUrl,
    String? sessionNotes,
    DateTime? createdAt,
  }) {
    return SessionEntity(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      studentId: studentId ?? this.studentId,
      tutorId: tutorId ?? this.tutorId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      sessionNotes: sessionNotes ?? this.sessionNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    bookingId,
    studentId,
    tutorId,
    startTime,
    endTime,
    status,
    meetingUrl,
    recordingUrl,
    sessionNotes,
    createdAt,
  ];
}
