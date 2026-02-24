import 'package:hive/hive.dart';

import '../models/profile_hive_model.dart';

/// Contract for the local (Hive) data source responsible for caching profile data.
abstract class ProfileLocalDataSource {
  /// Cache the profile data locally for offline access.
  Future<void> cacheProfile(ProfileHiveModel profile);

  /// Retrieve the cached profile, or `null` if none exists.
  Future<ProfileHiveModel?> getCachedProfile();

  /// Remove cached profile data.
  Future<void> clearProfile();
}

/// Hive-backed implementation of [ProfileLocalDataSource].
///
/// Uses the `profile_cache` box to store the current user's profile.
class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  /// Box for the cached profile – opened during DI initialisation.
  final Box<ProfileHiveModel> profileBox;

  static const _currentProfileKey = 'current_profile';

  ProfileLocalDataSourceImpl({required this.profileBox});

  // ── Profile Cache ─────────────────────────────────────────────────────────

  @override
  Future<void> cacheProfile(ProfileHiveModel profile) async {
    await profileBox.put(_currentProfileKey, profile);
  }

  @override
  Future<ProfileHiveModel?> getCachedProfile() async {
    return profileBox.get(_currentProfileKey);
  }

  @override
  Future<void> clearProfile() async {
    await profileBox.delete(_currentProfileKey);
  }
}
