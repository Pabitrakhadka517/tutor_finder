class ReviewSearchParams {
  final String? tutorId;
  final String? studentId;
  final String? bookingId;
  final int? rating;
  final int? minRating;
  final int? maxRating;
  final String? query;
  final String? subject;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? sortBy;
  final String? sortOrder;
  final int? page;
  final int? limit;

  const ReviewSearchParams({
    this.tutorId,
    this.studentId,
    this.bookingId,
    this.rating,
    this.minRating,
    this.maxRating,
    this.query,
    this.subject,
    this.startDate,
    this.endDate,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
    this.page = 1,
    this.limit = 20,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (tutorId != null) map['tutorId'] = tutorId;
    if (studentId != null) map['studentId'] = studentId;
    if (bookingId != null) map['bookingId'] = bookingId;
    if (rating != null) map['rating'] = rating;
    if (minRating != null) map['minRating'] = minRating;
    if (maxRating != null) map['maxRating'] = maxRating;
    if (query != null && query!.isNotEmpty) map['query'] = query;
    if (subject != null && subject!.isNotEmpty) map['subject'] = subject;
    if (startDate != null) map['startDate'] = startDate!.toIso8601String();
    if (endDate != null) map['endDate'] = endDate!.toIso8601String();
    if (sortBy != null) map['sortBy'] = sortBy;
    if (sortOrder != null) map['sortOrder'] = sortOrder;
    if (page != null) map['page'] = page;
    if (limit != null) map['limit'] = limit;

    return map;
  }

  ReviewSearchParams copyWith({
    String? tutorId,
    String? studentId,
    String? bookingId,
    int? rating,
    int? minRating,
    int? maxRating,
    String? query,
    String? subject,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    String? sortOrder,
    int? page,
    int? limit,
  }) {
    return ReviewSearchParams(
      tutorId: tutorId ?? this.tutorId,
      studentId: studentId ?? this.studentId,
      bookingId: bookingId ?? this.bookingId,
      rating: rating ?? this.rating,
      minRating: minRating ?? this.minRating,
      maxRating: maxRating ?? this.maxRating,
      query: query ?? this.query,
      subject: subject ?? this.subject,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  String toString() {
    return 'ReviewSearchParams('
        'tutorId: $tutorId, '
        'studentId: $studentId, '
        'bookingId: $bookingId, '
        'rating: $rating, '
        'minRating: $minRating, '
        'maxRating: $maxRating, '
        'query: $query, '
        'subject: $subject, '
        'startDate: $startDate, '
        'endDate: $endDate, '
        'sortBy: $sortBy, '
        'sortOrder: $sortOrder, '
        'page: $page, '
        'limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReviewSearchParams &&
        other.tutorId == tutorId &&
        other.studentId == studentId &&
        other.bookingId == bookingId &&
        other.rating == rating &&
        other.minRating == minRating &&
        other.maxRating == maxRating &&
        other.query == query &&
        other.subject == subject &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.sortBy == sortBy &&
        other.sortOrder == sortOrder &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    return tutorId.hashCode ^
        studentId.hashCode ^
        bookingId.hashCode ^
        rating.hashCode ^
        minRating.hashCode ^
        maxRating.hashCode ^
        query.hashCode ^
        subject.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        sortBy.hashCode ^
        sortOrder.hashCode ^
        page.hashCode ^
        limit.hashCode;
  }
}
