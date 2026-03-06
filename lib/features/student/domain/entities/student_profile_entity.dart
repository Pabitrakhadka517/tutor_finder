import 'package:equatable/equatable.dart';

/// Domain entity representing a student profile.
///
/// Contains student-specific data beyond the base [User].
class StudentProfileEntity extends Equatable {
  final String id;
  final String userId;
  final String grade;
  final List<String> subjectsInterested;
  final String? school;
  final String? bio;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const StudentProfileEntity({
    required this.id,
    required this.userId,
    required this.grade,
    this.subjectsInterested = const [],
    this.school,
    this.bio,
    this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
  });

  StudentProfileEntity copyWith({
    String? id,
    String? userId,
    String? grade,
    List<String>? subjectsInterested,
    String? school,
    String? bio,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentProfileEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      grade: grade ?? this.grade,
      subjectsInterested: subjectsInterested ?? this.subjectsInterested,
      school: school ?? this.school,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    grade,
    subjectsInterested,
    school,
    bio,
    avatarUrl,
    createdAt,
    updatedAt,
  ];
}
