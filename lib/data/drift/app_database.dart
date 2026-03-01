import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/product_dao.dart';
import 'daos/store_dao.dart';
import 'daos/sync_queue_dao.dart';
import 'daos/transaction_dao.dart';
import 'tables/payment_entry_table.dart';
import 'tables/product_table.dart';
import 'tables/store_table.dart';
import 'tables/sync_queue_table.dart';
import 'tables/transaction_item_table.dart';
import 'tables/transaction_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Stores, Products, Transactions, TransactionItems, SyncQueue, PaymentEntries],
  daos: [StoreDao, ProductDao, TransactionDao, SyncQueueDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(syncQueue);
      }
      if (from < 3) {
        await m.addColumn(products, products.stock);
      }
      if (from < 4) {
        await m.addColumn(stores, stores.currencyCode);
      }
      if (from < 5) {
        await m.createTable(paymentEntries);
        await m.addColumn(stores, stores.supportedCurrencies);
        // Backfill: create payment entries for existing transactions
        await customStatement('''
          INSERT INTO payment_entries (transaction_id, method, currency_code, amount, amount_in_base_currency, exchange_rate)
          SELECT id, 'cash', currency_code, amount_tendered, amount_tendered, 1.0
          FROM transactions
          WHERE amount_tendered > 0
        ''');
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'talon.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
