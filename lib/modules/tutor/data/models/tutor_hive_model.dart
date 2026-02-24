import 'package:hive/hive.dart';

part 'tutor_hive_model.g.dart';

/// Hive model for caching tutor data locally.
/// Provides offline support and faster loading of tutor information.
@HiveType(typeId: 1)
class TutorHiveModel extends HiveObject {
  TutorHiveModel({
    required this.id,
    required this.profileId,
    required this.fullName,
    required this.profileImage,
    required this.bio,
    required this.experienceYears,
    required this.hourlyRate,
    required this.languages,
    required this.subjects,
    required this.rating,
    required this.reviewCount,
    required this.verificationStatus,
    required this.isAvailable,
    required this.cachedAt,
    required this.createdAt,
    this.nextAvailableSlot,
    this.location,
    this.specialization,
    this.education,
  });

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String profileId;

  @HiveField(2)
  late String fullName;

  @HiveField(3)
  late String? profileImage;

  @HiveField(4)
  late String bio;

  @HiveField(5)
  late int experienceYears;

  @HiveField(6)
  late double hourlyRate;

  @HiveField(7)
  late List<String> languages;

  @HiveField(8)
  late List<String> subjects;

  @HiveField(9)
  late double rating;

  @HiveField(10)
  late int reviewCount;

  @HiveField(11)
  late String verificationStatus;

  @HiveField(12)
  late bool isAvailable;

  @HiveField(13)
  late DateTime cachedAt;

  @HiveField(14)
  late DateTime createdAt;

  @HiveField(15)
  late AvailabilitySlotHiveModel? nextAvailableSlot;

  @HiveField(16)
  late String? location;

  @HiveField(17)
  late String? specialization;

  @HiveField(18)
  late String? education;

  @override
  String toString() => 'TutorHiveModel(id: $id, fullName: $fullName)';
}

/// Hive model for availability slot data
@HiveType(typeId: 2)
class AvailabilitySlotHiveModel extends HiveObject {
  AvailabilitySlotHiveModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
    required this.dayOfWeek,
    this.studentId,
    this.lessonId,
    this.note,
  });

  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime startTime;

  @HiveField(2)
  late DateTime endTime;

  @HiveField(3)
  late bool isBooked;

  @HiveField(4)
  late int dayOfWeek;

  @HiveField(5)
  late String? studentId;

  @HiveField(6)
  late String? lessonId;

  @HiveField(7)
  late String? note;

  @override
  String toString() =>
      'AvailabilitySlotHiveModel(id: $id, startTime: $startTime)';
}

/// Cached search result for offline support
@HiveType(typeId: 3)
class TutorSearchCacheHiveModel extends HiveObject {
  TutorSearchCacheHiveModel({
    required this.queryKey,
    required this.tutorIds,
    required this.total,
    required this.page,
    required this.totalPages,
    required this.limit,
    required this.cachedAt,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });

  @HiveField(0)
  late String queryKey; // Hash of search parameters

  @HiveField(1)
  late List<String> tutorIds; // References to cached tutors

  @HiveField(2)
  late int total;

  @HiveField(3)
  late int page;

  @HiveField(4)
  late int totalPages;

  @HiveField(5)
  late int limit;

  @HiveField(6)
  late DateTime cachedAt;

  @HiveField(7)
  late bool hasNextPage;

  @HiveField(8)
  late bool hasPreviousPage;

  @override
  String toString() =>
      'TutorSearchCacheHiveModel(queryKey: $queryKey, page: $page)';
}
