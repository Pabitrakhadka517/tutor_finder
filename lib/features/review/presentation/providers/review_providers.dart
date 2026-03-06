import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../data/datasources/review_remote_datasource.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/review_repository.dart';
import '../notifiers/review_notifier.dart';
import '../state/review_state.dart';

// ================= Data Sources =================
final reviewRemoteDataSourceProvider = Provider<ReviewRemoteDataSource>(
  (ref) => ReviewRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider)),
);

// ================= Repository =================

/// Simple repository implementation for reviews.
/// Only implements the 2 backend endpoints.
class _ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource _remoteDataSource;

  _ReviewRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ReviewEntity>> createReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      final review = await _remoteDataSource.createReview(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );
      return Right(review);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TutorReviewsResult>> getTutorReviews(
    String tutorId,
  ) async {
    try {
      final result = await _remoteDataSource.getTutorReviews(tutorId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => _ReviewRepositoryImpl(ref.read(reviewRemoteDataSourceProvider)),
);

// ================= Notifiers =================
final reviewListNotifierProvider =
    StateNotifierProvider<ReviewListNotifier, ReviewListState>(
      (ref) => ReviewListNotifier(ref.read(reviewRepositoryProvider)),
    );

final createReviewNotifierProvider =
    StateNotifierProvider<CreateReviewNotifier, CreateReviewState>(
      (ref) => CreateReviewNotifier(ref.read(reviewRepositoryProvider)),
    );
