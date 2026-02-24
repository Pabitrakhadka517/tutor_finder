import 'package:dio/dio.dart';

import '../models/profile_dto.dart';
import 'profile_remote_datasource.dart';

/// Concrete implementation of [ProfileRemoteDataSource] using Dio.
///
/// All methods throw [DioException] on failure; the repository maps these to
/// domain [ProfileFailure] types.
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;

  /// API path constants for profile endpoints.
  static const _profile = '/api/profile';
  static const _updateTheme = '/api/profile/theme';
  static const _deleteImage = '/api/profile/image';
  static const _changePassword = '/api/profile/change-password';

  ProfileRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  // ── Get Profile ───────────────────────────────────────────────────────────

  @override
  Future<ProfileDto> getProfile() async {
    final response = await _dio.get(_profile);
    return ProfileDto.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Update Profile (with multipart support) ──────────────────────────────

  @override
  Future<ProfileDto> updateProfile(FormData formData) async {
    final response = await _dio.put(
      _profile,
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
    return ProfileDto.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Update Theme ──────────────────────────────────────────────────────────

  @override
  Future<ProfileDto> updateTheme({required String theme}) async {
    final response = await _dio.patch(_updateTheme, data: {'theme': theme});
    return ProfileDto.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Delete Profile Image ──────────────────────────────────────────────────

  @override
  Future<ProfileDto> deleteProfileImage() async {
    final response = await _dio.delete(_deleteImage);
    return ProfileDto.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Change Password ───────────────────────────────────────────────────────

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _dio.patch(
      _changePassword,
      data: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );
  }
}
