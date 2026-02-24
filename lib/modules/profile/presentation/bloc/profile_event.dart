import 'package:equatable/equatable.dart';

import '../../domain/usecases/update_profile_usecase.dart' as usecase;

/// Every event that the [ProfileBloc] can receive.
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// ── Load Profile ────────────────────────────────────────────────────────────
class LoadProfileRequested extends ProfileEvent {
  /// If true, tries to load from cache first for quick display,
  /// then fetches from remote in the background.
  final bool loadCachedFirst;

  const LoadProfileRequested({this.loadCachedFirst = false});

  @override
  List<Object?> get props => [loadCachedFirst];
}

/// ── Update Profile ─────────────────────────────────────────────────────────
class UpdateProfileRequested extends ProfileEvent {
  final String? name;
  final String? phone;
  final String? speciality;
  final String? address;
  final String? profileImagePath;
  final String? theme;
  final usecase.TutorFields? tutorFields;

  const UpdateProfileRequested({
    this.name,
    this.phone,
    this.speciality,
    this.address,
    this.profileImagePath,
    this.theme,
    this.tutorFields,
  });

  @override
  List<Object?> get props => [
    name,
    phone,
    speciality,
    address,
    profileImagePath,
    theme,
    tutorFields,
  ];
}

/// ── Update Theme ───────────────────────────────────────────────────────────
class UpdateThemeRequested extends ProfileEvent {
  final String theme; // "light" | "dark" | "system"

  const UpdateThemeRequested({required this.theme});

  @override
  List<Object?> get props => [theme];
}

/// ── Delete Profile Image ───────────────────────────────────────────────────
class DeleteImageRequested extends ProfileEvent {
  const DeleteImageRequested();
}

/// ── Change Password ────────────────────────────────────────────────────────
class ChangePasswordRequested extends ProfileEvent {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordRequested({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword];
}

/// ── Refresh Profile (pull-to-refresh or manual) ───────────────────────────
class RefreshProfileRequested extends ProfileEvent {
  const RefreshProfileRequested();
}
