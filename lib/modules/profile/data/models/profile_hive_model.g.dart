// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileHiveModelAdapter extends TypeAdapter<ProfileHiveModel> {
  @override
  final int typeId = 11;

  @override
  ProfileHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfileHiveModel(
      id: fields[0] as String,
      email: fields[1] as String,
      role: fields[2] as String,
      name: fields[3] as String?,
      phone: fields[4] as String?,
      speciality: fields[5] as String?,
      address: fields[6] as String?,
      profileImage: fields[7] as String?,
      theme: fields[8] as String?,
      verificationStatus: fields[9] as String?,
      createdAt: fields[10] as String?,
      bio: fields[11] as String?,
      hourlyRate: fields[12] as double?,
      experienceYears: fields[13] as int?,
      subjects: (fields[14] as List?)?.cast<String>(),
      languages: (fields[15] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProfileHiveModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.speciality)
      ..writeByte(6)
      ..write(obj.address)
      ..writeByte(7)
      ..write(obj.profileImage)
      ..writeByte(8)
      ..write(obj.theme)
      ..writeByte(9)
      ..write(obj.verificationStatus)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.bio)
      ..writeByte(12)
      ..write(obj.hourlyRate)
      ..writeByte(13)
      ..write(obj.experienceYears)
      ..writeByte(14)
      ..write(obj.subjects)
      ..writeByte(15)
      ..write(obj.languages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
