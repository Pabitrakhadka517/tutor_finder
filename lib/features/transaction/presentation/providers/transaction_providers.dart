import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/transaction_repository.dart';
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

// ================= Notifier =================
final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>(
  (ref) => TransactionNotifier(
    repository: ref.read(transactionRepositoryProvider),
  ),
);
