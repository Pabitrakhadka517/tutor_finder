import 'package:dartz/dartz.dart';

import '../../../booking/domain/entities/booking_entity.dart';
import '../../../booking/domain/enums/booking_status.dart';
import '../../../booking/domain/repositories/booking_repository.dart';
import '../entities/transaction_entity.dart';
import '../enums/transaction_status.dart';
import '../failures/transaction_failures.dart';
import '../repositories/payment_gateway_repository.dart';
import '../repositories/transaction_repository.dart';

/// Use case to process a booking payment.
/// Handles payment processing, balance updates, and status transitions.
class ProcessBookingPaymentUseCase {
  const ProcessBookingPaymentUseCase({
    required this.transactionRepository,
    required this.paymentGatewayRepository,
    required this.bookingRepository,
    required this.balanceService,
    required this.notificationService,
    required this.chatRoomService,
  });

  final TransactionRepository transactionRepository;
  final PaymentGatewayRepository paymentGatewayRepository;
  final BookingRepository bookingRepository;
  final BalanceService balanceService;
  final NotificationService notificationService;
  final ChatRoomService chatRoomService;

  /// Process booking payment
  Future<Either<TransactionFailure, TransactionEntity>> call({
    required String transactionId,
    required String userId,
    String? paymentMethodId,
  }) async {
    // 1. Retrieve transaction
    final transactionResult = await transactionRepository.getTransactionById(
      transactionId,
    );

    if (transactionResult.isLeft()) {
      return transactionResult;
    }

    final transaction = transactionResult.getOrElse(
      () => throw StateError('Handled above'),
    );

    // 2. Validate user authorization
    if (transaction.senderId != userId) {
      return const Left(
        TransactionAuthorizationFailure(
          'Not authorized to process this transaction',
        ),
      );
    }

    // 3. Validate transaction status
    if (!transaction.isProcessable) {
      return Left(
        TransactionValidationFailure(
          'Transaction cannot be processed. Status: ${transaction.status.value}',
        ),
      );
    }

    // 4. Validate transaction business rules
    if (!transaction.validateProcessable()) {
      return const Left(
        TransactionValidationFailure('Transaction failed validation checks'),
      );
    }

    try {
      // 5. Mark transaction as processing
      final processingTransaction = transaction.markProcessing();
      final updateResult = await transactionRepository.updateTransaction(
        processingTransaction,
      );

      if (updateResult.isLeft()) {
        return updateResult;
      }

      // 6. Process payment through gateway
      final paymentResult = await paymentGatewayRepository.processPayment(
        amount: transaction.totalAmount,
        currency: 'USD', // TODO: Make configurable
        metadata: {
          'transaction_id': transaction.id,
          'reference_id': transaction.referenceId,
          'reference_type': transaction.referenceType.value,
          'sender_id': transaction.senderId,
          'receiver_id': transaction.receiverId,
        },
        paymentMethodId: paymentMethodId,
        customerId: userId,
      );

      if (paymentResult.isLeft()) {
        // Mark transaction as failed
        final failedTransaction = processingTransaction.markFailed(
          'Payment gateway error: ${paymentResult.fold((l) => l.message, (r) => '')}',
        );
        await transactionRepository.updateTransaction(failedTransaction);
        return Left(
          paymentResult.fold((l) => l, (r) => throw StateError('Unreachable')),
        );
      }

      final payment = paymentResult.getOrElse(
        () => throw StateError('Handled above'),
      );

      if (!payment.success) {
        // Mark transaction as failed
        final failedTransaction = processingTransaction.markFailed(
          payment.message ?? 'Payment processing failed',
        );
        await transactionRepository.updateTransaction(failedTransaction);
        return Left(
          PaymentGatewayFailure(payment.message ?? 'Payment processing failed'),
        );
      }

      // 7. Payment successful - complete transaction
      final completedTransaction = processingTransaction.markCompleted(
        paymentGatewayTransactionId: payment.gatewayTransactionId,
      );

      final finalUpdateResult = await transactionRepository.updateTransaction(
        completedTransaction,
      );

      if (finalUpdateResult.isLeft()) {
        return finalUpdateResult;
      }

      // 8. Update tutor balance
      await balanceService.incrementTutorBalance(
        transaction.receiverId,
        transaction.receiverAmount,
      );

      // 9. Update booking status to PAID
      await bookingRepository.updateBookingStatus(
        bookingId: transaction.referenceId,
        newStatus: BookingStatus.paid,
        userId: transaction.senderId,
        userRole: 'student',
      );

      // 10. Create chat room for student and tutor
      await chatRoomService.createChatRoom(
        transaction.senderId,
        transaction.receiverId,
      );

      // 11. Send payment success notification
      await notificationService.sendPaymentSuccessNotification(
        senderId: transaction.senderId,
        receiverId: transaction.receiverId,
        amount: transaction.totalAmount,
        referenceId: transaction.referenceId,
      );

      return Right(completedTransaction);
    } catch (e) {
      // Handle any unexpected errors
      final failedTransaction = transaction.markFailed(
        'Unexpected error during payment processing: $e',
      );
      await transactionRepository.updateTransaction(failedTransaction);
      return Left(TransactionUnknownFailure('Payment processing failed: $e'));
    }
  }
}

/// Abstract service for managing user balances
abstract class BalanceService {
  Future<Either<TransactionFailure, void>> incrementTutorBalance(
    String tutorId,
    double amount,
  );
}

/// Abstract service for sending notifications
abstract class NotificationService {
  Future<Either<TransactionFailure, void>> sendPaymentSuccessNotification({
    required String senderId,
    required String receiverId,
    required double amount,
    required String referenceId,
  });
}

/// Abstract service for chat room management
abstract class ChatRoomService {
  Future<Either<TransactionFailure, void>> createChatRoom(
    String studentId,
    String tutorId,
  );
}
