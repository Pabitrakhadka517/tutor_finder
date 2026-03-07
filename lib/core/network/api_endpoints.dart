/// API endpoints for the application.
/// Contains all endpoint constants for different modules.
class ApiEndpoints {
  // Base API paths
  static const String auth = '/auth';
  static const String users = '/users';
  static const String bookings = '/bookings';
  static const String transactions = '/transactions';
  static const String chat = '/chat';
  static const String messages = '/messages';

  // Authentication endpoints
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String logout = '$auth/logout';
  static const String refreshToken = '$auth/refresh';
  static const String forgotPassword = '$auth/forgot-password';
  static const String resetPassword = '$auth/reset-password';
  static const String verifyEmail = '$auth/verify-email';

  // User endpoints
  static const String getProfile = '$users/profile';
  static const String updateProfile = '$users/profile';
  static const String getUserById = '$users/{id}';
  static const String searchTutors = '$users/tutors/search';
  static const String getTutorProfile = '$users/tutors/{id}';

  // Booking endpoints
  static const String createBooking = bookings;
  static const String getBookings = bookings;
  static const String getBookingById = '$bookings/{id}';
  static const String updateBooking = '$bookings/{id}';
  static const String cancelBooking = '$bookings/{id}/cancel';
  static const String confirmBooking = '$bookings/{id}/confirm';

  // Transaction endpoints
  static const String createPayment = '$transactions/payments';
  static const String getTransactions = transactions;
  static const String getTransactionById = '$transactions/{id}';
  static const String processRefund = '$transactions/{id}/refund';
  static const String getWalletBalance = '$transactions/wallet/balance';
  static const String addFunds = '$transactions/wallet/add-funds';
  static const String withdrawFunds = '$transactions/wallet/withdraw';

  // Chat Room endpoints
  static const String createChatRoom = '$chat/rooms';
  static const String getChatRoom = '$chat/rooms/{id}';
  static const String findChatRoom = '$chat/rooms/find';
  static const String findChatRoomByBooking = '$chat/rooms/find-by-booking';
  static const String getUserChatRooms = '$chat/users/{userId}/rooms';
  static const String updateChatRoom = '$chat/rooms/{id}';
  static const String updateLastMessage = '$chat/rooms/{id}/last-message';
  static const String deactivateChatRoom = '$chat/rooms/{id}/deactivate';
  static const String checkChatAccess = '$chat/rooms/{id}/access';

  // Message endpoints
  static const String createMessage = messages;
  static const String getMessage = '$messages/{id}';
  static const String getChatMessages = '$chat/rooms/{chatId}/messages';
  static const String markMessagesRead = '$chat/rooms/{chatId}/messages/read';
  static const String getChatUnreadCount = '$chat/rooms/{chatId}/unread-count';
  static const String getTotalUnreadCount = '$users/{userId}/unread-count';
  static const String updateMessage = '$messages/{id}';
  static const String deleteMessage = '$messages/{id}';
  static const String searchMessages = '$chat/rooms/{chatId}/messages/search';
  static const String getMessageStats = '$chat/rooms/{chatId}/stats';
  static const String getRecentMessages = '$users/{userId}/recent-messages';

  // Review endpoints
  static const String reviews = '/reviews';
  static const String createReview = reviews;
  static const String getReview = '$reviews/{id}';
  static const String updateReview = '$reviews/{id}';
  static const String deleteReview = '$reviews/{id}';
  static const String getReviewByBooking = '$reviews/booking/{bookingId}';
  static const String getTutorReviews = '$reviews/tutor/{tutorId}';
  static const String getStudentReviews = '$reviews/student/{studentId}';
  static const String searchReviews = '$reviews/search';
  static const String getReviewStatistics = '$reviews/tutor/{tutorId}/stats';
  static const String getRecentReviews = '$reviews/recent';
  static const String checkReviewExists = '$reviews/booking/{bookingId}/exists';

  // Tutor Rating endpoints
  static const String tutorRatings = '/tutor-ratings';
  static const String getTutorRating = '$tutorRatings/{tutorId}';
  static const String updateTutorRating = '$tutorRatings/{tutorId}';
  static const String createTutorRating = tutorRatings;
  static const String getTopRatedTutors = '$tutorRatings/top-rated';
  static const String getMostReviewedTutors = '$tutorRatings/most-reviewed';
  static const String getPlatformRatingStats = '$tutorRatings/platform/stats';
  static const String recalculateTutorRating =
      '$tutorRatings/{tutorId}/recalculate';

  // Notification endpoints
  static const String notifications = '/api/notifications';
  static const String createNotification = notifications;
  static const String getNotification = '$notifications/{id}';
  static const String getNotifications = notifications;
  static const String getNotificationsUnreadCount =
      '$notifications/unread-count';
  static const String markAsRead = '$notifications/{id}/read';
  static const String markAllRead = '$notifications/read-all';
  static const String deleteNotification = '$notifications/{id}';
  static const String deleteMultipleNotifications =
      '$notifications/bulk-delete';
  static const String getRecentNotifications = '$notifications/recent';
  static const String searchNotifications = '$notifications/search';
  static const String getNotificationStats = '$notifications/stats';
  static const String deleteAllRead = '$notifications/read/delete';
  static const String deleteOldNotifications = '$notifications/old/delete';
  static const String markMultipleAsRead = '$notifications/bulk-read';
  static const String getNotificationsByType = '$notifications/type/{type}';

  // Socket.IO endpoints
  static const String socket = '/socket.io';

  // WebSocket events
  static const String joinRoom = 'join_room';
  static const String leaveRoom = 'leave_room';
  static const String sendMessage = 'send_message';
  static const String messageReceived = 'message_received';
  static const String messageSent = 'message_sent';
  static const String messageRead = 'message_read';
  static const String userTyping = 'user_typing';
  static const String userStoppedTyping = 'user_stopped_typing';
  static const String userOnline = 'user_online';
  static const String userOffline = 'user_offline';
  static const String roomUpdated = 'room_updated';
  static const String error = 'error';
  static const String connect = 'connect';
  static const String disconnect = 'disconnect';

  // Notification WebSocket events
  static const String newNotification = 'new_notification';
  static const String notificationRead = 'notification_read';
  static const String notificationDeleted = 'notification_deleted';
  static const String notificationUpdated = 'notification_updated';
  static const String subscribeNotifications = 'subscribe_notifications';
  static const String unsubscribeNotificationEvents =
      'unsubscribe_notifications';
  static const String notificationCountUpdated = 'notification_count_updated';
}
