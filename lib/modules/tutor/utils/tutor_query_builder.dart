/// Query parameter builder utility for converting search parameters to HTTP query parameters.
/// Provides type-safe conversion from domain entities to API-compatible format.

import '../domain/entities/tutor_search_params.dart';

/// Builds query parameters for tutor search API calls.
/// Converts [TutorSearchParams] to Map<String, String> for HTTP requests.
class TutorQueryBuilder {
  /// Builds query parameters from search parameters
  static Map<String, String> buildSearchQuery(
    TutorSearchParams params, {
    int page = 1,
    int limit = 20,
  }) {
    final query = <String, String>{};

    // Pagination parameters
    query['page'] = page.toString();
    query['limit'] = limit.toString();

    // Search text
    if (params.search != null && params.search!.isNotEmpty) {
      query['q'] = params.search!;
    }

    // Subjects filter
    if (params.subjects.isNotEmpty) {
      query['subjects'] = params.subjects.join(',');
    }

    // Price range
    if (params.minPrice != null) {
      query['min_price'] = params.minPrice!.toString();
    }
    if (params.maxPrice != null) {
      query['max_price'] = params.maxPrice!.toString();
    }

    // Rating filter
    if (params.minRating != null) {
      query['min_rating'] = params.minRating!.toString();
    }

    // Experience filter
    if (params.minExperienceYears != null) {
      query['min_experience'] = params.minExperienceYears!.toString();
    }

    // Location filter
    if (params.location != null && params.location!.isNotEmpty) {
      query['location'] = params.location!;
    }

    // Languages filter
    if (params.languages.isNotEmpty) {
      query['languages'] = params.languages.join(',');
    }

    // Boolean filters
    if (params.verifiedOnly) {
      query['verified_only'] = 'true';
    }
    if (params.onlineOnly) {
      query['online_only'] = 'true';
    }
    if (params.inPersonOnly) {
      query['in_person_only'] = 'true';
    }
    if (params.availableOnly) {
      query['available_only'] = 'true';
    }

    // Sorting
    query['sort_by'] = params.sortBy.apiValue;

    return query;
  }

  /// Builds query parameters for tutor detail API call
  static Map<String, String> buildDetailQuery(
    String tutorId, {
    bool includeAvailability = false,
    bool includeReviews = false,
  }) {
    final query = <String, String>{};

    if (includeAvailability) {
      query['include_availability'] = 'true';
    }

    if (includeReviews) {
      query['include_reviews'] = 'true';
    }

    return query;
  }

  /// Builds query parameters for availability lookup
  static Map<String, String> buildAvailabilityQuery(
    String tutorId,
    DateTime date, {
    int? days,
  }) {
    final query = <String, String>{
      'tutor_id': tutorId,
      'date': _formatDate(date),
    };

    if (days != null && days > 1) {
      query['days'] = days.toString();
    }

    return query;
  }

  /// Builds request body for availability update
  static Map<String, dynamic> buildAvailabilityUpdateBody(
    List<Map<String, dynamic>> slots,
  ) {
    return {
      'availability_slots': slots
          .map(
            (slot) => {
              'id': slot['id'],
              'start_time': slot['start_time'],
              'end_time': slot['end_time'],
              'is_available': slot['is_available'] ?? true,
              'note': slot['note'],
            },
          )
          .toList(),
    };
  }

  /// Builds query parameters for tutor verification
  static Map<String, String> buildVerificationQuery(
    String tutorId, {
    String? verificationType,
  }) {
    final query = <String, String>{'tutor_id': tutorId};

    if (verificationType != null) {
      query['verification_type'] = verificationType;
    }

    return query;
  }

  // ── Helper Methods ─────────────────────────────────────────────────────

  /// Formats date to API-compatible format (YYYY-MM-DD)
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Formats datetime to API-compatible format (ISO 8601)
  static String formatDateTime(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Creates cache key for search results
  static String createSearchCacheKey(TutorSearchParams params, int page) {
    final keyParts = <String>[];

    keyParts.add('search');
    if (params.search != null && params.search!.isNotEmpty)
      keyParts.add('q=${params.search}');
    if (params.subjects.isNotEmpty)
      keyParts.add('subjects=${params.subjects.join(',')}');
    if (params.minPrice != null) keyParts.add('minPrice=${params.minPrice}');
    if (params.maxPrice != null) keyParts.add('maxPrice=${params.maxPrice}');
    if (params.minRating != null) keyParts.add('minRating=${params.minRating}');
    if (params.minExperienceYears != null)
      keyParts.add('minExp=${params.minExperienceYears}');
    if (params.location != null) keyParts.add('location=${params.location}');
    if (params.languages.isNotEmpty)
      keyParts.add('languages=${params.languages.join(',')}');
    if (params.verifiedOnly) keyParts.add('verified=true');
    if (params.onlineOnly) keyParts.add('online=true');
    if (params.inPersonOnly) keyParts.add('inPerson=true');
    if (params.availableOnly) keyParts.add('available=true');
    keyParts.add('sortBy=${params.sortBy.apiValue}');
    keyParts.add('page=$page');

    return keyParts.join('&');
  }

  /// Creates cache key for tutor detail
  static String createDetailCacheKey(
    String tutorId, {
    bool includeAvailability = false,
    bool includeReviews = false,
  }) {
    final keyParts = ['detail', 'tutor=$tutorId'];

    if (includeAvailability) keyParts.add('availability=true');
    if (includeReviews) keyParts.add('reviews=true');

    return keyParts.join('&');
  }

  /// Creates cache key for availability data
  static String createAvailabilityCacheKey(String tutorId, DateTime date) {
    return 'availability&tutor=$tutorId&date=${_formatDate(date)}';
  }
}

/// Example usage and API endpoint mapping
class TutorApiEndpoints {
  static const String baseUrl = '/tutors';

  // Search endpoints
  static const String search = '$baseUrl/search';
  static const String detail = '$baseUrl/{id}';
  static const String availability = '$baseUrl/{id}/availability';

  // Management endpoints (for tutors)
  static const String updateAvailability = '$baseUrl/me/availability';
  static const String verify = '$baseUrl/me/verify';

  /// Example: GET /tutors/search?q=math&subjects=Mathematics,Physics&page=1&limit=20
  static String buildSearchUrl(
    TutorSearchParams params, {
    int page = 1,
    int limit = 20,
  }) {
    final query = TutorQueryBuilder.buildSearchQuery(
      params,
      page: page,
      limit: limit,
    );
    final queryString = query.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return '$search?$queryString';
  }

  /// Example: GET /tutors/123?include_availability=true&include_reviews=true
  static String buildDetailUrl(
    String tutorId, {
    bool includeAvailability = false,
    bool includeReviews = false,
  }) {
    final url = detail.replaceFirst('{id}', tutorId);
    final query = TutorQueryBuilder.buildDetailQuery(
      tutorId,
      includeAvailability: includeAvailability,
      includeReviews: includeReviews,
    );

    if (query.isEmpty) return url;

    final queryString = query.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return '$url?$queryString';
  }

  /// Example: GET /tutors/123/availability?date=2024-01-15&days=7
  static String buildAvailabilityUrl(
    String tutorId,
    DateTime date, {
    int? days,
  }) {
    final url = availability.replaceFirst('{id}', tutorId);
    final query = TutorQueryBuilder.buildAvailabilityQuery(
      tutorId,
      date,
      days: days,
    );
    final queryString = query.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return '$url?$queryString';
  }
}
