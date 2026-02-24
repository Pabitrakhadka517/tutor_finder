import 'package:json_annotation/json_annotation.dart';

import 'transaction_dto.dart';

part 'transaction_list_response_dto.g.dart';

/// Data Transfer Object for transaction list API responses.
/// Handles paginated transaction lists from the backend.
@JsonSerializable(explicitToJson: true)
class TransactionListResponseDto {
  const TransactionListResponseDto({
    required this.transactions,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  @JsonKey(name: 'transactions')
  final List<TransactionDto> transactions;

  @JsonKey(name: 'total')
  final int total;

  @JsonKey(name: 'page')
  final int page;

  @JsonKey(name: 'limit')
  final int limit;

  @JsonKey(name: 'has_more')
  final bool hasMore;

  factory TransactionListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionListResponseDtoToJson(this);
}
