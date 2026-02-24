// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingListResponseDto _$BookingListResponseDtoFromJson(
        Map<String, dynamic> json) =>
    BookingListResponseDto(
      bookings: (json['bookings'] as List<dynamic>)
          .map((e) => BookingDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      hasNext: json['has_next'] as bool,
      nextPage: (json['next_page'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BookingListResponseDtoToJson(
        BookingListResponseDto instance) =>
    <String, dynamic>{
      'bookings': instance.bookings,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'has_next': instance.hasNext,
      'next_page': instance.nextPage,
    };
