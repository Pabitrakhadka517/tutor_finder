import 'package:json_annotation/json_annotation.dart';

import 'tutor_dto.dart';

part 'tutor_list_response_dto.g.dart';

/// Data Transfer Object for paginated tutor list response from API.
/// Contains tutors data along with pagination metadata.
@JsonSerializable()
class TutorListResponseDto {
  const TutorListResponseDto({
    required this.data,
    required this.total,
    required this.page,
    required this.totalPages,
    required this.limit,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  @JsonKey(name: 'data')
  final List<TutorDto> data;

  @JsonKey(name: 'total')
  final int total;

  @JsonKey(name: 'page')
  final int page;

  @JsonKey(name: 'total_pages')
  final int totalPages;

  @JsonKey(name: 'limit')
  final int limit;

  @JsonKey(name: 'has_next_page')
  final bool hasNextPage;

  @JsonKey(name: 'has_previous_page')
  final bool hasPreviousPage;

  /// Creates instance from JSON
  factory TutorListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TutorListResponseDtoFromJson(json);

  /// Converts instance to JSON
  Map<String, dynamic> toJson() => _$TutorListResponseDtoToJson(this);

  @override
  String toString() => 'TutorListResponseDto(page: $page, total: $total)';
}
