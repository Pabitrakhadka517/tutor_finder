import 'package:equatable/equatable.dart';

import 'tutor_entity.dart';

/// Represents a paginated result of tutor search/listing.
/// Contains the tutors data along with pagination metadata.
class TutorListResultEntity extends Equatable {
  const TutorListResultEntity({
    required this.tutors,
    required this.total,
    required this.page,
    required this.totalPages,
    required this.limit,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });

  /// List of tutors in this page
  final List<TutorEntity> tutors;

  /// Total number of tutors available
  final int total;

  /// Current page number (1-based)
  final int page;

  /// Total number of pages
  final int totalPages;

  /// Number of items per page
  final int limit;

  /// Whether there's a next page available
  final bool hasNextPage;

  /// Whether there's a previous page available
  final bool hasPreviousPage;

  /// Helper getters
  bool get isEmpty => tutors.isEmpty;
  bool get isNotEmpty => tutors.isNotEmpty;
  int get count => tutors.length;
  bool get isFirstPage => page <= 1;
  bool get isLastPage => page >= totalPages;

  /// Gets the range of items shown (e.g., "1-10 of 50")
  String get itemRangeDisplay {
    if (isEmpty) return '0 items';

    final startItem = ((page - 1) * limit) + 1;
    final endItem = (page * limit).clamp(0, total);
    return '$startItem-$endItem of $total';
  }

  /// Creates an empty result
  factory TutorListResultEntity.empty() {
    return const TutorListResultEntity(
      tutors: [],
      total: 0,
      page: 1,
      totalPages: 0,
      limit: 10,
    );
  }

  /// Creates a result for the first page with given tutors
  factory TutorListResultEntity.firstPage({
    required List<TutorEntity> tutors,
    required int total,
    required int limit,
  }) {
    final totalPages = (total / limit).ceil();
    return TutorListResultEntity(
      tutors: tutors,
      total: total,
      page: 1,
      totalPages: totalPages,
      limit: limit,
      hasNextPage: totalPages > 1,
      hasPreviousPage: false,
    );
  }

  /// Merges this result with new tutors (for pagination)
  TutorListResultEntity mergeWithNewPage(TutorListResultEntity newPage) {
    return TutorListResultEntity(
      tutors: [...tutors, ...newPage.tutors],
      total: newPage.total,
      page: newPage.page,
      totalPages: newPage.totalPages,
      limit: newPage.limit,
      hasNextPage: newPage.hasNextPage,
      hasPreviousPage: newPage.hasPreviousPage,
    );
  }

  /// Creates a copy with modified fields
  TutorListResultEntity copyWith({
    List<TutorEntity>? tutors,
    int? total,
    int? page,
    int? totalPages,
    int? limit,
    bool? hasNextPage,
    bool? hasPreviousPage,
  }) {
    return TutorListResultEntity(
      tutors: tutors ?? this.tutors,
      total: total ?? this.total,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      limit: limit ?? this.limit,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
    );
  }

  @override
  List<Object?> get props => [
    tutors,
    total,
    page,
    totalPages,
    limit,
    hasNextPage,
    hasPreviousPage,
  ];

  @override
  String toString() =>
      'TutorListResult(page: $page/$totalPages, count: ${tutors.length}, total: $total)';
}
