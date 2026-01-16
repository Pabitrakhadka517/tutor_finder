/// API Endpoints configuration for the Tutor Finder app
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  // For Android Emulator use: 'http://10.0.2.2:3000'
  // For iOS Simulator use: 'http://localhost:3000'
  // For Physical Device use your computer's IP: 'http://192.168.x.x:3000'
  static const String baseUrl = 'http://10.0.2.2:3000';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Auth Endpoints ============
  static const String register = '/auth/register';
  static const String registerAdmin = '/auth/register/admin';
  static const String registerTutor = '/auth/register/tutor';
  static const String login = '/auth/login';

  // Add more endpoints as needed
  // static const String logout = '/auth/logout';
  // static const String refreshToken = '/auth/refresh';
  // static const String forgotPassword = '/auth/forgot-password';
}
