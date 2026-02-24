import 'package:equatable/equatable.dart';

/// Search and filtering parameters for tutor discovery.
/// Handles all possible search criteria including pagination.
class TutorSearchParams extends Equatable {
  const TutorSearchParams({
    this.search,
    this.subject,
    this.subjects = const [],
    this.language,
    this.languages = const [],
    this.minPrice,
    this.maxPrice,
    this.availability,
    this.verifiedOnly = false,
    this.sortBy = TutorSortBy.newest,
    this.page = 1,
    this.limit = 10,
    this.location,
    this.minExperience,
    this.minExperienceYears,
    this.minRating,
    this.onlineOnly = false,
    this.inPersonOnly = false,
    this.availableOnly = false,
  });

  /// Search query for tutor name or bio
  final String? search;

  /// Filter by specific subject
  final String? subject;

  /// Filter by multiple subjects
  final List<String> subjects;

  /// Filter by language spoken
  final String? language;

  /// Filter by multiple languages
  final List<String> languages;

  /// Minimum hourly rate
  final double? minPrice;

  /// Maximum hourly rate
  final double? maxPrice;

  /// Filter by availability (show only available tutors)
  final bool? availability;

  /// Show only verified tutors
  final bool verifiedOnly;

  /// Sorting criteria
  final TutorSortBy sortBy;

  /// Page number for pagination (1-based)
  final int page;

  /// Number of items per page
  final int limit;

  /// Filter by location (optional)
  final String? location;

  /// Minimum years of experience
  final int? minExperience;

  /// Minimum years of experience (alternative field)
  final int? minExperienceYears;

  /// Minimum rating (0.0 to 5.0)
  final double? minRating;

  /// Show only online tutors
  final bool onlineOnly;

  /// Show only in-person tutors
  final bool inPersonOnly;

  /// Show only currently available tutors
  final bool availableOnly;

  /// Check if any filters are active
  bool get hasFilters =>
      subject != null ||
      subjects.isNotEmpty ||
      language != null ||
      languages.isNotEmpty ||
      minPrice != null ||
      maxPrice != null ||
      availability != null ||
      verifiedOnly ||
      location != null ||
      minExperience != null ||
      minExperienceYears != null ||
      minRating != null ||
      onlineOnly ||
      inPersonOnly ||
      availableOnly;

  /// Check if search query is active
  bool get hasSearch => search != null && search!.trim().isNotEmpty;

  /// Check if this is the first page
  bool get isFirstPage => page <= 1;

  /// Get next page parameters
  TutorSearchParams get nextPage => copyWith(page: page + 1);

  /// Reset to first page (useful when filters change)
  TutorSearchParams get firstPage => copyWith(page: 1);

  /// Clear all filters but keep search and pagination
  TutorSearchParams get clearFilters {
    return TutorSearchParams(
      search: search,
      page: page,
      limit: limit,
      sortBy: sortBy,
    );
  }

  /// Convert to query map for API calls
  Map<String, dynamic> toQueryMap() {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sort': sortBy.apiValue,
    };

    if (hasSearch) query['search'] = search!.trim();
    if (subject != null) query['subject'] = subject;
    if (subjects.isNotEmpty) query['subjects'] = subjects.join(',');
    if (language != null) query['language'] = language;
    if (languages.isNotEmpty) query['languages'] = languages.join(',');
    if (minPrice != null) query['minPrice'] = minPrice;
    if (maxPrice != null) query['maxPrice'] = maxPrice;
    if (availability != null) query['availability'] = availability;
    if (verifiedOnly) query['verifiedOnly'] = verifiedOnly;
    if (location != null) query['location'] = location;
    if (minExperience != null) query['minExperience'] = minExperience;
    if (minExperienceYears != null)
      query['minExperienceYears'] = minExperienceYears;
    if (minRating != null) query['minRating'] = minRating;
    if (onlineOnly) query['onlineOnly'] = onlineOnly;
    if (inPersonOnly) query['inPersonOnly'] = inPersonOnly;
    if (availableOnly) query['availableOnly'] = availableOnly;

    return query;
  }

  /// Create search params from query map (useful for URL parsing)
  factory TutorSearchParams.fromQueryMap(Map<String, dynamic> query) {
    return TutorSearchParams(
      search: query['search']?.toString(),
      subject: query['subject']?.toString(),
      subjects: query['subjects']?.toString().split(',') ?? [],
      language: query['language']?.toString(),
      languages: query['languages']?.toString().split(',') ?? [],
      minPrice: double.tryParse(query['minPrice']?.toString() ?? ''),
      maxPrice: double.tryParse(query['maxPrice']?.toString() ?? ''),
      availability: query['availability'] == 'true'
          ? true
          : query['availability'] == 'false'
          ? false
          : null,
      verifiedOnly: query['verifiedOnly'] == 'true',
      sortBy: TutorSortBy.fromApiValue(query['sort']?.toString() ?? 'newest'),
      page: int.tryParse(query['page']?.toString() ?? '1') ?? 1,
      limit: int.tryParse(query['limit']?.toString() ?? '10') ?? 10,
      location: query['location']?.toString(),
      minExperience: int.tryParse(query['minExperience']?.toString() ?? ''),
      minExperienceYears: int.tryParse(
        query['minExperienceYears']?.toString() ?? '',
      ),
      minRating: double.tryParse(query['minRating']?.toString() ?? ''),
      onlineOnly: query['onlineOnly'] == 'true',
      inPersonOnly: query['inPersonOnly'] == 'true',
      availableOnly: query['availableOnly'] == 'true',
    );
  }

  /// Creates a copy with modified fields
  TutorSearchParams copyWith({
    String? search,
    String? subject,
    List<String>? subjects,
    String? language,
    List<String>? languages,
    double? minPrice,
    double? maxPrice,
    bool? availability,
    bool? verifiedOnly,
    TutorSortBy? sortBy,
    int? page,
    int? limit,
    String? location,
    int? minExperience,
    int? minExperienceYears,
    double? minRating,
    bool? onlineOnly,
    bool? inPersonOnly,
    bool? availableOnly,
  }) {
    return TutorSearchParams(
      search: search ?? this.search,
      subject: subject ?? this.subject,
      subjects: subjects ?? this.subjects,
      language: language ?? this.language,
      languages: languages ?? this.languages,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      availability: availability ?? this.availability,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      sortBy: sortBy ?? this.sortBy,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      location: location ?? this.location,
      minExperience: minExperience ?? this.minExperience,
      minExperienceYears: minExperienceYears ?? this.minExperienceYears,
      minRating: minRating ?? this.minRating,
      onlineOnly: onlineOnly ?? this.onlineOnly,
      inPersonOnly: inPersonOnly ?? this.inPersonOnly,
      availableOnly: availableOnly ?? this.availableOnly,
    );
  }

  @override
  List<Object?> get props => [
    search,
    subject,
    subjects,
    language,
    languages,
    minPrice,
    maxPrice,
    availability,
    verifiedOnly,
    sortBy,
    page,
    limit,
    location,
    minExperience,
    minExperienceYears,
    minRating,
    onlineOnly,
    inPersonOnly,
    availableOnly,
  ];

  @override
  String toString() =>
      'TutorSearchParams(search: $search, page: $page, filters: $hasFilters)';
}

/// Sorting options for tutor search results
enum TutorSortBy {
  newest,
  priceAsc,
  priceDesc,
  rating,
  experience,
  alphabetical;

  /// API value for this sort option
  String get apiValue {
    switch (this) {
      case TutorSortBy.newest:
        return 'newest';
      case TutorSortBy.priceAsc:
        return 'price_asc';
      case TutorSortBy.priceDesc:
        return 'price_desc';
      case TutorSortBy.rating:
        return 'rating';
      case TutorSortBy.experience:
        return 'experience';
      case TutorSortBy.alphabetical:
        return 'alphabetical';
    }
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case TutorSortBy.newest:
        return 'Newest First';
      case TutorSortBy.priceAsc:
        return 'Price: Low to High';
      case TutorSortBy.priceDesc:
        return 'Price: High to Low';
      case TutorSortBy.rating:
        return 'Highest Rated';
      case TutorSortBy.experience:
        return 'Most Experienced';
      case TutorSortBy.alphabetical:
        return 'Alphabetical';
    }
  }

  /// Create from API value
  static TutorSortBy fromApiValue(String value) {
    switch (value) {
      case 'newest':
        return TutorSortBy.newest;
      case 'price_asc':
        return TutorSortBy.priceAsc;
      case 'price_desc':
        return TutorSortBy.priceDesc;
      case 'rating':
        return TutorSortBy.rating;
      case 'experience':
        return TutorSortBy.experience;
      case 'alphabetical':
        return TutorSortBy.alphabetical;
      default:
        return TutorSortBy.newest;
    }
  }
}
