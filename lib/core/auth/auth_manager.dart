/// Manages authentication tokens and user session state
class AuthManager {
  String? _authToken;
  String? _userId;
  String? _userRole;

  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  String? get authToken => _authToken;
  String? get userId => _userId;
  String? get userRole => _userRole;
  bool get isAuthenticated => _authToken != null;

  void setSession({
    required String token,
    required String userId,
    required String role,
  }) {
    _authToken = token;
    _userId = userId;
    _userRole = role;
  }

  void clearSession() {
    _authToken = null;
    _userId = null;
    _userRole = null;
  }

  String? getToken() => _authToken;
  String? getCurrentUserId() => _userId;
}
