import 'package:equatable/equatable.dart';

import '../../domain/entities/profile_entity.dart';

/// Possible high-level statuses for the profile flow.
enum ProfileStatus {
  /// No profile action has been performed yet.
  initial,

  /// Loading profile data.
  loading,

  /// Profile is loaded and available.
  loaded,

  /// Profile is being updated (show loading indicator on update operations).
  updating,

  /// A non-fatal error occurred.
  error,

  /// Password was changed successfully.
  passwordChanged,

  /// Theme was updated successfully.
  themeUpdated,

  /// Profile image was deleted successfully.
  imageDeleted,
}

/// Immutable state emitted by [ProfileBloc].
class ProfileState extends Equatable {
  final ProfileStatus status;
  final ProfileEntity? profile;
  final String? errorMessage;

  const ProfileState._({required this.status, this.profile, this.errorMessage});

  // ── Named constructors ──────────────────────────────────────────────────

  const ProfileState.initial() : this._(status: ProfileStatus.initial);

  const ProfileState.loading({ProfileEntity? profile})
    : this._(status: ProfileStatus.loading, profile: profile);

  const ProfileState.loaded(ProfileEntity profile)
    : this._(status: ProfileStatus.loaded, profile: profile);

  const ProfileState.updating(ProfileEntity profile)
    : this._(status: ProfileStatus.updating, profile: profile);

  const ProfileState.error(String message, {ProfileEntity? profile})
    : this._(
        status: ProfileStatus.error,
        errorMessage: message,
        profile: profile,
      );

  const ProfileState.passwordChanged(ProfileEntity profile)
    : this._(status: ProfileStatus.passwordChanged, profile: profile);

  const ProfileState.themeUpdated(ProfileEntity profile)
    : this._(status: ProfileStatus.themeUpdated, profile: profile);

  const ProfileState.imageDeleted(ProfileEntity profile)
    : this._(status: ProfileStatus.imageDeleted, profile: profile);

  /// Convenience copy helper.
  ProfileState copyWith({
    ProfileStatus? status,
    ProfileEntity? profile,
    String? errorMessage,
  }) {
    return ProfileState._(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
