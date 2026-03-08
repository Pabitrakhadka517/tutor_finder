import 'dart:io';

import 'package:flutter/foundation.dart';

/// API Endpoints configuration for the Tutor Finder app
/// Maps to web-backend-learnmentor routes
class ApiEndpoints {
  ApiEndpoints._();

  static const String _configuredHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: '',
  );
  static const bool _useEmulatorHost = bool.fromEnvironment(
    'USE_ANDROID_EMULATOR_HOST',
    defaultValue: false,
  );
  static const bool _useAdbReverse = bool.fromEnvironment(
    'USE_ADB_REVERSE',
    defaultValue: false,
  );
  static const String _defaultLanHost = '192.168.1.67';
  static const int _configuredPort = int.fromEnvironment(
    'API_PORT',
    defaultValue: 4000,
  );

  // // ================= Base URLs =================

  // /// Android Emulator (Phone & Tablet)
  // /// 10.0.2.2 maps to host machine localhost
  // static const String _androidEmulatorUrl = 'http://10.0.2.2:4000';

  // /// iOS Simulator
  // static const String _iosSimulatorUrl = 'http://localhost:4000';

  // /// Physical device (use your PC IP)
  // static const String _physicalDeviceUrl = 'http://192.168.1.67:4000';

  // /// Base URL getter
  // static String get baseUrl {
  //   if (kIsWeb) {
  //     return _iosSimulatorUrl;
  //   } else if (Platform.isAndroid) {
  //     return _androidEmulatorUrl;
  //   } else if (Platform.isIOS) {
  //     return _iosSimulatorUrl;
  //   } else {
  //     return _physicalDeviceUrl;
  //   }
  // }

  // API_HOST/API_PORT can be provided at run time with --dart-define.
  // Android defaults to localhost through adb reverse in debug workflows.
  // Toggle behaviors if needed:
  // flutter run --dart-define=USE_ADB_REVERSE=false
  // flutter run --dart-define=USE_ANDROID_EMULATOR_HOST=true
  static String get _host {
    if (_configuredHost.isNotEmpty) return _configuredHost;
    if (kIsWeb || Platform.isIOS) return 'localhost';
    if (Platform.isAndroid) {
      if (_useAdbReverse) return 'localhost';
      return _useEmulatorHost ? '10.0.2.2' : _defaultLanHost;
    }
    return 'localhost';
  }

  static String get baseUrl => 'http://$_host:$_configuredPort';

  // ================= Timeouts =================
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // ================= Auth Endpoints =================
  static const String register = '/api/auth/register';
  static const String registerUser = '/api/auth/register/user';
  static const String registerAdmin = '/api/auth/register/admin';
  static const String registerTutor = '/api/auth/register/tutor';
  static const String login = '/api/auth/login';
  static const String refreshToken = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String me = '/api/auth/me';

  // ================= Profile Endpoints =================
  static const String getProfile = '/api/profile';
  static const String updateProfile = '/api/profile';
  static const String updateTheme = '/api/profile/theme';
  static const String deleteProfileImage = '/api/profile/image';

  // ================= Tutor Endpoints =================
  static const String tutors = '/api/tutors';
  static String tutorById(String id) => '/api/tutors/$id';
  static const String myAvailability = '/api/tutors/my/availability';
  static String tutorAvailability(String id) => '/api/tutors/$id/availability';
  static const String submitVerification = '/api/tutors/my/verify/submit';

  // ================= Booking Endpoints =================
  static const String createBooking = '/api/bookings/book';
  static const String bookings = '/api/bookings';
  static String bookingStatus(String id) => '/api/bookings/$id/status';
  static String completeBooking(String id) => '/api/bookings/$id/complete';
  static String cancelBooking(String id) => '/api/bookings/$id/cancel';
  static String editBooking(String id) => '/api/bookings/$id';

  // ================= Chat Endpoints =================
  static const String chats = '/api/chats';
  static String chatMessages(String chatId) => '/api/chats/$chatId/messages';
  static String sendMessage(String chatId) => '/api/chats/$chatId/messages';
  static String editMessage(String messageId) =>
      '/api/chats/messages/$messageId';
  static String deleteMessage(String messageId) =>
      '/api/chats/messages/$messageId';
  static String markRead(String chatId) => '/api/chats/$chatId/read';

  // ================= Transaction Endpoints =================
  static String initBookingPayment(String bookingId) =>
      '/api/transactions/bookings/transaction/$bookingId';
  static String processBookingPayment(String transactionId) =>
      '/api/transactions/bookings/transaction/$transactionId/pay';
  static const String sentTransactions = '/api/transactions/transactions/sent';
  static const String receivedTransactions =
      '/api/transactions/transactions/received';

  // ================= Payment (Booking) Endpoints =================
  static const String paymentInitBooking = '/api/payment/init-booking';
  static const String paymentVerify = '/api/payment/verify';
  static const String paymentHistory = '/api/payment/history';

  // ================= Review Endpoints =================
  static String createReview(String bookingId) => '/api/reviews/$bookingId';
  static String tutorReviews(String tutorId) => '/api/reviews/tutor/$tutorId';

  // ================= Notification Endpoints =================
  static const String notifications = '/api/notifications';
  static const String unreadCount = '/api/notifications/unread-count';
  static String markNotificationRead(String id) =>
      '/api/notifications/$id/read';
  static const String markAllRead = '/api/notifications/read-all';
  static String deleteNotification(String id) => '/api/notifications/$id';

  // ================= Dashboard Endpoints =================
  static const String studentDashboard = '/api/dashboard/student';
  static const String tutorDashboard = '/api/dashboard/tutor';
  static const String adminDashboard = '/api/dashboard/admin';

  // ================= Study Resources Endpoints =================
  static const String studyResources = '/api/study';
  static const String studyUpload = '/api/study/upload';
  static const String myStudyResources = '/api/study/my';
  static String deleteStudyResource(String id) => '/api/study/$id';

  // ================= Admin Endpoints =================
  static const String adminUsers = '/api/admin/users';
  static String adminUserById(String id) => '/api/admin/users/$id';
  static const String adminStats = '/api/admin/stats';
  static String verifyTutor(String tutorId) =>
      '/api/admin/tutors/$tutorId/verify';
  static const String announcements = '/api/admin/announcements';
  static String deleteAnnouncement(String id) => '/api/admin/announcements/$id';

  // ================= Image Helper =================
  static String? getImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;

    // Clean path to ensure no double slashes
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$cleanPath';
  }
}
