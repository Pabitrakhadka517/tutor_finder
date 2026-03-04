import 'dart:io';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(Map<String, dynamic> fields, File? file);
  Future<ProfileModel> updateTheme(String theme);
  Future<ProfileModel> deleteProfileImage();
}
