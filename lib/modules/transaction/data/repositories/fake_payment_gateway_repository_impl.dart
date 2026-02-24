import 'dart:math';

import 'package:dartz/dartz.dart';

import '../../domain/failures/transaction_failures.dart';
import '../../domain/repositories/payment_gateway_repository.dart';

/// Fake payment gateway implementation for testing and development.
/// Simulates real payment processing with configurable success/failure rates.
class FakePaymentGatewayRepositoryImpl implements PaymentGatewayRepository {
  const FakePaymentGatewayRepositoryImpl({
    this.successRate = 0.95, // 95% success rate by default
    this.processingDelay = const Duration(seconds: 2),
  });

  final double successRate;
  final Duration processingDelay;

  @override
  Future<Either<PaymentGatewayFailure, PaymentResult>> processPayment({
    required double amount,
    required String currency,
    required Map<String, dynamic> metadata,
    String? paymentMethodId,
    String? customerId,
  }) async {
    // Simulate network delay
    await Future.delayed(processingDelay);

    // Validate amount
    if (amount <= 0) {
      return const Left(
        PaymentGatewayFailure(
          'Invalid amount: must be greater than 0',
          code: 'INVALID_AMOUNT',
        ),
      );
    }

    // Validate currency
    if (currency.toUpperCase() != 'USD') {
      return Left(
        PaymentGatewayFailure(
          'Unsupported currency: $currency',
          code: 'UNSUPPORTED_CURRENCY',
        ),
      );
    }

    // Simulate random success/failure based on success rate
    final random = Random();
    final isSuccessful = random.nextDouble() < successRate;

    if (!isSuccessful) {
      // Simulate various failure types
      final failureType = random.nextInt(4);
      switch (failureType) {
        case 0:
          return const Left(
            PaymentGatewayFailure(
              'Insufficient funds',
              code: 'INSUFFICIENT_FUNDS',
            ),
          );
        case 1:
          return const Left(
            PaymentGatewayFailure(
              'Payment method declined',
              code: 'PAYMENT_DECLINED',
            ),
          );
        case 2:
          return const Left(
            PaymentGatewayFailure(
              'Payment gateway timeout',
              code: 'GATEWAY_TIMEOUT',
            ),
          );
        default:
          return const Left(
            PaymentGatewayFailure(
              'Unknown payment error',
              code: 'UNKNOWN_ERROR',
            ),
          );
      }
    }

    // Generate fake gateway transaction ID
    final gatewayTransactionId =
        'fake_txn_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(10000)}';

    return Right(
      PaymentResult(
        success: true,
        gatewayTransactionId: gatewayTransactionId,
        message: 'Payment processed successfully',
        metadata: {
          'processed_at': DateTime.now().toIso8601String(),
          'gateway': 'fake_gateway',
          'amount': amount,
          'currency': currency,
          ...metadata,
        },
      ),
    );
  }

  @override
  Future<Either<PaymentGatewayFailure, PaymentStatus>> verifyPayment(
    String gatewayTransactionId,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // For fake gateway, all transactions with proper format are considered successful
    if (gatewayTransactionId.startsWith('fake_txn_')) {
      return const Right(
        PaymentStatus(
          status: 'success',
          amount: 0.0, // Would need to store this in real implementation
          currency: 'USD',
          updatedAt: null,
        ),
      );
    }

    return const Left(
      PaymentGatewayFailure(
        'Transaction not found',
        code: 'TRANSACTION_NOT_FOUND',
      ),
    );
  }

  @override
  Future<Either<PaymentGatewayFailure, RefundResult>> refundPayment({
    required String gatewayTransactionId,
    required double amount,
    String? reason,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // For fake gateway, simulate refund processing
    if (!gatewayTransactionId.startsWith('fake_txn_')) {
      return const Left(
        PaymentGatewayFailure(
          'Transaction not found for refund',
          code: 'TRANSACTION_NOT_FOUND',
        ),
      );
    }

    if (amount <= 0) {
      return const Left(
        PaymentGatewayFailure('Invalid refund amount', code: 'INVALID_AMOUNT'),
      );
    }

    final refundId = 'fake_refund_${DateTime.now().millisecondsSinceEpoch}';

    return Right(
      RefundResult(
        success: true,
        refundId: refundId,
        amount: amount,
        message: 'Refund processed successfully',
      ),
    );
  }

  @override
  Future<Either<PaymentGatewayFailure, PaymentDetails>> getPaymentDetails(
    String gatewayTransactionId,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    if (!gatewayTransactionId.startsWith('fake_txn_')) {
      return const Left(
        PaymentGatewayFailure(
          'Payment details not found',
          code: 'TRANSACTION_NOT_FOUND',
        ),
      );
    }

    // Parse timestamp from fake transaction ID
    final parts = gatewayTransactionId.split('_');
    final timestamp = int.tryParse(parts.length > 2 ? parts[2] : '0') ?? 0;
    final createdAt = DateTime.fromMillisecondsSinceEpoch(timestamp);

    return Right(
      PaymentDetails(
        gatewayTransactionId: gatewayTransactionId,
        amount: 0.0, // Would be stored in real implementation
        currency: 'USD',
        status: 'success',
        createdAt: createdAt,
        paymentMethod: 'fake_card',
        metadata: {'gateway': 'fake_gateway', 'environment': 'test'},
      ),
    );
  }

  @override
  Future<bool> isGatewayAvailable() async {
    // Simulate network check
    await Future.delayed(const Duration(milliseconds: 100));
    return true; // Fake gateway is always "available"
  }
}
