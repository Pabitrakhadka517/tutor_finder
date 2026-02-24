import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/booking_usecases.dart';
import '../state/booking_state.dart';

// ================= Booking List Notifier =================
class BookingListNotifier extends StateNotifier<BookingListState> {
  final GetBookingsUseCase _getBookingsUseCase;

  BookingListNotifier(this._getBookingsUseCase)
    : super(const BookingListState());

  Future<void> fetchBookings({String? status}) async {
    state = state.copyWith(isLoading: true, activeFilter: status);

    final result = await _getBookingsUseCase(GetBookingsParams(status: status));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (bookings) =>
          state = state.copyWith(isLoading: false, bookings: bookings),
    );
  }

  void refreshBookings() {
    fetchBookings(status: state.activeFilter);
  }
}

// ================= Booking Action Notifier =================
class BookingActionNotifier extends StateNotifier<BookingActionState> {
  final CreateBookingUseCase _createBookingUseCase;
  final UpdateBookingStatusUseCase _updateBookingStatusUseCase;
  final CompleteBookingUseCase _completeBookingUseCase;
  final CancelBookingUseCase _cancelBookingUseCase;

  BookingActionNotifier(
    this._createBookingUseCase,
    this._updateBookingStatusUseCase,
    this._completeBookingUseCase,
    this._cancelBookingUseCase,
  ) : super(const BookingActionState());

  Future<bool> createBooking({
    required String tutorId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    state = const BookingActionState(isLoading: true);

    final result = await _createBookingUseCase(
      CreateBookingParams(
        tutorId: tutorId,
        startTime: startTime,
        endTime: endTime,
        notes: notes,
      ),
    );

    return result.fold(
      (failure) {
        state = BookingActionState(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (booking) {
        state = BookingActionState(
          isLoading: false,
          booking: booking,
          successMessage: 'Booking created successfully!',
        );
        return true;
      },
    );
  }

  Future<bool> updateStatus(String bookingId, String status) async {
    state = const BookingActionState(isLoading: true);

    final result = await _updateBookingStatusUseCase(
      UpdateBookingStatusParams(bookingId: bookingId, status: status),
    );

    return result.fold(
      (failure) {
        state = BookingActionState(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (booking) {
        state = BookingActionState(
          isLoading: false,
          booking: booking,
          successMessage: 'Booking ${status.toLowerCase()} successfully!',
        );
        return true;
      },
    );
  }

  Future<bool> completeBooking(String bookingId) async {
    state = const BookingActionState(isLoading: true);

    final result = await _completeBookingUseCase(bookingId);
    return result.fold(
      (failure) {
        state = BookingActionState(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (booking) {
        state = BookingActionState(
          isLoading: false,
          booking: booking,
          successMessage: 'Booking completed!',
        );
        return true;
      },
    );
  }

  Future<bool> cancelBooking(String bookingId) async {
    state = const BookingActionState(isLoading: true);

    final result = await _cancelBookingUseCase(bookingId);
    return result.fold(
      (failure) {
        state = BookingActionState(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (booking) {
        state = BookingActionState(
          isLoading: false,
          booking: booking,
          successMessage: 'Booking cancelled',
        );
        return true;
      },
    );
  }

  void resetState() {
    state = const BookingActionState();
  }
}
