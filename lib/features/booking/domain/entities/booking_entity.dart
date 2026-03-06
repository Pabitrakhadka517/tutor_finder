import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final String id;
  final String studentId;
  final String tutorId;
  final String? studentName;
  final String? tutorName;
  final String? studentImage;
  final String? tutorImage;
  final String status;
  final String paymentStatus;
  final DateTime startTime;
  final DateTime endTime;
  final double price;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingEntity({
    required this.id,
    required this.studentId,
    required this.tutorId,
    this.studentName,
    this.tutorName,
    this.studentImage,
    this.tutorImage,
    required this.status,
    required this.paymentStatus,
    required this.startTime,
    required this.endTime,
    required this.price,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'PENDING';
  bool get isConfirmed => status == 'CONFIRMED';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isRejected => status == 'REJECTED';
  bool get isPaid => status == 'PAID';

  double get durationHours => endTime.difference(startTime).inMinutes / 60.0;

  @override
  List<Object?> get props => [id, status, paymentStatus, startTime, endTime];
}
