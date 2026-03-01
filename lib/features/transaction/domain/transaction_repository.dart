import '../../../core/utils/either.dart';
import '../../../core/error/failures.dart';
import 'entities/transaction_entity.dart';

abstract class TransactionRepository {
  /// Initialize booking payment and return eSewa form payload from backend.
  Future<Either<Failure, PaymentInitEntity>> initializePayment({
    required String bookingId,
  });

  /// Verify payment callback details from eSewa via backend verification API.
  Future<Either<Failure, void>> verifyPayment({
    required String transactionUUID,
    required double amount,
    required String transactionCode,
    Map<String, dynamic>? callbackData,
  });

  /// Fetch user booking payment history.
  Future<Either<Failure, List<TransactionEntity>>> fetchPaymentHistory();

  /// Legacy wrappers used by existing screens.
  Future<Either<Failure, PaymentInitEntity>> initBookingPayment(
    String bookingId,
  );

  Future<Either<Failure, void>> processBookingPayment({
    required String transactionId,
    required String transactionCode,
    Map<String, dynamic>? esewaCallbackData,
  });

  Future<Either<Failure, List<TransactionEntity>>> getSentTransactions();

  Future<Either<Failure, List<TransactionEntity>>> getReceivedTransactions();
}
