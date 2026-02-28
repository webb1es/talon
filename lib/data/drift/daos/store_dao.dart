import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/store_table.dart';

part 'store_dao.g.dart';

@DriftAccessor(tables: [Stores])
class StoreDao extends DatabaseAccessor<AppDatabase> with _$StoreDaoMixin {
  StoreDao(super.db);

  Future<List<Store>> allStores() => select(stores).get();

  Future<void> upsertStore(StoresCompanion entry) =>
      into(stores).insertOnConflictUpdate(entry);

  Future<void> upsertAll(List<StoresCompanion> entries) async {
    await batch((b) {
      for (final entry in entries) {
        b.insert(stores, entry, onConflict: DoUpdate((_) => entry));
      }
    });
  }
}
