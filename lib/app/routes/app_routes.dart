import 'package:flutter/material.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/role_selection/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/dashboard/presentation/pages/role_based_dashboard_shell.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/tutor/presentation/pages/tutor_list_page.dart';
import '../../features/tutor/presentation/pages/tutor_detail_page.dart';
import '../../features/booking/presentation/pages/booking_list_page.dart';
import '../../features/booking/presentation/pages/create_booking_page.dart';
import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../features/chat/presentation/pages/chat_room_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';
import '../../features/transaction/presentation/pages/transaction_history_page.dart';
import '../../features/transaction/presentation/pages/payment_page.dart';
import '../../features/transaction/presentation/pages/payment_success_page.dart';
import '../../features/transaction/presentation/pages/payment_failure_page.dart';
import '../../features/review/presentation/pages/tutor_reviews_page.dart';
import '../../features/review/presentation/pages/create_review_page.dart';
import '../../features/study/presentation/pages/study_resources_page.dart';
import '../../features/study/presentation/pages/my_resources_page.dart';
import '../../features/study/presentation/pages/upload_resource_page.dart';
import '../../features/admin/presentation/pages/admin_users_page.dart';
import '../../features/admin/presentation/pages/admin_user_detail_page.dart';
import '../../features/admin/presentation/pages/announcements_page.dart';

/// Named route constants for the app
class AppRoutes {
  AppRoutes._();

  // ================= Route Names =================
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String tutorList = '/tutors';
  static const String tutorDetail = '/tutors/detail';
  static const String bookingList = '/bookings';
  static const String createBooking = '/bookings/create';
  static const String chatList = '/chats';
  static const String chatRoom = '/chats/room';
  static const String notifications = '/notifications';
  static const String transactionHistory = '/transactions';
  static const String payment = '/payment';
  static const String paymentSuccess = '/payment/success';
  static const String paymentFailure = '/payment/failure';
  static const String tutorReviews = '/reviews/tutor';
  static const String createReview = '/reviews/create';
  static const String studyResources = '/study';
  static const String myResources = '/study/my';
  static const String uploadResource = '/study/upload';
  static const String adminUsers = '/admin/users';
  static const String adminUserDetail = '/admin/users/detail';
  static const String announcements = '/admin/announcements';

  // ================= Route Generator =================
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashPage(), settings);
      case onboarding:
        return _buildRoute(const OnboardingPage(), settings);
      case roleSelection:
        return _buildRoute(const RoleSelectionPage(), settings);
      case login:
        final loginArgs = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          LoginPage(role: loginArgs?['role'] ?? 'STUDENT'),
          settings,
        );
      case register:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          RegisterPage(role: args?['role'] ?? 'STUDENT'),
          settings,
        );
      case forgotPassword:
        return _buildRoute(const ForgotPasswordPage(), settings);
      case resetPassword:
        final resetArgs = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          ResetPasswordPage(token: resetArgs?['token'] as String?),
          settings,
        );
      case dashboard:
        return _buildRoute(const RoleBasedDashboardShell(), settings);
      case profile:
        return _buildRoute(const ProfilePage(), settings);
      case editProfile:
        return _buildRoute(const EditProfilePage(), settings);
      case tutorList:
        return _buildRoute(const TutorListPage(), settings);
      case tutorDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(TutorDetailPage(tutorId: args['tutorId']), settings);
      case bookingList:
        return _buildRoute(const BookingListPage(), settings);
      case createBooking:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(CreateBookingPage(tutor: args['tutor']), settings);
      case chatList:
        return _buildRoute(const ChatListPage(), settings);
      case chatRoom:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          ChatRoomPage(
            chatId: args['chatId'],
            recipientName: args['recipientName'],
          ),
          settings,
        );
      case notifications:
        return _buildRoute(const NotificationPage(), settings);
      case transactionHistory:
        return _buildRoute(const TransactionHistoryPage(), settings);
      case payment:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          PaymentPage(
            bookingId: args['bookingId'],
            tutorName: args['tutorName'],
            price: args['price'],
          ),
          settings,
        );
      case paymentSuccess:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          PaymentSuccessPage(
            bookingId: args['bookingId'] ?? '',
            tutorName: args['tutorName'] ?? 'Tutor',
            amount: (args['amount'] is num)
                ? (args['amount'] as num).toDouble()
                : 0,
          ),
          settings,
        );
      case paymentFailure:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          PaymentFailurePage(
            message: args?['message'] ?? 'Payment failed. Please try again.',
          ),
          settings,
        );
      case tutorReviews:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          TutorReviewsPage(tutorId: args['tutorId']),
          settings,
        );
      case createReview:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          CreateReviewPage(
            bookingId: args['bookingId'],
            tutorName: args['tutorName'],
          ),
          settings,
        );
      case studyResources:
        return _buildRoute(const StudyResourcesPage(), settings);
      case myResources:
        return _buildRoute(const MyResourcesPage(), settings);
      case uploadResource:
        return _buildRoute(const UploadResourcePage(), settings);
      case adminUsers:
        return _buildRoute(const AdminUsersPage(), settings);
      case adminUserDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          AdminUserDetailPage(userId: args['userId']),
          settings,
        );
      case announcements:
        return _buildRoute(const AnnouncementsPage(), settings);
      default:
        return _buildRoute(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
