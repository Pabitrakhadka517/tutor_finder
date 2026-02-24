import 'package:dartz/dartz.dart';

import '../entities/chat_room_entity.dart';
import '../failures/chat_failures.dart';
import '../repositories/chat_room_repository.dart';

/// Use case for creating or getting an existing chat room.
/// Business logic for handling chat room creation/retrieval.
class CreateOrGetChatUseCase {
  final ChatRoomRepository _chatRoomRepository;

  CreateOrGetChatUseCase(this._chatRoomRepository);

  /// Create or get a chat room between two users for a specific booking.
  /// If chat already exists, returns existing chat.
  /// If not, creates a new one.
  Future<Either<ChatFailure, ChatRoomEntity>> call(
    CreateOrGetChatParams params,
  ) async {
    // Validate user roles (business rule: student and tutor must be different)
    if (params.studentId == params.tutorId) {
      return Left(
        ChatFailure.invalidOperation(
          'Student and tutor cannot be the same person',
        ),
      );
    }

    // First, try to find existing chat for this booking
    final existingByBookingResult = await _chatRoomRepository
        .findChatRoomByBooking(params.bookingId);

    // Handle repository error
    if (existingByBookingResult.isLeft()) {
      return Left(
        existingByBookingResult.fold(
          (failure) => failure,
          (_) => ChatFailure.serverError('Unexpected error'),
        ),
      );
    }

    final existingByBooking = existingByBookingResult.getOrElse(() => null);
    if (existingByBooking != null) {
      return Right(existingByBooking);
    }

    // If no booking-specific chat, try to find existing chat between users
    final existingResult = await _chatRoomRepository.findChatRoomBetweenUsers(
      params.studentId,
      params.tutorId,
    );

    // Handle repository error
    if (existingResult.isLeft()) {
      return Left(
        existingResult.fold(
          (failure) => failure,
          (_) => ChatFailure.serverError('Unexpected error'),
        ),
      );
    }

    final existing = existingResult.getOrElse(() => null);
    if (existing != null) {
      // Update existing chat with booking reference if not already set
      if (existing.bookingId != params.bookingId) {
        final updatedChat = existing.copyWith(bookingId: params.bookingId);
        return await _chatRoomRepository.updateChatRoom(updatedChat);
      }
      return Right(existing);
    }

    // No existing chat found, create a new one
    return await _chatRoomRepository.createChatRoom(
      studentId: params.studentId,
      tutorId: params.tutorId,
      bookingId: params.bookingId,
    );
  }
}

/// Parameters for creating or getting a chat room
class CreateOrGetChatParams {
  final String studentId;
  final String tutorId;
  final String bookingId;

  CreateOrGetChatParams({
    required this.studentId,
    required this.tutorId,
    required this.bookingId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreateOrGetChatParams &&
        other.studentId == studentId &&
        other.tutorId == tutorId &&
        other.bookingId == bookingId;
  }

  @override
  int get hashCode =>
      studentId.hashCode ^ tutorId.hashCode ^ bookingId.hashCode;

  @override
  String toString() {
    return 'CreateOrGetChatParams(studentId: $studentId, tutorId: $tutorId, bookingId: $bookingId)';
  }
}
