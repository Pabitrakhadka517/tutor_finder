import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utility class for password hashing
class PasswordHasher {
  /// Hash a password using SHA256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify if a password matches a hash
  static bool verifyPassword(String password, String hashedPassword) {
    final passwordHash = hashPassword(password);
    return passwordHash == hashedPassword;
  }
}
