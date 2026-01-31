import 'package:hive/hive.dart';
import 'package:tutor_finder/features/profile/data/models/profile_model.dart';
import '../profile_local_data_source.dart';

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final Box<ProfileModel> profileBox;

  ProfileLocalDataSourceImpl({required this.profileBox});

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    await profileBox.put('cached_profile', profile);
  }

  @override
  Future<ProfileModel> getLastProfile() async {
    final profile = profileBox.get('cached_profile');
    if (profile != null) {
      return profile;
    } else {
      throw Exception('Cache Empty');
    }
  }
}
