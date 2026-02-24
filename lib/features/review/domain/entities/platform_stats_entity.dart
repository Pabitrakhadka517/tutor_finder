class PlatformStatsEntity {
  final double averageRating;
  final int totalReviews;
  final int totalTutors;
  final Map<int, int> ratingDistribution;
  final DateTime lastUpdated;

  const PlatformStatsEntity({
    required this.averageRating,
    required this.totalReviews,
    required this.totalTutors,
    required this.ratingDistribution,
    required this.lastUpdated,
  });

  @override
  String toString() {
    return 'PlatformStatsEntity('
        'averageRating: $averageRating, '
        'totalReviews: $totalReviews, '
        'totalTutors: $totalTutors, '
        'ratingDistribution: $ratingDistribution, '
        'lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlatformStatsEntity &&
        other.averageRating == averageRating &&
        other.totalReviews == totalReviews &&
        other.totalTutors == totalTutors &&
        _mapEquals(other.ratingDistribution, ratingDistribution) &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return averageRating.hashCode ^
        totalReviews.hashCode ^
        totalTutors.hashCode ^
        ratingDistribution.hashCode ^
        lastUpdated.hashCode;
  }

  bool _mapEquals(Map<int, int> map1, Map<int, int> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }
}
