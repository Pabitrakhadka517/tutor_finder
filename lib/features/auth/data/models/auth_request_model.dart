/// Request model for authentication (login/register)
/// API payload: { "email": "...", "password": "...", "expectedRole": "..." }
class AuthRequestModel {
  final String email;
  final String password;
  final String? expectedRole;

  AuthRequestModel({
    required this.email,
    required this.password,
    this.expectedRole,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'email': email, 'password': password};
    if (expectedRole != null) {
      map['expectedRole'] = expectedRole;
    }
    return map;
  }
}
