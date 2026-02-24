// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TutorHiveModelAdapter extends TypeAdapter<TutorHiveModel> {
  @override
  final int typeId = 1;

  @override
  TutorHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TutorHiveModel(
      id: fields[0] as String,
      profileId: fields[1] as String,
      fullName: fields[2] as String,
      profileImage: fields[3] as String?,
      bio: fields[4] as String,
      experienceYears: fields[5] as int,
      hourlyRate: fields[6] as double,
      languages: (fields[7] as List).cast<String>(),
      subjects: (fields[8] as List).cast<String>(),
      rating: fields[9] as double,
      reviewCount: fields[10] as int,
      verificationStatus: fields[11] as String,
      isAvailable: fields[12] as bool,
      cachedAt: fields[13] as DateTime,
      createdAt: fields[14] as DateTime,
      nextAvailableSlot: fields[15] as AvailabilitySlotHiveModel?,
      location: fields[16] as String?,
      specialization: fields[17] as String?,
      education: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TutorHiveModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.profileId)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.profileImage)
      ..writeByte(4)
      ..write(obj.bio)
      ..writeByte(5)
      ..write(obj.experienceYears)
      ..writeByte(6)
      ..write(obj.hourlyRate)
      ..writeByte(7)
      ..write(obj.languages)
      ..writeByte(8)
      ..write(obj.subjects)
      ..writeByte(9)
      ..write(obj.rating)
      ..writeByte(10)
      ..write(obj.reviewCount)
      ..writeByte(11)
      ..write(obj.verificationStatus)
      ..writeByte(12)
      ..write(obj.isAvailable)
      ..writeByte(13)
      ..write(obj.cachedAt)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.nextAvailableSlot)
      ..writeByte(16)
      ..write(obj.location)
      ..writeByte(17)
      ..write(obj.specialization)
      ..writeByte(18)
      ..write(obj.education);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TutorHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AvailabilitySlotHiveModelAdapter
    extends TypeAdapter<AvailabilitySlotHiveModel> {
  @override
  final int typeId = 2;

  @override
  AvailabilitySlotHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AvailabilitySlotHiveModel(
      id: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime,
      isBooked: fields[3] as bool,
      dayOfWeek: fields[4] as int,
      studentId: fields[5] as String?,
      lessonId: fields[6] as String?,
      note: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AvailabilitySlotHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.isBooked)
      ..writeByte(4)
      ..write(obj.dayOfWeek)
      ..writeByte(5)
      ..write(obj.studentId)
      ..writeByte(6)
      ..write(obj.lessonId)
      ..writeByte(7)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailabilitySlotHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TutorSearchCacheHiveModelAdapter
    extends TypeAdapter<TutorSearchCacheHiveModel> {
  @override
  final int typeId = 3;

  @override
  TutorSearchCacheHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TutorSearchCacheHiveModel(
      queryKey: fields[0] as String,
      tutorIds: (fields[1] as List).cast<String>(),
      total: fields[2] as int,
      page: fields[3] as int,
      totalPages: fields[4] as int,
      limit: fields[5] as int,
      cachedAt: fields[6] as DateTime,
      hasNextPage: fields[7] as bool,
      hasPreviousPage: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TutorSearchCacheHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.queryKey)
      ..writeByte(1)
      ..write(obj.tutorIds)
      ..writeByte(2)
      ..write(obj.total)
      ..writeByte(3)
      ..write(obj.page)
      ..writeByte(4)
      ..write(obj.totalPages)
      ..writeByte(5)
      ..write(obj.limit)
      ..writeByte(6)
      ..write(obj.cachedAt)
      ..writeByte(7)
      ..write(obj.hasNextPage)
      ..writeByte(8)
      ..write(obj.hasPreviousPage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TutorSearchCacheHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
