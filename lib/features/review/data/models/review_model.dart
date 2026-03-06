import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.bookingId,
    required super.tutorId,
    required super.studentId,
    super.studentName,
    super.studentImage,
    required super.rating,
    super.comment,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
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

    // Parse booking (can be an object or string ID)
    String bookingId = '';
    if (json['booking'] is Map) {
      bookingId = (json['booking'] as Map)['_id']?.toString() ?? '';
    } else {
      bookingId = json['booking']?.toString() ?? '';
    }

    return ReviewModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      bookingId: bookingId,
      tutorId: json['tutor']?.toString() ?? '',
      studentId: studentId,
      studentName: studentName,
      studentImage: studentImage,
      rating: (json['rating'] is num) ? (json['rating'] as num).toInt() : 0,
      comment: json['comment']?.toString(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
