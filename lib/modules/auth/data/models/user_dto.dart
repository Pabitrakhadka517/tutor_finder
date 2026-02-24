import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

/// DTO that maps the `user` object inside API responses.
///
/// Uses `json_serializable` – run `dart run build_runner build` to regenerate
/// the `*.g.dart` file after any change.
@JsonSerializable()
class UserDto {
  final String? id;

  @JsonKey(name: '_id')
  final String? mongoId;

  final String email;
  final String? name;
  final String role;
  final DateTime? createdAt;

  const UserDto({
    this.id,
    this.mongoId,
    required this.email,
    this.name,
    required this.role,
    this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  /// Returns the best available ID from the response.
  String get resolvedId => id ?? mongoId ?? '';
}
