import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String bookingId;
  final String tutorId;
  final String studentId;
  final String? studentName;
  final String? studentImage;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ReviewEntity({
    required this.id,
    required this.bookingId,
    required this.tutorId,
    required this.studentId,
    this.studentName,
    this.studentImage,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor for creating a new review (before it's persisted)
  factory ReviewEntity.create({
    required String bookingId,
    required String tutorId,
    required String studentId,
    required int rating,
    String? comment,
    String? studentName,
    String? studentImage,
  }) {
    return ReviewEntity(
      id: '',
      bookingId: bookingId,
      tutorId: tutorId,
      studentId: studentId,
      studentName: studentName,
      studentImage: studentImage,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
  }

  ReviewEntity copyWith({
    String? id,
    String? bookingId,
    String? tutorId,
    String? studentId,
    String? studentName,
    String? studentImage,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      tutorId: tutorId ?? this.tutorId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentImage: studentImage ?? this.studentImage,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, bookingId, rating, updatedAt];
}
