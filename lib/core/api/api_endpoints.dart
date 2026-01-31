import 'dart:io';

import 'package:flutter/foundation.dart';

/// API Endpoints configuration for the Tutor Finder app
class ApiEndpoints {
  ApiEndpoints._();

  // ================= Base URLs =================

  /// Android Emulator (Phone & Tablet)
  /// 10.0.2.2 maps to host machine localhost
  static const String _androidEmulatorUrl = 'http://10.0.2.2:3000'; // Port 3000

  /// iOS Simulator
  static const String _iosSimulatorUrl = 'http://localhost:3000'; // Port 3000

  /// Physical device (use your PC IP)
  static const String _physicalDeviceUrl =
      'http://192.168.1.67:3000'; // Port 3000

  /// Base URL getter
  static String get baseUrl {
    if (kIsWeb) {
      return _iosSimulatorUrl;
    } else if (Platform.isAndroid) {
      return _androidEmulatorUrl;
    } else if (Platform.isIOS) {
      return _iosSimulatorUrl;
    } else {
      return _physicalDeviceUrl;
    }
  }

  // ================= Timeouts =================
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // ================= Auth Endpoints =================
  static const String register = '/api/auth/register';
  static const String registerAdmin = '/api/auth/register/admin';
  static const String registerTutor = '/api/auth/register/tutor';
  static const String login = '/api/auth/login';

  // ================= Profile Endpoints =================
  static const String updateProfile = '/api/profile';
  static const String getProfile = '/api/profile';
}
