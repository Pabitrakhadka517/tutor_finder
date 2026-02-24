import 'package:equatable/equatable.dart';

class StudyResourceEntity extends Equatable {
  final String id;
  final String title;
  final String category;
  final String type; // PDF, MODULE, OTHER
  final String url;
  final String? size;
  final String? duration;
  final String tutorId;
  final String? tutorName;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudyResourceEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    required this.url,
    this.size,
    this.duration,
    required this.tutorId,
    this.tutorName,
    this.isPublic = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPdf => type == 'PDF';
  bool get isModule => type == 'MODULE';

  @override
  List<Object?> get props => [id, title, type, category];
}
