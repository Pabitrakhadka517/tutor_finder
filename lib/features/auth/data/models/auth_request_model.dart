/// Request model for authentication (login/register)
/// API payload: { "email": "...", "password": "..." }
class AuthRequestModel {
  final String email;
  final String password;

  AuthRequestModel({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
