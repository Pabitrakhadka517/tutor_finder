import 'package:dio/dio.dart';

import '../models/profile_dto.dart';

/// Contract for the remote (REST API) data source.
///
/// Throws exceptions on error – the repository converts them to [ProfileFailure]s.
abstract class ProfileRemoteDataSource {
  /// GET /api/profile
  Future<ProfileDto> getProfile();

  /// PUT /api/profile (supports multipart/form-data for image upload)
  Future<ProfileDto> updateProfile(FormData formData);

  /// PATCH /api/profile/theme
  Future<ProfileDto> updateTheme({required String theme});

  /// DELETE /api/profile/image
  Future<ProfileDto> deleteProfileImage();

  /// PATCH /api/profile/change-password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}
