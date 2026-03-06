import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;
  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaymentInitEntity>> initializePayment({
    required String bookingId,
  }) async {
    try {
      final result = await remoteDataSource.initializePayment(
        bookingId: bookingId,
      );
      return Either.right(result);
    } on AuthException catch (e) {
      return Either.left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Either.left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Either.left(ApiFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyPayment({
    required String transactionUUID,
    required double amount,
    required String transactionCode,
    Map<String, dynamic>? callbackData,
  }) async {
    try {
      await remoteDataSource.verifyPayment(
        transactionUUID: transactionUUID,
        amount: amount,
        transactionCode: transactionCode,
        callbackData: callbackData,
      );
      return Either.right(null);
    } on AuthException catch (e) {
      return Either.left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Either.left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Either.left(ApiFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> fetchPaymentHistory() async {
    try {
      final result = await remoteDataSource.fetchPaymentHistory();
      return Either.right(result);
    } on AuthException catch (e) {
      return Either.left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Either.left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Either.left(ApiFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentInitEntity>> initBookingPayment(
    String bookingId,
  ) {
    return initializePayment(bookingId: bookingId);
  }

  @override
  Future<Either<Failure, void>> processBookingPayment({
    required String transactionId,
    required String transactionCode,
    Map<String, dynamic>? esewaCallbackData,
  }) {
    return verifyPayment(
      transactionUUID: transactionId,
      amount: 0,
      transactionCode: transactionCode,
      callbackData: esewaCallbackData,
    );
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getSentTransactions() {
    return fetchPaymentHistory();
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getReceivedTransactions() {
    return _fetchReceivedTransactions();
  }

  Future<Either<Failure, List<TransactionEntity>>>
  _fetchReceivedTransactions() async {
    try {
      final result = await remoteDataSource.fetchReceivedHistory();
      return Either.right(result);
    } on AuthException catch (e) {
      return Either.left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Either.left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Either.left(ApiFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }
}
