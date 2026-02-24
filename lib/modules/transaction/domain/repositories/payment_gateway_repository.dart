import 'package:dartz/dartz.dart';

import '../failures/transaction_failures.dart';

/// Payment gateway abstraction for processing payments.
/// Allows for multiple payment provider implementations.
abstract class PaymentGatewayRepository {
  /// Process a payment charge
  Future<Either<PaymentGatewayFailure, PaymentResult>> processPayment({
    required double amount,
    required String currency,
    required Map<String, dynamic> metadata,
    String? paymentMethodId,
    String? customerId,
  });

  /// Verify payment status with gateway
  Future<Either<PaymentGatewayFailure, PaymentStatus>> verifyPayment(
    String gatewayTransactionId,
  );

  /// Refund a payment (if supported)
  Future<Either<PaymentGatewayFailure, RefundResult>> refundPayment({
    required String gatewayTransactionId,
    required double amount,
    String? reason,
  });

  /// Get gateway transaction details
  Future<Either<PaymentGatewayFailure, PaymentDetails>> getPaymentDetails(
    String gatewayTransactionId,
  );

  /// Check if gateway is available
  Future<bool> isGatewayAvailable();
}

/// Result of payment processing
class PaymentResult {
  const PaymentResult({
    required this.success,
    required this.gatewayTransactionId,
    this.message,
    this.metadata,
  });

  final bool success;
  final String gatewayTransactionId;
  final String? message;
  final Map<String, dynamic>? metadata;
}

/// Payment status from gateway
class PaymentStatus {
  const PaymentStatus({
    required this.status,
    required this.amount,
    this.currency,
    this.updatedAt,
  });

  final String status; // 'success', 'pending', 'failed', etc.
  final double amount;
  final String? currency;
  final DateTime? updatedAt;
}

/// Result of refund operation
class RefundResult {
  const RefundResult({
    required this.success,
    required this.refundId,
    required this.amount,
    this.message,
  });

  final bool success;
  final String refundId;
  final double amount;
  final String? message;
}

/// Detailed payment information from gateway
class PaymentDetails {
  const PaymentDetails({
    required this.gatewayTransactionId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.paymentMethod,
    this.customerId,
    this.metadata,
  });

  final String gatewayTransactionId;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;
  final String? paymentMethod;
  final String? customerId;
  final Map<String, dynamic>? metadata;
}
