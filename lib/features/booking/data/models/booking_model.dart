import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.studentId,
    required super.tutorId,
    super.studentName,
    super.tutorName,
    super.studentImage,
    super.tutorImage,
    required super.status,
    required super.paymentStatus,
    required super.startTime,
    required super.endTime,
    required super.price,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Parse student (can be an object or string ID)
    String studentId = '';
    String? studentName;
    String? studentImage;
    if (json['student'] is Map) {
      final s = json['student'] as Map<String, dynamic>;
      studentId = s['_id']?.toString() ?? s['id']?.toString() ?? '';
      studentName = s['fullName']?.toString();
      studentImage = s['profileImage']?.toString();
    } else {
      studentId = json['student']?.toString() ?? '';
    }

    // Parse tutor (can be an object or string ID)
    String tutorId = '';
    String? tutorName;
    String? tutorImage;
    if (json['tutor'] is Map) {
      final t = json['tutor'] as Map<String, dynamic>;
      tutorId = t['_id']?.toString() ?? t['id']?.toString() ?? '';
      tutorName = t['fullName']?.toString();
      tutorImage = t['profileImage']?.toString();
    } else {
      tutorId = json['tutor']?.toString() ?? '';
    }

    return BookingModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      studentId: studentId,
      tutorId: tutorId,
      studentName: studentName,
      tutorName: tutorName,
      studentImage: studentImage,
      tutorImage: tutorImage,
      status: json['status']?.toString() ?? 'PENDING',
      paymentStatus: json['paymentStatus']?.toString() ?? 'UNPAID',
      startTime:
          DateTime.tryParse(json['startTime']?.toString() ?? '') ??
          DateTime.now(),
      endTime:
          DateTime.tryParse(json['endTime']?.toString() ?? '') ??
          DateTime.now(),
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      notes: json['notes']?.toString(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tutorId': tutorId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }
}
