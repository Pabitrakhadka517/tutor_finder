import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_cached_profile_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import '../state/profile_state.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  final GetProfileUseCase getProfileUseCase; // Remote
  final GetCachedProfileUseCase getCachedProfileUseCase; // Local
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileNotifier({
    required this.getProfileUseCase,
    required this.getCachedProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileState.initial());

  Future<void> getProfile() async {
    // 1. Start loading
    state = state.copyWith(isLoading: true, error: null);

    // 2. Try Cache First
    final cachedResult = await getCachedProfileUseCase(const NoParams());
    cachedResult.fold(
      (failure) { /* Ignore cache failure, wait for remote */ },
      (profile) {
        // If we found a cached profile, show it immediately, but keep loading true 
        // because we are fetching fresh data.
        state = state.copyWith(profile: profile, isLoading: true);
      },
    );

    // 3. Fetch Remote
    final remoteResult = await getProfileUseCase(const NoParams());
    remoteResult.fold(
      (failure) {
        // If remote fails, we stop loading.
        // If we have data from cache, we keep it but maybe show a snackbar (handled in UI via state.error).
        // If we didn't have cache, this is a hard error.
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (profile) {
        // Update with fresh data
        state = state.copyWith(isLoading: false, profile: profile, error: null);
      },
    );
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String speciality,
    required String address,
    File? image, // File object from ImagePicker
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final params = UpdateProfileParams(
      name: name,
      phone: phone,
      speciality: speciality,
      address: address,
      image: image,
    );
    final result = await updateProfileUseCase(params);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (profile) => state = state.copyWith(isLoading: false, profile: profile),
    );
  }
}
