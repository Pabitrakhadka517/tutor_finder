import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final ProfileEntity? profile;
  final String? error;

  const ProfileState({
    this.isLoading = false,
    this.profile,
    this.error,
  });

  factory ProfileState.initial() => const ProfileState();

  ProfileState copyWith({
    bool? isLoading,
    ProfileEntity? profile,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, profile, error];
}
