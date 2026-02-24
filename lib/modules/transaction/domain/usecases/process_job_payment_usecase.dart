import 'package:dartz/dartz.dart';

import '../entities/transaction_entity.dart';
import '../failures/transaction_failures.dart';
import '../repositories/payment_gateway_repository.dart';
import '../repositories/transaction_repository.dart';
import 'process_booking_payment_usecase.dart';

/// Use case to process a job payment.
/// Similar to booking payment but for job-based transactions.
class ProcessJobPaymentUseCase {
  const ProcessJobPaymentUseCase({
    required this.transactionRepository,
    required this.paymentGatewayRepository,
    required this.balanceService,
    required this.notificationService,
    required this.chatRoomService,
  });

  final TransactionRepository transactionRepository;
  final PaymentGatewayRepository paymentGatewayRepository;
  final BalanceService balanceService;
  final NotificationService notificationService;
  final ChatRoomService chatRoomService;

  /// Process job payment
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

    // 3. Validate transaction status and business rules
    if (!transaction.isProcessable || !transaction.validateProcessable()) {
      return Left(
        TransactionValidationFailure(
          'Transaction cannot be processed. Status: ${transaction.status.value}',
        ),
      );
    }

    try {
      // 4. Mark transaction as processing
      final processingTransaction = transaction.markProcessing();
      final updateResult = await transactionRepository.updateTransaction(
        processingTransaction,
      );

      if (updateResult.isLeft()) {
        return updateResult;
      }

      // 5. Process payment through gateway
      final paymentResult = await paymentGatewayRepository.processPayment(
        amount: transaction.totalAmount,
        currency: 'USD',
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

      if (paymentResult.isLeft() ||
          !paymentResult.getOrElse(() => throw StateError('Handled')).success) {
        final failedTransaction = processingTransaction.markFailed(
          'Payment gateway error',
        );
        await transactionRepository.updateTransaction(failedTransaction);
        return Left(
          paymentResult.fold(
            (l) => l,
            (r) => PaymentGatewayFailure('Payment failed'),
          ),
        );
      }

      final payment = paymentResult.getOrElse(
        () => throw StateError('Handled above'),
      );

      // 6. Complete transaction
      final completedTransaction = processingTransaction.markCompleted(
        paymentGatewayTransactionId: payment.gatewayTransactionId,
      );

      final finalUpdateResult = await transactionRepository.updateTransaction(
        completedTransaction,
      );

      if (finalUpdateResult.isLeft()) {
        return finalUpdateResult;
      }

      // 7. Update tutor balance
      await balanceService.incrementTutorBalance(
        transaction.receiverId,
        transaction.receiverAmount,
      );

      // 8. Create chat room for student and tutor
      await chatRoomService.createChatRoom(
        transaction.senderId,
        transaction.receiverId,
      );

      // 9. Send payment success notification
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
