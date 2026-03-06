import 'dart:convert';

/// Utility class for decoding JWT tokens locally.
/// Extracts payload claims (userId, email, role, etc.) without
/// making an API call — enables fast role-based redirection on app start.
class JwtDecoder {
  JwtDecoder._();

  /// Decode the JWT payload and return it as a Map.
  /// Returns null if the token is malformed.
  static Map<String, dynamic>? decode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Check whether the token has expired.
  static bool isExpired(String token) {
    final payload = decode(token);
    if (payload == null) return true;

    final exp = payload['exp'] as int?;
    if (exp == null) return true;

    final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expDate);
  }

  /// Extract the user role from the JWT payload.
  /// Falls back to `'student'` when the claim is missing.
  static String getRole(String token) {
    final payload = decode(token);
    return (payload?['role'] as String?) ?? 'student';
  }

  /// Extract the user ID from the JWT payload.
  static String? getUserId(String token) {
    final payload = decode(token);
    return payload?['userId'] as String? ??
        payload?['id'] as String? ??
        payload?['sub'] as String?;
  }

  /// Extract email from the JWT payload.
  static String? getEmail(String token) {
    final payload = decode(token);
    return payload?['email'] as String?;
  }

  /// Return the remaining duration until expiry. Returns [Duration.zero] if
  /// already expired or the token cannot be decoded.
  static Duration getRemainingTime(String token) {
    final payload = decode(token);
    if (payload == null) return Duration.zero;

    final exp = payload['exp'] as int?;
    if (exp == null) return Duration.zero;

    final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    final remaining = expDate.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
