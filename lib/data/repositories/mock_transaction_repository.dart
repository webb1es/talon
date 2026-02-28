import '../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

class MockTransactionRepository implements TransactionRepository {
  final _transactions = <Transaction>[];

  @override
  Future<Result<Transaction>> createTransaction(Transaction transaction) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _transactions.add(transaction);
    return Success(transaction);
  }

  @override
  Future<Result<List<Transaction>>> getTransactions({
    required String storeId,
    DateTime? date,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    var filtered = _transactions.where((t) => t.storeId == storeId);
    if (date != null) {
      filtered = filtered.where((t) =>
          t.createdAt.year == date.year &&
          t.createdAt.month == date.month &&
          t.createdAt.day == date.day);
    }
    return Success(filtered.toList());
  }
}
