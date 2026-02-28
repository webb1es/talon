import 'package:drift/drift.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/transaction.dart' as entity;
import '../../domain/repositories/transaction_repository.dart';
import '../drift/app_database.dart';
import '../drift/daos/transaction_dao.dart';

class DriftTransactionRepository implements TransactionRepository {
  final TransactionDao _dao;

  DriftTransactionRepository(this._dao);

  @override
  Future<Result<entity.Transaction>> createTransaction(
    entity.Transaction txn,
  ) async {
    try {
      final txnCompanion = TransactionsCompanion.insert(
        id: txn.id,
        storeId: txn.storeId,
        cashierId: txn.cashierId,
        cashierName: txn.cashierName,
        subtotal: txn.subtotal,
        taxRate: txn.taxRate,
        taxAmount: txn.taxAmount,
        total: txn.total,
        amountTendered: txn.amountTendered,
        change: txn.change,
        currencyCode: Value(txn.currencyCode),
        createdAt: txn.createdAt,
      );

      final itemCompanions = txn.items
          .map((i) => TransactionItemsCompanion.insert(
                transactionId: txn.id,
                productId: i.productId,
                productName: i.productName,
                sku: i.sku,
                unitPrice: i.unitPrice,
                quantity: i.quantity,
                lineTotal: i.lineTotal,
              ))
          .toList();

      await _dao.insertFullTransaction(txnCompanion, itemCompanions);
      return Success(txn);
    } catch (e) {
      return Fail(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<entity.Transaction>>> getTransactions({
    required String storeId,
    DateTime? date,
  }) async {
    try {
      final rows = await _dao.transactionsByStore(storeId, date: date);
      final transactions = <entity.Transaction>[];

      for (final row in rows) {
        final itemRows = await _dao.itemsForTransaction(row.id);
        final items = itemRows
            .map((i) => entity.TransactionItem(
                  productId: i.productId,
                  productName: i.productName,
                  sku: i.sku,
                  unitPrice: i.unitPrice,
                  quantity: i.quantity,
                  lineTotal: i.lineTotal,
                ))
            .toList();

        transactions.add(entity.Transaction(
          id: row.id,
          storeId: row.storeId,
          cashierId: row.cashierId,
          cashierName: row.cashierName,
          items: items,
          subtotal: row.subtotal,
          taxRate: row.taxRate,
          taxAmount: row.taxAmount,
          total: row.total,
          amountTendered: row.amountTendered,
          change: row.change,
          currencyCode: row.currencyCode,
          createdAt: row.createdAt,
        ));
      }

      return Success(transactions);
    } catch (e) {
      return Fail(CacheFailure(e.toString()));
    }
  }
}
