/// API endpoints configuration for transaction module.
/// Centralizes all transaction-related API paths for maintainability.
class TransactionApiEndpoints {
  static const String _baseTransaction = '/api/transactions';

  // Core CRUD operations
  static const String createTransaction = '$_baseTransaction';
  static const String getSentTransactions = '$_baseTransaction/sent';
  static const String getReceivedTransactions = '$_baseTransaction/received';
  static const String searchTransactions = '$_baseTransaction/search';
  static const String getTransactionStats = '$_baseTransaction/stats';
  static const String processPayment = '$_baseTransaction/process-payment';

  // Individual transaction operations
  static String getTransactionById(String id) => '$_baseTransaction/$id';
  static String updateTransaction(String id) => '$_baseTransaction/$id';
  static String deleteTransaction(String id) => '$_baseTransaction/$id';

  // Reference-based operations
  static String findByReference(String referenceId) =>
      '$_baseTransaction/reference/$referenceId';
  static String checkPendingTransaction(String referenceId) =>
      '$_baseTransaction/reference/$referenceId/pending';

  // Booking-specific endpoints
  static const String initBookingTransaction = '$_baseTransaction/booking/init';
  static const String processBookingPayment =
      '$_baseTransaction/booking/process';
  static String getBookingTransaction(String bookingId) =>
      '$_baseTransaction/booking/$bookingId';

  // Job-specific endpoints
  static const String initJobTransaction = '$_baseTransaction/job/init';
  static const String processJobPayment = '$_baseTransaction/job/process';
  static String getJobTransaction(String jobId) =>
      '$_baseTransaction/job/$jobId';

  // Admin operations (if needed later)
  static const String getAllTransactions = '$_baseTransaction/admin/all';
  static const String getTransactionsByUser = '$_baseTransaction/admin/by-user';
  static const String getTransactionsByReference =
      '$_baseTransaction/admin/by-reference';
}
