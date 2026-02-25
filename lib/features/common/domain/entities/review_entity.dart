import 'package:equatable/equatable.dart';

/// Domain entity representing a review left by a student for a tutor.
class ReviewEntity extends Equatable {
  final String id;
  final String bookingId;
  final String studentId;
  final String tutorId;
  final String? studentName;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.bookingId,
    required this.studentId,
    required this.tutorId,
    this.studentName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  ReviewEntity copyWith({
    String? id,
    String? bookingId,
    String? studentId,
    String? tutorId,
    String? studentName,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      studentId: studentId ?? this.studentId,
      tutorId: tutorId ?? this.tutorId,
      studentName: studentName ?? this.studentName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    bookingId,
    studentId,
    tutorId,
    studentName,
    rating,
    comment,
    createdAt,
  ];
}
