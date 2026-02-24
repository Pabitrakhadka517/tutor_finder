/// App-wide constants for LearnMentor
class AppConstants {
  AppConstants._();

  // ================= App Info =================
  static const String appName = 'LearnMentor';
  static const String appVersion = '1.0.0';
  static const String currency = 'Rs.';
  static const double platformCommissionRate = 0.10; // 10%

  // ================= Pagination =================
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // ================= Storage Keys =================
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'userId';
  static const String userRoleKey = 'user_role';

  // ================= User Roles =================
  static const String roleStudent = 'STUDENT';
  static const String roleTutor = 'TUTOR';
  static const String roleAdmin = 'ADMIN';

  // ================= Booking Statuses =================
  static const String bookingPending = 'PENDING';
  static const String bookingConfirmed = 'CONFIRMED';
  static const String bookingAccepted = 'ACCEPTED';
  static const String bookingRejected = 'REJECTED';
  static const String bookingPaid = 'PAID';
  static const String bookingCompleted = 'COMPLETED';
  static const String bookingCancelled = 'CANCELLED';

  // ================= Transaction Statuses =================
  static const String transactionPending = 'PENDING';
  static const String transactionCompleted = 'COMPLETED';
  static const String transactionFailed = 'FAILED';

  // ================= Notification Types =================
  static const String notifBookingCreated = 'BOOKING_CREATED';
  static const String notifBookingUpdated = 'BOOKING_UPDATED';
  static const String notifPaymentSuccess = 'PAYMENT_SUCCESS';
  static const String notifNewReview = 'NEW_REVIEW';
  static const String notifAdminMessage = 'ADMIN_MESSAGE';

  // ================= Verification Statuses =================
  static const String verificationPending = 'PENDING';
  static const String verificationVerified = 'VERIFIED';
  static const String verificationRejected = 'REJECTED';

  // ================= Study Resource Types =================
  static const String resourcePdf = 'PDF';
  static const String resourceModule = 'MODULE';
  static const String resourceOther = 'OTHER';

  // ================= Announcement Types =================
  static const String announcementInfo = 'INFO';
  static const String announcementWarning = 'WARNING';
  static const String announcementUrgent = 'URGENT';

  // ================= Target Audiences =================
  static const String targetAll = 'ALL';
  static const String targetStudent = 'STUDENT';
  static const String targetTutor = 'TUTOR';

  // ================= Theme Modes =================
  static const String themeLight = 'light';
  static const String themeDark = 'dark';
  static const String themeSystem = 'system';

  // ================= Validation =================
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxBioLength = 500;
  static const int maxReviewLength = 1000;

  // ================= File Uploads =================
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const List<String> allowedDocExtensions = [
    'pdf',
    'doc',
    'docx',
    'ppt',
    'pptx',
    'txt',
    'zip',
  ];
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];
}
