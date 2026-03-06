import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/activity_item.dart';

part 'activity_item_dto.g.dart';

@JsonSerializable()
class ActivityItemDto {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const ActivityItemDto({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  factory ActivityItemDto.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityItemDtoToJson(this);

  ActivityItem toDomain() => ActivityItem(
    id: id,
    type: type,
    title: title,
    description: description,
    timestamp: timestamp,
    metadata: metadata ?? {},
  );

  factory ActivityItemDto.fromDomain(ActivityItem entity) => ActivityItemDto(
    id: entity.id,
    type: entity.type,
    title: entity.title,
    description: entity.description,
    timestamp: entity.timestamp,
    metadata: Map.from(entity.metadata),
  );
}
