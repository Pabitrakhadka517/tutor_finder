import 'package:hive/hive.dart';

import '../../domain/entities/booking_entity.dart';
import '../../domain/enums/booking_status.dart';
import '../../domain/enums/payment_status.dart';

part 'booking_hive_model.g.dart';

/// Hive model for local storage of booking data.
/// Includes caching metadata for cache management.
@HiveType(typeId: 1) // Make sure this doesn't conflict with other Hive types
class BookingHiveModel extends HiveObject {
  BookingHiveModel({
    required this.id,
    required this.studentId,
    required this.tutorId,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    this.notes,
    this.sessionNotes,
    this.cancellationReason,
    this.updatedAt,
    DateTime? cachedAt,
  }) : cachedAt = cachedAt ?? DateTime.now();

  @HiveField(0)
  String id;

  @HiveField(1)
  String studentId;

  @HiveField(2)
  String tutorId;

  @HiveField(3)
  DateTime startTime;

  @HiveField(4)
  DateTime endTime;

  @HiveField(5)
  double price;

  @HiveField(6)
  String status;

  @HiveField(7)
  String paymentStatus;

  @HiveField(8)
  String? notes;

  @HiveField(9)
  String? sessionNotes;

  @HiveField(10)
  String? cancellationReason;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  DateTime? updatedAt;

  // Cache metadata
  @HiveField(13)
  DateTime cachedAt;

  /// Convert to domain entity
  BookingEntity toEntity() {
    return BookingEntity(
      id: id,
      studentId: studentId,
      tutorId: tutorId,
      startTime: startTime,
      endTime: endTime,
      price: price,
      status: BookingStatus.fromString(status),
      paymentStatus: PaymentStatus.fromString(paymentStatus),
      notes: notes,
      sessionNotes: sessionNotes,
      cancellationReason: cancellationReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory BookingHiveModel.fromEntity(BookingEntity entity) {
    return BookingHiveModel(
      id: entity.id,
      studentId: entity.studentId,
      tutorId: entity.tutorId,
      startTime: entity.startTime,
      endTime: entity.endTime,
      price: entity.price,
      status: entity.status.value,
      paymentStatus: entity.paymentStatus.value,
      notes: entity.notes,
      sessionNotes: entity.sessionNotes,
      cancellationReason: entity.cancellationReason,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Check if cached data is expired
  bool isExpired([Duration? maxAge]) {
    final age = maxAge ?? const Duration(hours: 1); // Default 1 hour expiration
    return DateTime.now().difference(cachedAt) > age;
  }

  /// Update cached timestamp
  void refreshCache() {
    cachedAt = DateTime.now();
  }

  @override
  String toString() {
    return 'BookingHiveModel(id: $id, status: $status, cachedAt: $cachedAt)';
  }
}
