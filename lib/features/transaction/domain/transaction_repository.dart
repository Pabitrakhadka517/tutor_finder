import '../../../core/utils/either.dart';
import '../../../core/error/failures.dart';
import 'entities/transaction_entity.dart';

abstract class TransactionRepository {
  /// Init a booking payment - returns eSewa payment details
  Future<Either<Failure, PaymentInitEntity>> initBookingPayment(String bookingId);

  /// Process/verify payment after eSewa callback
  Future<Either<Failure, void>> processBookingPayment({
    required String transactionId,
    required String transactionCode,
  });

  /// Get transactions sent by current user (payments made)
  Future<Either<Failure, List<TransactionEntity>>> getSentTransactions();

  /// Get transactions received by current user (income)
  Future<Either<Failure, List<TransactionEntity>>> getReceivedTransactions();
}
