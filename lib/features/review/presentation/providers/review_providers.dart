import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/providers/shared_prefs_provider.dart';
import '../../data/datasources/review_local_datasource.dart';
import '../../data/datasources/review_remote_datasouce.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../domain/repositories/review_repository.dart';
import '../notifiers/review_notifier.dart';
import '../state/review_state.dart';

// ================= Core =================
final _reviewDioProvider = Provider<Dio>((ref) => Dio());
final _reviewDioClientProvider = Provider<DioClient>(
  (ref) => DioClient(ref.read(_reviewDioProvider)),
);

// ================= Network Info =================
final _reviewNetworkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(Connectivity());
});

// ================= Data Sources =================
final reviewRemoteDataSourceProvider = Provider<ReviewRemoteDataSource>(
  (ref) => ReviewRemoteDataSourceImpl(ref.read(_reviewDioClientProvider)),
);

final reviewLocalDataSourceProvider = Provider<ReviewLocalDataSource>(
  (ref) => ReviewLocalDataSourceImpl(ref.read(sharedPreferencesProvider)),
);

// ================= Repository =================
final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ReviewRepositoryImpl(
    ref.read(reviewRemoteDataSourceProvider),
    ref.read(reviewLocalDataSourceProvider),
    ref.read(_reviewNetworkInfoProvider),
  ),
);

// ================= Notifiers =================
final reviewListNotifierProvider =
    StateNotifierProvider<ReviewListNotifier, ReviewListState>(
      (ref) => ReviewListNotifier(ref.read(reviewRepositoryProvider)),
    );

final createReviewNotifierProvider =
    StateNotifierProvider<CreateReviewNotifier, CreateReviewState>(
      (ref) => CreateReviewNotifier(ref.read(reviewRepositoryProvider)),
    );
