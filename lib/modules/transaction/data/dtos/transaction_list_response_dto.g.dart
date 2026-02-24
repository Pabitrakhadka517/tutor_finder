// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionListResponseDto _$TransactionListResponseDtoFromJson(
        Map<String, dynamic> json) =>
    TransactionListResponseDto(
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => TransactionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      hasMore: json['has_more'] as bool,
    );

Map<String, dynamic> _$TransactionListResponseDtoToJson(
        TransactionListResponseDto instance) =>
    <String, dynamic>{
      'transactions': instance.transactions.map((e) => e.toJson()).toList(),
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'has_more': instance.hasMore,
    };
