import 'package:dartz/dartz.dart';

import '../entities/platform_stats_entity.dart';
import '../entities/tutor_rating_entity.dart';
import '../failures/tutor_rating_failures.dart';

abstract class TutorRatingRepository {
  Future<Either<TutorRatingFailure, TutorRatingEntity>> createTutorRating(
    TutorRatingEntity rating,
  );

  Future<Either<TutorRatingFailure, TutorRatingEntity>> updateTutorRating(
    String tutorId,
    TutorRatingEntity rating,
  );

  Future<Either<TutorRatingFailure, TutorRatingEntity>> getTutorRating(
    String tutorId,
  );

  Future<Either<TutorRatingFailure, TutorRatingEntity>> recalculateTutorRating(
    String tutorId,
  );

  Future<Either<TutorRatingFailure, List<TutorRatingEntity>>>
  getTopRatedTutors({int? limit});

  Future<Either<TutorRatingFailure, List<TutorRatingEntity>>>
  getMostReviewedTutors({int? limit});

  Future<Either<TutorRatingFailure, PlatformStatsEntity>>
  getPlatformRatingStats();
}
