import 'package:equatable/equatable.dart';

/// Base class for all tutor-related failures in the domain layer.
/// Provides a consistent error handling approach across the module.
abstract class TutorFailure extends Equatable {
  const TutorFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Server-related failures
class TutorServerFailure extends TutorFailure {
  const TutorServerFailure(super.message);

  factory TutorServerFailure.general() =>
      const TutorServerFailure('Server error occurred. Please try again.');

  factory TutorServerFailure.maintenance() => const TutorServerFailure(
    'Server is under maintenance. Please try again later.',
  );

  factory TutorServerFailure.serviceUnavailable() =>
      const TutorServerFailure('Service is temporarily unavailable.');
}

/// Network-related failures
class TutorNetworkFailure extends TutorFailure {
  const TutorNetworkFailure(super.message);

  factory TutorNetworkFailure.noInternet() => const TutorNetworkFailure(
    'No internet connection. Please check your network.',
  );

  factory TutorNetworkFailure.timeout() =>
      const TutorNetworkFailure('Request timed out. Please try again.');

  factory TutorNetworkFailure.connectionError() =>
      const TutorNetworkFailure('Connection error. Please check your network.');
}

/// Authentication and authorization failures
class TutorAuthFailure extends TutorFailure {
  const TutorAuthFailure(super.message);

  factory TutorAuthFailure.unauthorized() =>
      const TutorAuthFailure('You are not authorized to access this resource.');

  factory TutorAuthFailure.tokenExpired() =>
      const TutorAuthFailure('Your session has expired. Please log in again.');

  factory TutorAuthFailure.forbidden() => const TutorAuthFailure(
    'You do not have permission to perform this action.',
  );
}

/// Validation failures
class TutorValidationFailure extends TutorFailure {
  const TutorValidationFailure(super.message);

  factory TutorValidationFailure.invalidSearch() =>
      const TutorValidationFailure(
        'Search query must be at least 2 characters.',
      );

  factory TutorValidationFailure.invalidPriceRange() =>
      const TutorValidationFailure(
        'Minimum price cannot be greater than maximum price.',
      );

  factory TutorValidationFailure.invalidPage() =>
      const TutorValidationFailure('Page number must be greater than 0.');

  factory TutorValidationFailure.invalidLimit() =>
      const TutorValidationFailure('Limit must be between 1 and 100.');

  factory TutorValidationFailure.invalidAvailabilitySlot() =>
      const TutorValidationFailure(
        'Invalid availability slot. Check start and end times.',
      );

  factory TutorValidationFailure.overlappingSlots() =>
      const TutorValidationFailure('Availability slots cannot overlap.');

  factory TutorValidationFailure.slotInPast() => const TutorValidationFailure(
    'Cannot create availability slots in the past.',
  );
}

/// Cache-related failures
class TutorCacheFailure extends TutorFailure {
  const TutorCacheFailure(super.message);

  factory TutorCacheFailure.notFound() =>
      const TutorCacheFailure('No cached data found.');

  factory TutorCacheFailure.expired() =>
      const TutorCacheFailure('Cached data has expired.');

  factory TutorCacheFailure.corruptedData() =>
      const TutorCacheFailure('Cached data is corrupted and cannot be read.');

  factory TutorCacheFailure.storageError() =>
      const TutorCacheFailure('Error accessing local storage.');
}

/// Not found failures
class TutorNotFoundFailure extends TutorFailure {
  const TutorNotFoundFailure(super.message);

  factory TutorNotFoundFailure.tutorNotFound() =>
      const TutorNotFoundFailure('Tutor not found.');

  factory TutorNotFoundFailure.noResults() =>
      const TutorNotFoundFailure('No tutors found matching your criteria.');

  factory TutorNotFoundFailure.noAvailability() =>
      const TutorNotFoundFailure('No availability slots found for this tutor.');
}

/// Business logic failures
class TutorBusinessFailure extends TutorFailure {
  const TutorBusinessFailure(super.message);

  factory TutorBusinessFailure.alreadyVerified() =>
      const TutorBusinessFailure('Tutor is already verified.');

  factory TutorBusinessFailure.verificationInProgress() =>
      const TutorBusinessFailure('Verification is already in progress.');

  factory TutorBusinessFailure.notEligibleForVerification() =>
      const TutorBusinessFailure(
        'Profile is not complete enough for verification.',
      );

  factory TutorBusinessFailure.slotAlreadyBooked() =>
      const TutorBusinessFailure('This time slot is already booked.');

  factory TutorBusinessFailure.cannotModifyBookedSlot() =>
      const TutorBusinessFailure(
        'Cannot modify a time slot that is already booked.',
      );
}

/// Rate limiting failures
class TutorRateLimitFailure extends TutorFailure {
  const TutorRateLimitFailure(super.message);

  factory TutorRateLimitFailure.tooManyRequests() =>
      const TutorRateLimitFailure(
        'Too many requests. Please wait a moment before trying again.',
      );

  factory TutorRateLimitFailure.searchRateLimit() =>
      const TutorRateLimitFailure(
        'You are searching too quickly. Please slow down.',
      );
}

/// Unknown/unexpected failures
class TutorUnknownFailure extends TutorFailure {
  const TutorUnknownFailure(super.message);

  factory TutorUnknownFailure.general() => const TutorUnknownFailure(
    'An unexpected error occurred. Please try again.',
  );

  factory TutorUnknownFailure.parsing() =>
      const TutorUnknownFailure('Error processing server response.');
}
