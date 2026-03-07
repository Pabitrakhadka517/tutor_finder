import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/review_entity.dart';
import '../failures/review_failures.dart';
import '../repositories/review_repository.dart';

/// Use case for searching reviews with advanced filters
///
/// This use case handles:
/// 1. Input validation for search parameters
/// 2. Search query execution with proper filters
/// 3. Pagination and sorting management
/// 4. Cache management for search results
@injectable
class SearchReviewsUseCase {
  final ReviewRepository _reviewRepository;

  SearchReviewsUseCase(this._reviewRepository);

  Future<Either<ReviewFailure, List<ReviewEntity>>> call(
    SearchReviewsParams params,
  ) async {
    // Validate pagination parameters
    if (params.page != null && params.page! < 1) {
      return const Left(
        ReviewFailure.validationError('Page number must be greater than 0'),
      );
    }

    if (params.limit != null && (params.limit! < 1 || params.limit! > 100)) {
      return const Left(
        ReviewFailure.validationError('Limit must be between 1 and 100'),
      );
    }

    // Validate rating filters
    if (params.rating != null && (params.rating! < 1 || params.rating! > 5)) {
      return const Left(
        ReviewFailure.validationError('Rating must be between 1 and 5'),
      );
    }

    if (params.minRating != null &&
        (params.minRating! < 1 || params.minRating! > 5)) {
      return const Left(
        ReviewFailure.validationError('Minimum rating must be between 1 and 5'),
      );
    }

    if (params.maxRating != null &&
        (params.maxRating! < 1 || params.maxRating! > 5)) {
      return const Left(
        ReviewFailure.validationError('Maximum rating must be between 1 and 5'),
      );
    }

    if (params.minRating != null &&
        params.maxRating != null &&
        params.minRating! > params.maxRating!) {
      return const Left(
        ReviewFailure.validationError(
          'Minimum rating cannot be greater than maximum rating',
        ),
      );
    }

    // Validate date range
    if (params.startDate != null &&
        params.endDate != null &&
        params.startDate!.isAfter(params.endDate!)) {
      return const Left(
        ReviewFailure.validationError('Start date cannot be after end date'),
      );
    }

    // Validate sort parameters
    const validSortFields = ['createdAt', 'updatedAt', 'rating'];
    if (params.sortBy != null && !validSortFields.contains(params.sortBy)) {
      return Left(
        ReviewFailure.validationError(
          'Invalid sort field. Valid options: ${validSortFields.join(', ')}',
        ),
      );
    }

    const validSortOrders = ['asc', 'desc'];
    if (params.sortOrder != null &&
        !validSortOrders.contains(params.sortOrder)) {
      return Left(
        ReviewFailure.validationError(
          'Invalid sort order. Valid options: ${validSortOrders.join(', ')}',
        ),
      );
    }

    return _reviewRepository.searchReviews(
      tutorId: params.tutorId,
      studentId: params.studentId,
      bookingId: params.bookingId,
      rating: params.rating,
      minRating: params.minRating,
      maxRating: params.maxRating,
      query: params.query,
      subject: params.subject,
      startDate: params.startDate,
      endDate: params.endDate,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
      page: params.page,
      limit: params.limit,
    );
  }
}

class SearchReviewsParams {
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

  const SearchReviewsParams({
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

  @override
  String toString() {
    return 'SearchReviewsParams('
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

    return other is SearchReviewsParams &&
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

  SearchReviewsParams copyWith({
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
    return SearchReviewsParams(
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
}
