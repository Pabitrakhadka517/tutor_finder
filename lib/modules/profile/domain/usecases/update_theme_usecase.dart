import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/profile_entity.dart';
import '../failures/profile_failures.dart';
import '../repositories/profile_repository.dart';

/// Use case for updating the user's theme preference.
class UpdateThemeUseCase {
  final ProfileRepository _repository;

  const UpdateThemeUseCase(this._repository);

  Future<Either<ProfileFailure, ProfileEntity>> call(
    UpdateThemeParams params,
  ) async {
    // ── Validation ───────────────────────────────────────────────────────────
    final theme = params.theme.toLowerCase();
    if (!['light', 'dark', 'system'].contains(theme)) {
      return const Left(
        ValidationFailure('Theme must be one of: light, dark, system'),
      );
    }

    return _repository.updateTheme(theme);
  }
}

class UpdateThemeParams extends Equatable {
  final String theme; // "light" | "dark" | "system"

  const UpdateThemeParams({required this.theme});

  @override
  List<Object?> get props => [theme];
}
