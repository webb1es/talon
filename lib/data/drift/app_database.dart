import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/product_dao.dart';
import 'daos/store_dao.dart';
import 'daos/sync_queue_dao.dart';
import 'daos/transaction_dao.dart';
import 'tables/product_table.dart';
import 'tables/store_table.dart';
import 'tables/sync_queue_table.dart';
import 'tables/transaction_item_table.dart';
import 'tables/transaction_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Stores, Products, Transactions, TransactionItems, SyncQueue],
  daos: [StoreDao, ProductDao, TransactionDao, SyncQueueDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(syncQueue);
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
