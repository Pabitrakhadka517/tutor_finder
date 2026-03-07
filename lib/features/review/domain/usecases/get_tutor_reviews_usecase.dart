import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/review_entity.dart';
import '../failures/review_failures.dart';
import '../repositories/review_repository.dart';

/// Use case for retrieving tutor reviews with pagination support
///
/// This use case handles:
/// 1. Input validation for pagination parameters
/// 2. Fetching reviews for a specific tutor
/// 3. Cache management through repository layer
/// 4. Proper error handling and pagination logic
@injectable
class GetTutorReviewsUseCase {
  final ReviewRepository _reviewRepository;

  GetTutorReviewsUseCase(this._reviewRepository);

  Future<Either<ReviewFailure, List<ReviewEntity>>> call(
    GetTutorReviewsParams params,
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

    // Validate tutor ID
    if (params.tutorId.trim().isEmpty) {
      return const Left(
        ReviewFailure.validationError('Tutor ID cannot be empty'),
      );
    }

    return _reviewRepository.getTutorReviews(
      params.tutorId,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetTutorReviewsParams {
  final String tutorId;
  final int? page;
  final int? limit;

  const GetTutorReviewsParams({
    required this.tutorId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  String toString() {
    return 'GetTutorReviewsParams(tutorId: $tutorId, page: $page, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GetTutorReviewsParams &&
        other.tutorId == tutorId &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode => tutorId.hashCode ^ page.hashCode ^ limit.hashCode;
}
