import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/transaction_entity.dart';
import '../transaction_repository.dart';

class InitializePaymentParams {
  final String bookingId;

  const InitializePaymentParams({required this.bookingId});
}

class InitializePaymentUseCase
    extends UseCase<PaymentInitEntity, InitializePaymentParams> {
  final TransactionRepository repository;

  InitializePaymentUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentInitEntity>> call(
    InitializePaymentParams params,
  ) {
    return repository.initializePayment(bookingId: params.bookingId);
  }
}

class VerifyPaymentParams {
  final String transactionUUID;
  final double amount;
  final String transactionCode;
  final Map<String, dynamic>? callbackData;

  const VerifyPaymentParams({
    required this.transactionUUID,
    required this.amount,
    required this.transactionCode,
    this.callbackData,
  });
}

class VerifyPaymentUseCase extends UseCase<void, VerifyPaymentParams> {
  final TransactionRepository repository;

  VerifyPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(VerifyPaymentParams params) {
    return repository.verifyPayment(
      transactionUUID: params.transactionUUID,
      amount: params.amount,
      transactionCode: params.transactionCode,
      callbackData: params.callbackData,
    );
  }
}

class FetchPaymentHistoryUseCase
    extends UseCase<List<TransactionEntity>, NoParams> {
  final TransactionRepository repository;

  FetchPaymentHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(NoParams params) {
    return repository.fetchPaymentHistory();
  }
}

class FetchReceivedTransactionsUseCase
    extends UseCase<List<TransactionEntity>, NoParams> {
  final TransactionRepository repository;

  FetchReceivedTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(NoParams params) {
    return repository.getReceivedTransactions();
  }
}
