import '../../domain/entities/study_resource_entity.dart';

class StudyResourceModel extends StudyResourceEntity {
  const StudyResourceModel({
    required super.id,
    required super.title,
    required super.category,
    required super.type,
    required super.url,
    super.size,
    super.duration,
    required super.tutorId,
    super.tutorName,
    super.isPublic,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StudyResourceModel.fromJson(Map<String, dynamic> json) {
    // Parse tutor (can be object or string)
    String tutorId = '';
    String? tutorName;
    if (json['tutor'] is Map) {
      final t = json['tutor'] as Map<String, dynamic>;
      tutorId = t['_id']?.toString() ?? t['id']?.toString() ?? '';
      tutorName = t['fullName']?.toString();
    } else {
      tutorId = json['tutor']?.toString() ?? '';
    }

    return StudyResourceModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      type: json['type']?.toString() ?? 'OTHER',
      url: json['url']?.toString() ?? '',
      size: json['size']?.toString(),
      duration: json['duration']?.toString(),
      tutorId: tutorId,
      tutorName: tutorName,
      isPublic: json['isPublic'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
