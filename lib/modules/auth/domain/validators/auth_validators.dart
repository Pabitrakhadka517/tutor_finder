/// Frontend validation helpers used by use cases before hitting the network.
class AuthValidators {
  AuthValidators._();

  // ── Email ──────────────────────────────────────────────────────────────────
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required.';
    }
    if (!_emailRegex.hasMatch(email.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  // ── Password ───────────────────────────────────────────────────────────────
  /// Min 8 chars, 1 uppercase, 1 lowercase, 1 digit, 1 special char.
  static final _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:,.<>?/\\|`~]).{8,}$',
  );

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required.';
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

  /// Quick check using the combined regex.
  static bool isPasswordStrong(String password) {
    return _passwordRegex.hasMatch(password);
  }

  // ── Role guard ─────────────────────────────────────────────────────────────
  static const _allowedSelfRegisterRoles = {'student', 'tutor'};

  /// Returns an error message if the role is not allowed for self-registration.
  static String? validateRole(String? role) {
    if (role == null || role.trim().isEmpty) {
      return 'Role is required.';
    }
    if (!_allowedSelfRegisterRoles.contains(role.trim().toLowerCase())) {
      return 'Self-registration is only allowed for STUDENT or TUTOR roles.';
    }
    return null;
  }
}
