import 'package:drift/drift.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/store.dart' as entity;
import '../../domain/repositories/store_repository.dart';
import '../drift/app_database.dart';
import '../drift/daos/store_dao.dart';

class DriftStoreRepository implements StoreRepository {
  final StoreDao _dao;

  DriftStoreRepository(this._dao);

  @override
  Future<Result<List<entity.Store>>> getStores() async {
    try {
      final rows = await _dao.allStores();
      final stores = rows
          .map((r) => entity.Store(
                id: r.id,
                name: r.name,
                address: r.address,
                currencyCode: r.currencyCode,
              ))
          .toList();
      return Success(stores);
    } catch (e) {
      return Fail(CacheFailure(e.toString()));
    }
  }
}

/// Seeds the stores table with initial data if empty.
Future<void> seedStores(StoreDao dao) async {
  final existing = await dao.allStores();
  if (existing.isNotEmpty) return;

  await dao.upsertAll([
    StoresCompanion.insert(id: '1', name: 'Downtown Branch', address: '12 Samora Machel Ave, Harare'),
    StoresCompanion.insert(id: '2', name: 'Mall Outlet', address: '45 Jason Moyo St, Bulawayo'),
    StoresCompanion.insert(id: '3', name: 'Airport Kiosk', address: 'Terminal 2, RGM Airport', currencyCode: const Value('ZWG')),
  ]);
}
