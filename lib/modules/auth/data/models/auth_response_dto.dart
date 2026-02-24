import 'package:json_annotation/json_annotation.dart';

import 'user_dto.dart';

part 'auth_response_dto.g.dart';

/// DTO for all auth-related API responses (login, register, refresh, /me).
///
/// The backend may return tokens & user data in several shapes, so many fields
/// are nullable. Use the `resolved*` getters to normalise across formats.
@JsonSerializable()
class AuthResponseDto {
  final String? message;

  // ── Tokens ────────────────────────────────────────────────────────────────
  final String? token;
  final String? accessToken;

  @JsonKey(name: 'access_token')
  final String? accessTokenSnake;

  final String? refreshToken;

  @JsonKey(name: 'refresh_token')
  final String? refreshTokenSnake;

  // ── User fields (flat) ────────────────────────────────────────────────────
  final String? userId;
  final String? id;

  @JsonKey(name: '_id')
  final String? mongoId;

  final String? email;
  final String? name;
  final String? role;
  final DateTime? createdAt;

  // ── Nested user object ────────────────────────────────────────────────────
  final UserDto? user;

  const AuthResponseDto({
    this.message,
    this.token,
    this.accessToken,
    this.accessTokenSnake,
    this.refreshToken,
    this.refreshTokenSnake,
    this.userId,
    this.id,
    this.mongoId,
    this.email,
    this.name,
    this.role,
    this.createdAt,
    this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseDtoToJson(this);

  // ── Normalisation getters ─────────────────────────────────────────────────

  String? get resolvedToken => token ?? accessToken ?? accessTokenSnake;

  String? get resolvedRefreshToken => refreshToken ?? refreshTokenSnake;

  String get resolvedUserId =>
      userId ?? id ?? mongoId ?? user?.resolvedId ?? '';

  String get resolvedEmail => email ?? user?.email ?? '';

  String? get resolvedName => name ?? user?.name;

  String get resolvedRole => role ?? user?.role ?? 'student';

  DateTime? get resolvedCreatedAt => createdAt ?? user?.createdAt;
}
