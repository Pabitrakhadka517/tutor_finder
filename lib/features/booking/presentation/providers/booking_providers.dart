import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../data/datasources/booking_remote_datasource.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/booking_repository.dart';
import '../../domain/usecases/booking_usecases.dart';
import '../notifiers/booking_notifier.dart';
import '../state/booking_state.dart';

// ================= Data Sources =================
final bookingRemoteDataSourceProvider = Provider<BookingRemoteDataSource>(
  (ref) => BookingRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider)),
);

// ================= Repository =================
final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => BookingRepositoryImpl(
    remoteDataSource: ref.read(bookingRemoteDataSourceProvider),
  ),
);

// ================= Use Cases =================
final createBookingUseCaseProvider = Provider(
  (ref) => CreateBookingUseCase(ref.read(bookingRepositoryProvider)),
);

final getBookingsUseCaseProvider = Provider(
  (ref) => GetBookingsUseCase(ref.read(bookingRepositoryProvider)),
);

final updateBookingStatusUseCaseProvider = Provider(
  (ref) => UpdateBookingStatusUseCase(ref.read(bookingRepositoryProvider)),
);

final completeBookingUseCaseProvider = Provider(
  (ref) => CompleteBookingUseCase(ref.read(bookingRepositoryProvider)),
);

final cancelBookingUseCaseProvider = Provider(
  (ref) => CancelBookingUseCase(ref.read(bookingRepositoryProvider)),
);

// ================= Notifiers =================
final bookingListNotifierProvider =
    StateNotifierProvider<BookingListNotifier, BookingListState>(
      (ref) => BookingListNotifier(ref.read(getBookingsUseCaseProvider)),
    );

final bookingActionNotifierProvider =
    StateNotifierProvider<BookingActionNotifier, BookingActionState>(
      (ref) => BookingActionNotifier(
        ref.read(createBookingUseCaseProvider),
        ref.read(updateBookingStatusUseCaseProvider),
        ref.read(completeBookingUseCaseProvider),
        ref.read(cancelBookingUseCaseProvider),
      ),
    );
