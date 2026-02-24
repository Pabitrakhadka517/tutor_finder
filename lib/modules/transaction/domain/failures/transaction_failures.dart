/// Base class for all transaction-related failures.
/// Provides a consistent error handling approach across the transaction domain.
abstract class TransactionFailure implements Exception {
  const TransactionFailure(this.message);

  final String message;

  @override
  String toString() => 'TransactionFailure: $message';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TransactionFailure &&
            runtimeType == other.runtimeType &&
            message == other.message);
  }

  @override
  int get hashCode => message.hashCode;
}

/// Failure when transaction validation fails
class TransactionValidationFailure extends TransactionFailure {
  const TransactionValidationFailure(super.message);
}

/// Failure when authorization is denied
class TransactionAuthorizationFailure extends TransactionFailure {
  const TransactionAuthorizationFailure(super.message);
}

/// Failure when transaction is not found
class TransactionNotFoundFailure extends TransactionFailure {
  const TransactionNotFoundFailure(super.message);
}

/// Failure when payment gateway operation fails
class PaymentGatewayFailure extends TransactionFailure {
  const PaymentGatewayFailure(super.message, {this.code, this.details});

  final String? code;
  final Map<String, dynamic>? details;
}

/// Failure when insufficient funds for transaction
class InsufficientFundsFailure extends TransactionFailure {
  const InsufficientFundsFailure(
    super.message, {
    this.requiredAmount,
    this.availableAmount,
  });

  final double? requiredAmount;
  final double? availableAmount;
}

/// Failure when transaction conflicts with business rules
class TransactionConflictFailure extends TransactionFailure {
  const TransactionConflictFailure(super.message);
}

/// Failure during network operations
class TransactionNetworkFailure extends TransactionFailure {
  const TransactionNetworkFailure(super.message);
}

/// Failure on the server side
class TransactionServerFailure extends TransactionFailure {
  const TransactionServerFailure(super.message, {this.statusCode});

  final int? statusCode;
}

/// Unknown failure that doesn't fit other categories
class TransactionUnknownFailure extends TransactionFailure {
  const TransactionUnknownFailure(super.message);
}
