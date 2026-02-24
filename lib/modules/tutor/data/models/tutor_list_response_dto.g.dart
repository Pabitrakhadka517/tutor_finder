// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TutorListResponseDto _$TutorListResponseDtoFromJson(
        Map<String, dynamic> json) =>
    TutorListResponseDto(
      data: (json['data'] as List<dynamic>)
          .map((e) => TutorDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      hasNextPage: json['has_next_page'] as bool,
      hasPreviousPage: json['has_previous_page'] as bool,
    );

Map<String, dynamic> _$TutorListResponseDtoToJson(
        TutorListResponseDto instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
      'page': instance.page,
      'total_pages': instance.totalPages,
      'limit': instance.limit,
      'has_next_page': instance.hasNextPage,
      'has_previous_page': instance.hasPreviousPage,
    };
