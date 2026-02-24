import 'dart:io';

/// Frontend validation helpers for profile fields.
class ProfileValidators {
  ProfileValidators._();

  // ── Name validation ───────────────────────────────────────────────────────
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Name is required.';
    }
    final trimmed = name.trim();
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters.';
    }
    if (trimmed.length > 100) {
      return 'Name must be at most 100 characters.';
    }
    return null;
  }

  // ── Phone validation ──────────────────────────────────────────────────────
  static final _phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');

  static String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return null; // Phone is optional
    }
    final trimmed = phone.trim();
    if (trimmed.length < 10) {
      return 'Phone number must be at least 10 digits.';
    }
    if (!_phoneRegex.hasMatch(trimmed)) {
      return 'Please enter a valid phone number.';
    }
    return null;
  }

  // ── Speciality validation ─────────────────────────────────────────────────
  static String? validateSpeciality(String? speciality) {
    if (speciality == null || speciality.trim().isEmpty) {
      return null; // Optional field
    }
    if (speciality.trim().length > 200) {
      return 'Speciality must be at most 200 characters.';
    }
    return null;
  }

  // ── Bio validation (tutor only) ───────────────────────────────────────────
  static String? validateBio(String? bio) {
    if (bio == null || bio.trim().isEmpty) {
      return null; // Optional field
    }
    if (bio.trim().length > 2000) {
      return 'Bio must be at most 2000 characters.';
    }
    return null;
  }

  // ── Hourly rate validation (tutor only) ───────────────────────────────────
  static String? validateHourlyRate(double? rate) {
    if (rate == null) {
      return null; // Optional field
    }
    if (rate < 0) {
      return 'Hourly rate must be non-negative.';
    }
    if (rate > 10000) {
      return 'Hourly rate seems too high.';
    }
    return null;
  }

  // ── Experience validation (tutor only) ────────────────────────────────────
  static String? validateExperienceYears(int? years) {
    if (years == null) {
      return null; // Optional field
    }
    if (years < 0) {
      return 'Experience years must be non-negative.';
    }
    if (years > 50) {
      return 'Experience years seems too high.';
    }
    return null;
  }

  // ── Password validation ───────────────────────────────────────────────────
  static String? validateOldPassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Current password is required.';
    }
    return null;
  }

  /// Min 8 chars, 1 uppercase, 1 lowercase, 1 digit, 1 special char.
  static String? validateNewPassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'New password is required.';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter.';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Password must contain at least one digit.';
    }
    if (!RegExp(
      r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:,.<>?/\\|`~]',
    ).hasMatch(password)) {
      return 'Password must contain at least one special character.';
    }
    return null;
  }

  // ── Image validation ──────────────────────────────────────────────────────
  static const _maxImageSize = 5 * 1024 * 1024; // 5MB
  static const _allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

  static String? validateImageFile(File? file) {
    if (file == null) {
      return null; // Optional
    }

    // Check file exists
    if (!file.existsSync()) {
      return 'File does not exist.';
    }

    // Check file size
    final size = file.lengthSync();
    if (size > _maxImageSize) {
      return 'File size must be less than 5MB.';
    }

    // Check file extension
    final extension = file.path.toLowerCase().split('.').last;
    if (!_allowedExtensions.any((ext) => ext.contains(extension))) {
      return 'Only JPG, PNG, and WEBP files are supported.';
    }

    return null;
  }

  // ── Lists validation ──────────────────────────────────────────────────────
  static String? validateSubjects(List<String>? subjects) {
    if (subjects == null || subjects.isEmpty) {
      return null; // Optional
    }
    if (subjects.length > 20) {
      return 'Too many subjects (maximum 20).';
    }
    for (final subject in subjects) {
      if (subject.trim().isEmpty) {
        return 'Subject names cannot be empty.';
      }
      if (subject.trim().length > 100) {
        return 'Subject name too long (maximum 100 characters).';
      }
    }
    return null;
  }

  static String? validateLanguages(List<String>? languages) {
    if (languages == null || languages.isEmpty) {
      return null; // Optional
    }
    if (languages.length > 10) {
      return 'Too many languages (maximum 10).';
    }
    for (final language in languages) {
      if (language.trim().isEmpty) {
        return 'Language names cannot be empty.';
      }
      if (language.trim().length > 50) {
        return 'Language name too long (maximum 50 characters).';
      }
    }
    return null;
  }
}
