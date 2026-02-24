import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/delete_profile_image_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/update_theme_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// The single BLoC that manages the entire profile flow.
///
/// Receives [ProfileEvent]s from the UI, delegates to appropriate use cases,
/// and emits [ProfileState]s that the UI observes via `BlocBuilder`/`BlocListener`.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UpdateThemeUseCase _updateThemeUseCase;
  final DeleteProfileImageUseCase _deleteProfileImageUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;

  ProfileBloc({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required UpdateThemeUseCase updateThemeUseCase,
    required DeleteProfileImageUseCase deleteProfileImageUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
  }) : _getProfileUseCase = getProfileUseCase,
       _updateProfileUseCase = updateProfileUseCase,
       _updateThemeUseCase = updateThemeUseCase,
       _deleteProfileImageUseCase = deleteProfileImageUseCase,
       _changePasswordUseCase = changePasswordUseCase,
       super(const ProfileState.initial()) {
    on<LoadProfileRequested>(_onLoadProfileRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<UpdateThemeRequested>(_onUpdateThemeRequested);
    on<DeleteImageRequested>(_onDeleteImageRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<RefreshProfileRequested>(_onRefreshProfileRequested);
  }

  // ── Load Profile ──────────────────────────────────────────────────────────

  Future<void> _onLoadProfileRequested(
    LoadProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileState.loading(profile: state.profile));

    if (event.loadCachedFirst) {
      // Try cached first for quick display
      final cachedResult = await _getProfileUseCase.getCached();
      cachedResult.fold(
        (failure) {
          // No cached profile, continue with remote fetch
        },
        (profile) {
          emit(ProfileState.loaded(profile));
        },
      );
    }

    // Fetch from remote
    final result = await _getProfileUseCase();
    result.fold((failure) {
      // If we had cached data and remote failed, keep cached with error message
      if (state.profile != null) {
        emit(ProfileState.error(failure.message, profile: state.profile));
      } else {
        emit(ProfileState.error(failure.message));
      }
    }, (profile) => emit(ProfileState.loaded(profile)));
  }

  // ── Update Profile ────────────────────────────────────────────────────────

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) {
      emit(const ProfileState.error('No profile loaded to update.'));
      return;
    }

    emit(ProfileState.updating(state.profile!));

    final params = UpdateProfileParams(
      name: event.name,
      phone: event.phone,
      speciality: event.speciality,
      address: event.address,
      profileImagePath: event.profileImagePath,
      theme: event.theme,
      tutorFields: event.tutorFields,
    );

    final result = await _updateProfileUseCase(params);

    result.fold(
      (failure) =>
          emit(ProfileState.error(failure.message, profile: state.profile)),
      (profile) => emit(ProfileState.loaded(profile)),
    );
  }

  // ── Update Theme ──────────────────────────────────────────────────────────

  Future<void> _onUpdateThemeRequested(
    UpdateThemeRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) {
      emit(const ProfileState.error('No profile loaded to update theme.'));
      return;
    }

    emit(ProfileState.updating(state.profile!));

    final params = UpdateThemeParams(theme: event.theme);
    final result = await _updateThemeUseCase(params);

    result.fold(
      (failure) =>
          emit(ProfileState.error(failure.message, profile: state.profile)),
      (profile) => emit(ProfileState.themeUpdated(profile)),
    );
  }

  // ── Delete Profile Image ──────────────────────────────────────────────────

  Future<void> _onDeleteImageRequested(
    DeleteImageRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) {
      emit(const ProfileState.error('No profile loaded to delete image.'));
      return;
    }

    emit(ProfileState.updating(state.profile!));

    final result = await _deleteProfileImageUseCase();

    result.fold(
      (failure) =>
          emit(ProfileState.error(failure.message, profile: state.profile)),
      (profile) => emit(ProfileState.imageDeleted(profile)),
    );
  }

  // ── Change Password ───────────────────────────────────────────────────────

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) {
      emit(const ProfileState.error('No profile loaded.'));
      return;
    }

    emit(ProfileState.updating(state.profile!));

    final params = ChangePasswordParams(
      oldPassword: event.oldPassword,
      newPassword: event.newPassword,
    );

    final result = await _changePasswordUseCase(params);

    result.fold(
      (failure) =>
          emit(ProfileState.error(failure.message, profile: state.profile)),
      (_) => emit(ProfileState.passwordChanged(state.profile!)),
    );
  }

  // ── Refresh Profile ───────────────────────────────────────────────────────

  Future<void> _onRefreshProfileRequested(
    RefreshProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // Don't show loading for refresh, just fetch silently
    final result = await _getProfileUseCase();

    result.fold(
      (failure) =>
          emit(ProfileState.error(failure.message, profile: state.profile)),
      (profile) => emit(ProfileState.loaded(profile)),
    );
  }
}
