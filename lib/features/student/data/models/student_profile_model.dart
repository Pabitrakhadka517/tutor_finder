import '../../domain/entities/student_profile_entity.dart';

/// Data model for StudentProfileEntity, adding JSON serialization.
class StudentProfileModel extends StudentProfileEntity {
  const StudentProfileModel({
    required super.id,
    required super.userId,
    required super.grade,
    super.subjectsInterested,
    super.school,
    super.bio,
    super.avatarUrl,
    required super.createdAt,
    super.updatedAt,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? json['user'] ?? '',
      grade: json['grade'] ?? '',
      subjectsInterested: _toStringList(
        json['subjectsInterested'] ?? json['subjects'],
      ),
      school: json['school'],
      bio: json['bio'],
      avatarUrl: json['avatarUrl'] ?? json['profileImage'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'grade': grade,
      'subjectsInterested': subjectsInterested,
      if (school != null) 'school': school,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }

  factory StudentProfileModel.fromEntity(StudentProfileEntity entity) {
    return StudentProfileModel(
      id: entity.id,
      userId: entity.userId,
      grade: entity.grade,
      subjectsInterested: entity.subjectsInterested,
      school: entity.school,
      bio: entity.bio,
      avatarUrl: entity.avatarUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}
