import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/chat_repository.dart';
import '../notifiers/chat_notifier.dart';
import '../state/chat_state.dart';

// ================= Data Sources =================
final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>(
  (ref) => ChatRemoteDataSourceImpl(
    apiClient: ref.read(apiClientProvider),
  ),
);

// ================= Repository =================
final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepositoryImpl(
    remoteDataSource: ref.read(chatRemoteDataSourceProvider),
  ),
);

// ================= Notifiers =================
final chatListNotifierProvider =
    StateNotifierProvider<ChatListNotifier, ChatListState>(
  (ref) => ChatListNotifier(ref.read(chatRepositoryProvider)),
);

final chatMessagesNotifierProvider =
    StateNotifierProvider<ChatMessagesNotifier, ChatMessagesState>(
  (ref) => ChatMessagesNotifier(ref.read(chatRepositoryProvider)),
);
