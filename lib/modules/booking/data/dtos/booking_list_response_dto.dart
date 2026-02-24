import 'package:json_annotation/json_annotation.dart';

import 'booking_dto.dart';

part 'booking_list_response_dto.g.dart';

/// DTO for paginated booking list API responses.
@JsonSerializable()
class BookingListResponseDto {
  const BookingListResponseDto({
    required this.bookings,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    this.nextPage,
  });

  @JsonKey(name: 'bookings')
  final List<BookingDto> bookings;

  @JsonKey(name: 'total')
  final int total;

  @JsonKey(name: 'page')
  final int page;

  @JsonKey(name: 'limit')
  final int limit;

  @JsonKey(name: 'has_next')
  final bool hasNext;

  @JsonKey(name: 'next_page')
  final int? nextPage;

  /// Factory constructor for JSON deserialization
  factory BookingListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$BookingListResponseDtoFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$BookingListResponseDtoToJson(this);

  @override
  String toString() {
    return 'BookingListResponseDto(total: $total, page: $page, limit: $limit, hasNext: $hasNext)';
  }
}
