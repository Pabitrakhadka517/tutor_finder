import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/exceptions/cache_exception.dart';
import '../dtos/review_dto.dart';
import '../dtos/tutor_rating_dto.dart';

abstract class ReviewLocalDataSource {
  // Review caching
  Future<void> cacheReview(ReviewDto reviewDto);
  Future<void> cacheReviews(List<ReviewDto> reviews, String cacheKey);
  Future<ReviewDto?> getCachedReview(String id);
  Future<List<ReviewDto>?> getCachedReviews(String cacheKey);
  Future<void> removeCachedReview(String id);
  Future<void> clearReviewCache();

  // Tutor rating caching
  Future<void> cacheTutorRating(TutorRatingDto ratingDto);
  Future<void> cacheTutorRatings(List<TutorRatingDto> ratings, String cacheKey);
  Future<TutorRatingDto?> getCachedTutorRating(String tutorId);
  Future<List<TutorRatingDto>?> getCachedTutorRatings(String cacheKey);
  Future<void> removeCachedTutorRating(String tutorId);
  Future<void> clearTutorRatingCache();

  // Platform stats caching
  Future<void> cachePlatformStats(PlatformStatsDto statsDto);
  Future<PlatformStatsDto?> getCachedPlatformStats();
  Future<void> clearPlatformStatsCache();

  // Cache management
  Future<void> clearAllCache();
  Future<bool> isCacheExpired(String cacheKey);
  Future<void> setCacheTimestamp(String cacheKey);
}

@LazySingleton(as: ReviewLocalDataSource)
class ReviewLocalDataSourceImpl implements ReviewLocalDataSource {
  final SharedPreferences _sharedPreferences;

  static const String _reviewCachePrefix = 'review_cache_';
  static const String _reviewsCachePrefix = 'reviews_cache_';
  static const String _tutorRatingCachePrefix = 'tutor_rating_cache_';
  static const String _tutorRatingsCachePrefix = 'tutor_ratings_cache_';
  static const String _platformStatsCache = 'platform_stats_cache';
  static const String _timestampSuffix = '_timestamp';

  // Cache duration in milliseconds (30 minutes)
  static const int _cacheDuration = 30 * 60 * 1000;

  ReviewLocalDataSourceImpl(this._sharedPreferences);

  @override
  Future<void> cacheReview(ReviewDto reviewDto) async {
    try {
      final cacheKey = '$_reviewCachePrefix${reviewDto.id}';
      final json = jsonEncode(reviewDto.toJson());
      await _sharedPreferences.setString(cacheKey, json);
      await setCacheTimestamp(cacheKey);
    } catch (e) {
      throw CacheException('Failed to cache review: $e');
    }
  }

  @override
  Future<void> cacheReviews(List<ReviewDto> reviews, String cacheKey) async {
    try {
      final fullCacheKey = '$_reviewsCachePrefix$cacheKey';
      final json = jsonEncode(
        reviews.map((review) => review.toJson()).toList(),
      );
      await _sharedPreferences.setString(fullCacheKey, json);
      await setCacheTimestamp(fullCacheKey);
    } catch (e) {
      throw CacheException('Failed to cache reviews: $e');
    }
  }

  @override
  Future<ReviewDto?> getCachedReview(String id) async {
    try {
      final cacheKey = '$_reviewCachePrefix$id';

      if (await isCacheExpired(cacheKey)) {
        await removeCachedReview(id);
        return null;
      }

      final json = _sharedPreferences.getString(cacheKey);
      if (json == null) return null;

      final Map<String, dynamic> map = jsonDecode(json);
      return ReviewDto.fromJson(map);
    } catch (e) {
      throw CacheException('Failed to get cached review: $e');
    }
  }

  @override
  Future<List<ReviewDto>?> getCachedReviews(String cacheKey) async {
    try {
      final fullCacheKey = '$_reviewsCachePrefix$cacheKey';

      if (await isCacheExpired(fullCacheKey)) {
        await _sharedPreferences.remove(fullCacheKey);
        await _sharedPreferences.remove('$fullCacheKey$_timestampSuffix');
        return null;
      }

      final json = _sharedPreferences.getString(fullCacheKey);
      if (json == null) return null;

      final List<dynamic> list = jsonDecode(json);
      return list.map((item) => ReviewDto.fromJson(item)).toList();
    } catch (e) {
      throw CacheException('Failed to get cached reviews: $e');
    }
  }

  @override
  Future<void> removeCachedReview(String id) async {
    try {
      final cacheKey = '$_reviewCachePrefix$id';
      await _sharedPreferences.remove(cacheKey);
      await _sharedPreferences.remove('$cacheKey$_timestampSuffix');
    } catch (e) {
      throw CacheException('Failed to remove cached review: $e');
    }
  }

  @override
  Future<void> clearReviewCache() async {
    try {
      final keys = _sharedPreferences.getKeys();
      final reviewKeys = keys.where(
        (key) =>
            key.startsWith(_reviewCachePrefix) ||
            key.startsWith(_reviewsCachePrefix),
      );

      for (final key in reviewKeys) {
        await _sharedPreferences.remove(key);
      }
    } catch (e) {
      throw CacheException('Failed to clear review cache: $e');
    }
  }

  @override
  Future<void> cacheTutorRating(TutorRatingDto ratingDto) async {
    try {
      final cacheKey = '$_tutorRatingCachePrefix${ratingDto.tutorId}';
      final json = jsonEncode(ratingDto.toJson());
      await _sharedPreferences.setString(cacheKey, json);
      await setCacheTimestamp(cacheKey);
    } catch (e) {
      throw CacheException('Failed to cache tutor rating: $e');
    }
  }

  @override
  Future<void> cacheTutorRatings(
    List<TutorRatingDto> ratings,
    String cacheKey,
  ) async {
    try {
      final fullCacheKey = '$_tutorRatingsCachePrefix$cacheKey';
      final json = jsonEncode(
        ratings.map((rating) => rating.toJson()).toList(),
      );
      await _sharedPreferences.setString(fullCacheKey, json);
      await setCacheTimestamp(fullCacheKey);
    } catch (e) {
      throw CacheException('Failed to cache tutor ratings: $e');
    }
  }

  @override
  Future<TutorRatingDto?> getCachedTutorRating(String tutorId) async {
    try {
      final cacheKey = '$_tutorRatingCachePrefix$tutorId';

      if (await isCacheExpired(cacheKey)) {
        await removeCachedTutorRating(tutorId);
        return null;
      }

      final json = _sharedPreferences.getString(cacheKey);
      if (json == null) return null;

      final Map<String, dynamic> map = jsonDecode(json);
      return TutorRatingDto.fromJson(map);
    } catch (e) {
      throw CacheException('Failed to get cached tutor rating: $e');
    }
  }

  @override
  Future<List<TutorRatingDto>?> getCachedTutorRatings(String cacheKey) async {
    try {
      final fullCacheKey = '$_tutorRatingsCachePrefix$cacheKey';

      if (await isCacheExpired(fullCacheKey)) {
        await _sharedPreferences.remove(fullCacheKey);
        await _sharedPreferences.remove('$fullCacheKey$_timestampSuffix');
        return null;
      }

      final json = _sharedPreferences.getString(fullCacheKey);
      if (json == null) return null;

      final List<dynamic> list = jsonDecode(json);
      return list.map((item) => TutorRatingDto.fromJson(item)).toList();
    } catch (e) {
      throw CacheException('Failed to get cached tutor ratings: $e');
    }
  }

  @override
  Future<void> removeCachedTutorRating(String tutorId) async {
    try {
      final cacheKey = '$_tutorRatingCachePrefix$tutorId';
      await _sharedPreferences.remove(cacheKey);
      await _sharedPreferences.remove('$cacheKey$_timestampSuffix');
    } catch (e) {
      throw CacheException('Failed to remove cached tutor rating: $e');
    }
  }

  @override
  Future<void> clearTutorRatingCache() async {
    try {
      final keys = _sharedPreferences.getKeys();
      final ratingKeys = keys.where(
        (key) =>
            key.startsWith(_tutorRatingCachePrefix) ||
            key.startsWith(_tutorRatingsCachePrefix),
      );

      for (final key in ratingKeys) {
        await _sharedPreferences.remove(key);
      }
    } catch (e) {
      throw CacheException('Failed to clear tutor rating cache: $e');
    }
  }

  @override
  Future<void> cachePlatformStats(PlatformStatsDto statsDto) async {
    try {
      final json = jsonEncode(statsDto.toJson());
      await _sharedPreferences.setString(_platformStatsCache, json);
      await setCacheTimestamp(_platformStatsCache);
    } catch (e) {
      throw CacheException('Failed to cache platform stats: $e');
    }
  }

  @override
  Future<PlatformStatsDto?> getCachedPlatformStats() async {
    try {
      if (await isCacheExpired(_platformStatsCache)) {
        await clearPlatformStatsCache();
        return null;
      }

      final json = _sharedPreferences.getString(_platformStatsCache);
      if (json == null) return null;

      final Map<String, dynamic> map = jsonDecode(json);
      return PlatformStatsDto.fromJson(map);
    } catch (e) {
      throw CacheException('Failed to get cached platform stats: $e');
    }
  }

  @override
  Future<void> clearPlatformStatsCache() async {
    try {
      await _sharedPreferences.remove(_platformStatsCache);
      await _sharedPreferences.remove('$_platformStatsCache$_timestampSuffix');
    } catch (e) {
      throw CacheException('Failed to clear platform stats cache: $e');
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      await clearReviewCache();
      await clearTutorRatingCache();
      await clearPlatformStatsCache();
    } catch (e) {
      throw CacheException('Failed to clear all cache: $e');
    }
  }

  @override
  Future<bool> isCacheExpired(String cacheKey) async {
    try {
      final timestampKey = '$cacheKey$_timestampSuffix';
      final timestamp = _sharedPreferences.getInt(timestampKey);

      if (timestamp == null) return true;

      final now = DateTime.now().millisecondsSinceEpoch;
      return (now - timestamp) > _cacheDuration;
    } catch (e) {
      // If there's an error checking the timestamp, consider it expired
      return true;
    }
  }

  @override
  Future<void> setCacheTimestamp(String cacheKey) async {
    try {
      final timestampKey = '$cacheKey$_timestampSuffix';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await _sharedPreferences.setInt(timestampKey, timestamp);
    } catch (e) {
      throw CacheException('Failed to set cache timestamp: $e');
    }
  }
}
