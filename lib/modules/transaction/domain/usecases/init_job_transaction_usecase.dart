import 'package:dartz/dartz.dart';

import '../entities/transaction_entity.dart';
import '../enums/reference_type.dart';
import '../failures/transaction_failures.dart';
import '../repositories/transaction_repository.dart';

/// Placeholder for job entity - will be created when job module is implemented
class JobEntity {
  const JobEntity({
    required this.id,
    required this.studentId,
    required this.tutorId,
    required this.price,
    required this.status,
  });

  final String id;
  final String studentId;
  final String tutorId;
  final double price;
  final String status; // 'accepted', 'pending', etc.
}

/// Placeholder for job repository - will be created when job module is implemented
abstract class JobRepository {
  Future<Either<dynamic, JobEntity>> getJobById(String jobId);
}

/// Use case to initialize a transaction for a job payment.
/// Validates job state and creates a pending transaction.
class InitJobTransactionUseCase {
  const InitJobTransactionUseCase({
    required this.transactionRepository,
    required this.jobRepository,
  });

  final TransactionRepository transactionRepository;
  final JobRepository jobRepository;

  /// Initialize a job transaction
  Future<Either<TransactionFailure, TransactionEntity>> call({
    required String jobId,
    required String studentId,
  }) async {
    // 1. Validate job exists
    final jobResult = await jobRepository.getJobById(jobId);
    if (jobResult.isLeft()) {
      return const Left(TransactionValidationFailure('Job not found'));
    }

    final job = jobResult.getOrElse(() => throw StateError('Handled above'));

    // 2. Ensure job is accepted
    if (job.status != 'accepted') {
      return const Left(
        TransactionValidationFailure(
          'Job must be accepted before payment can be processed',
        ),
      );
    }

    // 3. Validate user authorization (student can only pay for their own jobs)
    if (job.studentId != studentId) {
      return const Left(
        TransactionAuthorizationFailure('Not authorized to pay for this job'),
      );
    }

    // 4. Check if pending transaction already exists
    final existingTransactionResult = await transactionRepository
        .findTransactionByReference(jobId);

    if (existingTransactionResult.isLeft()) {
      return Left(
        existingTransactionResult.fold(
          (l) => l,
          (r) => throw StateError('Unreachable'),
        ),
      );
    }

    final existingTransaction = existingTransactionResult.getOrElse(
      () => throw StateError('Handled above'),
    );

    if (existingTransaction != null && existingTransaction.isPending) {
      return Left(
        TransactionConflictFailure(
          'A pending transaction already exists for this job',
        ),
      );
    }

    // 5. Create new transaction
    final createResult = await transactionRepository.createTransaction(
      senderId: job.studentId,
      receiverId: job.tutorId,
      referenceId: jobId,
      referenceType: ReferenceType.job,
      totalAmount: job.price,
      notes: 'Payment for job completion',
    );

    return createResult;
  }
}
