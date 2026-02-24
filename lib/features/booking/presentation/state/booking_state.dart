import '../../domain/entities/booking_entity.dart';

// ================= Booking List State =================
class BookingListState {
  final bool isLoading;
  final List<BookingEntity> bookings;
  final String? errorMessage;
  final String? activeFilter;

  const BookingListState({
    this.isLoading = false,
    this.bookings = const [],
    this.errorMessage,
    this.activeFilter,
  });

  BookingListState copyWith({
    bool? isLoading,
    List<BookingEntity>? bookings,
    String? errorMessage,
    String? activeFilter,
  }) {
    return BookingListState(
      isLoading: isLoading ?? this.isLoading,
      bookings: bookings ?? this.bookings,
      errorMessage: errorMessage,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

// ================= Booking Action State =================
class BookingActionState {
  final bool isLoading;
  final BookingEntity? booking;
  final String? errorMessage;
  final String? successMessage;

  const BookingActionState({
    this.isLoading = false,
    this.booking,
    this.errorMessage,
    this.successMessage,
  });

  BookingActionState copyWith({
    bool? isLoading,
    BookingEntity? booking,
    String? errorMessage,
    String? successMessage,
  }) {
    return BookingActionState(
      isLoading: isLoading ?? this.isLoading,
      booking: booking ?? this.booking,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
