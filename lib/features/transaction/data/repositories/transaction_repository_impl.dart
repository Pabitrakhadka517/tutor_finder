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
  Future<Either<Failure, PaymentInitEntity>> initBookingPayment(
    String bookingId,
  ) async {
    try {
      final result = await remoteDataSource.initBookingPayment(bookingId);
      return Either.right(result);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> processBookingPayment({
    required String transactionId,
    required String transactionCode,
  }) async {
    try {
      await remoteDataSource.processBookingPayment(
        transactionId: transactionId,
        transactionCode: transactionCode,
      );
      return Either.right(null);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getSentTransactions() async {
    try {
      final result = await remoteDataSource.getSentTransactions();
      return Either.right(result);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getReceivedTransactions() async {
    try {
      final result = await remoteDataSource.getReceivedTransactions();
      return Either.right(result);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }
}
