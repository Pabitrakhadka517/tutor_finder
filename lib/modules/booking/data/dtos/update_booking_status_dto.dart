import 'package:json_annotation/json_annotation.dart';

import '../../domain/usecases/update_booking_status_usecase.dart';

part 'update_booking_status_dto.g.dart';

/// DTO for update booking status API requests.
@JsonSerializable()
class UpdateBookingStatusDto {
  const UpdateBookingStatusDto({required this.status, this.reason});

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'reason')
  final String? reason;

  /// Factory constructor for JSON deserialization
  factory UpdateBookingStatusDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateBookingStatusDtoFromJson(json);

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() => _$UpdateBookingStatusDtoToJson(this);

  /// Create from use case parameters
  factory UpdateBookingStatusDto.fromParams(UpdateBookingStatusParams params) {
    return UpdateBookingStatusDto(
      status: params.newStatus.value,
      reason: params.reason,
    );
  }

  @override
  String toString() {
    return 'UpdateBookingStatusDto(status: $status, reason: $reason)';
  }
}
