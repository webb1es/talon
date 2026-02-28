import '../../core/error/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Result<Transaction>> createTransaction(Transaction transaction);

  Future<Result<List<Transaction>>> getTransactions({
    required String storeId,
    DateTime? date,
  });
}
