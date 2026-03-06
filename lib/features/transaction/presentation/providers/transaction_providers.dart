import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/transaction_repository.dart';
import '../../domain/usecases/payment_usecases.dart';
import '../notifiers/transaction_notifier.dart';
import '../state/transaction_state.dart';

// ================= Data Sources =================
final transactionRemoteDataSourceProvider =
    Provider<TransactionRemoteDataSource>(
      (ref) => TransactionRemoteDataSourceImpl(
        apiClient: ref.read(apiClientProvider),
      ),
    );

// ================= Repository =================
final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepositoryImpl(
    remoteDataSource: ref.read(transactionRemoteDataSourceProvider),
  ),
);

final initializePaymentUseCaseProvider = Provider<InitializePaymentUseCase>(
  (ref) => InitializePaymentUseCase(ref.read(transactionRepositoryProvider)),
);

final verifyPaymentUseCaseProvider = Provider<VerifyPaymentUseCase>(
  (ref) => VerifyPaymentUseCase(ref.read(transactionRepositoryProvider)),
);

final fetchPaymentHistoryUseCaseProvider = Provider<FetchPaymentHistoryUseCase>(
  (ref) => FetchPaymentHistoryUseCase(ref.read(transactionRepositoryProvider)),
);

final fetchReceivedTransactionsUseCaseProvider =
    Provider<FetchReceivedTransactionsUseCase>(
      (ref) => FetchReceivedTransactionsUseCase(
        ref.read(transactionRepositoryProvider),
      ),
    );

// ================= Notifier =================
final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>(
      (ref) => TransactionNotifier(
        initializePaymentUseCase: ref.read(initializePaymentUseCaseProvider),
        verifyPaymentUseCase: ref.read(verifyPaymentUseCaseProvider),
        fetchPaymentHistoryUseCase: ref.read(
          fetchPaymentHistoryUseCaseProvider,
        ),
        fetchReceivedTransactionsUseCase: ref.read(
          fetchReceivedTransactionsUseCaseProvider,
        ),
      ),
    );
