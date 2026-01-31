import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tutor_finder/core/api/api_client.dart';
import 'package:tutor_finder/core/api/api_endpoints.dart';
import 'package:tutor_finder/features/profile/data/models/profile_model.dart';

import '../profile_remote_data_source.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getProfile);

      // Backend returns the profile directly (not nested in a 'profile' key for GET)
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  @override
  Future<ProfileModel> updateProfile(
    Map<String, String> fields,
    File? file,
  ) async {
    try {
      String fileName = file != null
          ? file.path.split(RegExp(r'[/\\]')).last
          : "";

      FormData formData = FormData.fromMap({
        ...fields,
        if (file != null)
          "profileImage": await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ),
      });

      final response = await apiClient.put(
        ApiEndpoints.updateProfile,
        data: formData,
      );

      // Backend returns { message: "...", profile: {...} } for PUT
      if (response.data is Map && response.data.containsKey('profile')) {
        return ProfileModel.fromJson(response.data['profile']);
      }

      // Fallback to direct parsing
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
