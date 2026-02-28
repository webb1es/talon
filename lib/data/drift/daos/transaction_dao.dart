import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/transaction_item_table.dart';
import '../tables/transaction_table.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions, TransactionItems])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  Future<void> insertFullTransaction(
    TransactionsCompanion txn,
    List<TransactionItemsCompanion> items,
  ) async {
    await batch((b) {
      b.insert(transactions, txn);
      b.insertAll(transactionItems, items);
    });
  }

  Future<List<Transaction>> transactionsByStore(
    String storeId, {
    DateTime? date,
  }) {
    final query = select(transactions)
      ..where((t) => t.storeId.equals(storeId));
    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      query
        ..where((t) => t.createdAt.isBiggerOrEqualValue(start))
        ..where((t) => t.createdAt.isSmallerThanValue(end));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<List<TransactionItem>> itemsForTransaction(String transactionId) =>
      (select(transactionItems)
            ..where((t) => t.transactionId.equals(transactionId)))
          .get();
}
