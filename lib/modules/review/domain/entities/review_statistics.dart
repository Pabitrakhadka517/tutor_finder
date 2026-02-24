/// Aggregated statistics for reviews
class ReviewStatistics {
  final int totalReviews;
  final double averageRating;
  final Map<int, int> ratingDistribution;
  final int recentReviewsCount;
  final double positiveReviewsPercentage;

  const ReviewStatistics({
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
    required this.recentReviewsCount,
    required this.positiveReviewsPercentage,
  });

  @override
  String toString() =>
      'ReviewStatistics(total: $totalReviews, avg: $averageRating)';
}

/// Review combined with student information
class ReviewWithStudentInfo {
  final dynamic review; // ReviewEntity
  final String studentName;
  final String? studentAvatar;

  const ReviewWithStudentInfo({
    required this.review,
    required this.studentName,
    this.studentAvatar,
  });

  @override
  String toString() => 'ReviewWithStudentInfo(student: $studentName)';
}
