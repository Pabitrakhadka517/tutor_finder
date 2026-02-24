import '../value_objects/rating_vo.dart';

/// Core review entity containing all business rules and validation logic.
/// Represents a student's review and rating of a tutor after a completed booking.
class ReviewEntity {
  const ReviewEntity({
    required this.id,
    required this.bookingId,
    required this.tutorId,
    required this.studentId,
    required this.rating,
    required this.createdAt,
    this.comment,
    this.updatedAt,
  });

  final String id;
  final String bookingId;
  final String tutorId;
  final String studentId;
  final Rating rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // ── Business Rules & Validations ──────────────────────────────────────

  /// Business Rule: Validate comment length (max 500 characters)
  static String? validateCommentLength(String? comment) {
    if (comment == null || comment.trim().isEmpty) {
      return null; // Comment is optional
    }

    final trimmedComment = comment.trim();

    if (trimmedComment.length > 500) {
      return 'Comment must not exceed 500 characters';
    }

    if (trimmedComment.length < 10) {
      return 'Comment must be at least 10 characters long';
    }

    return null; // Valid comment
  }

  /// Business Rule: Validate review ownership
  /// Only the student who made the booking can create/edit the review
  bool validateOwnership(String currentUserId) {
    return studentId == currentUserId;
  }

  /// Business Rule: Check if user can view this review
  /// Students can view their own reviews, tutors can view reviews about them
  bool canUserView(String currentUserId) {
    return studentId == currentUserId || tutorId == currentUserId;
  }

  /// Business Rule: Check if review can be edited
  /// Reviews can only be edited by the student within 24 hours of creation
  bool canBeEditedBy(String currentUserId) {
    if (!validateOwnership(currentUserId)) {
      return false;
    }

    // Check if within 24 hours of creation
    final hoursSinceCreation = DateTime.now().difference(createdAt).inHours;
    return hoursSinceCreation <= 24;
  }

  /// Business Rule: Validate review data before creation
  static List<String> validateForCreation({
    required String bookingId,
    required String tutorId,
    required String studentId,
    required Rating rating,
    String? comment,
  }) {
    final errors = <String>[];

    // Validate IDs are not empty
    if (bookingId.trim().isEmpty) {
      errors.add('Booking ID is required');
    }

    if (tutorId.trim().isEmpty) {
      errors.add('Tutor ID is required');
    }

    if (studentId.trim().isEmpty) {
      errors.add('Student ID is required');
    }

    // Validate student and tutor are different
    if (studentId.trim() == tutorId.trim()) {
      errors.add('Student and tutor cannot be the same person');
    }

    // Validate comment
    final commentError = validateCommentLength(comment);
    if (commentError != null) {
      errors.add(commentError);
    }

    return errors;
  }

  /// Get sanitized comment (trim and remove excessive whitespace)
  String? get sanitizedComment {
    if (comment == null) return null;
    return comment!.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Check if review is recent (within last 30 days)
  bool get isRecent {
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    return daysSinceCreation <= 30;
  }

  /// Check if review has been edited
  bool get isEdited => updatedAt != null && updatedAt!.isAfter(createdAt);

  /// Get review age in days
  int get ageInDays => DateTime.now().difference(createdAt).inDays;

  /// Create an updated copy of the review
  ReviewEntity copyWith({
    String? id,
    String? bookingId,
    String? tutorId,
    String? studentId,
    Rating? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      tutorId: tutorId ?? this.tutorId,
      studentId: studentId ?? this.studentId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create an edited version with updated timestamp
  ReviewEntity edit({Rating? newRating, String? newComment}) {
    if (newRating == null && newComment == null) {
      throw ArgumentError('At least one field must be updated when editing');
    }

    return copyWith(
      rating: newRating ?? rating,
      comment: newComment ?? comment,
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewEntity &&
        other.id == id &&
        other.bookingId == bookingId &&
        other.tutorId == tutorId &&
        other.studentId == studentId &&
        other.rating == rating &&
        other.comment == comment &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        bookingId.hashCode ^
        tutorId.hashCode ^
        studentId.hashCode ^
        rating.hashCode ^
        (comment?.hashCode ?? 0) ^
        createdAt.hashCode ^
        (updatedAt?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'ReviewEntity('
        'id: $id, '
        'bookingId: $bookingId, '
        'tutorId: $tutorId, '
        'studentId: $studentId, '
        'rating: ${rating.value}, '
        'comment: ${comment?.length ?? 0} chars, '
        'createdAt: $createdAt'
        ')';
  }
}
