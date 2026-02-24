// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_booking_status_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateBookingStatusDto _$UpdateBookingStatusDtoFromJson(
        Map<String, dynamic> json) =>
    UpdateBookingStatusDto(
      status: json['status'] as String,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$UpdateBookingStatusDtoToJson(
        UpdateBookingStatusDto instance) =>
    <String, dynamic>{
      'status': instance.status,
      'reason': instance.reason,
    };
