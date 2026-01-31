import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:tutor_finder/features/profile/data/models/profile_model.dart';
import '../profile_local_data_source.dart';

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final Box<ProfileModel> profileBox;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ProfileLocalDataSourceImpl({required this.profileBox});

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    // Cache using the specific user ID as key
    if (profile.id.isNotEmpty) {
      try {
        await profileBox.put(profile.id, profile);
        print('SUCCESSFULLY CACHED PROFILE FOR ID: ${profile.id}');
      } catch (e) {
        print('ERROR CACHING PROFILE: $e');
        rethrow;
      }
    } else {
      print('WARNING: PROFILE ID IS EMPTY, CANNOT CACHE');
    }
  }

  @override
  Future<ProfileModel> getLastProfile() async {
    // Get current user ID from secure storage (saved during login)
    final userId = await _secureStorage.read(key: 'user_id');

    if (userId != null) {
      final profile = profileBox.get(userId);
      if (profile != null) {
        return profile;
      }
    }

    throw Exception('Cache Empty');
  }
}
