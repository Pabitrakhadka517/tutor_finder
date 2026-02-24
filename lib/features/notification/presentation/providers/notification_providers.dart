import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/shared_prefs_provider.dart';
import '../../data/datasources/notification_local_datasource.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/datasources/notification_websocket_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/notification_repository.dart';
import '../notifiers/notification_notifier.dart';
import '../state/notification_state.dart';

// ================= Core =================
final _dioProvider = Provider<Dio>((ref) => Dio());
final _dioClientProvider = Provider<DioClient>(
  (ref) => DioClient(ref.read(_dioProvider)),
);

// ================= Data Sources =================
final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>(
      (ref) => NotificationRemoteDataSourceImpl(ref.read(_dioClientProvider)),
    );

final notificationLocalDataSourceProvider =
    Provider<NotificationLocalDataSource>(
      (ref) =>
          NotificationLocalDataSourceImpl(ref.read(sharedPreferencesProvider)),
    );

final notificationWebSocketDataSourceProvider =
    Provider<NotificationWebSocketDataSource>(
      (ref) => NotificationWebSocketDataSourceImpl(),
    );

// ================= Repository =================
final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(
    ref.read(notificationRemoteDataSourceProvider),
    ref.read(notificationLocalDataSourceProvider),
    ref.read(notificationWebSocketDataSourceProvider),
  ),
);

// ================= Notifier =================
final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, NotificationListState>(
      (ref) => NotificationNotifier(ref.read(notificationRepositoryProvider)),
    );
