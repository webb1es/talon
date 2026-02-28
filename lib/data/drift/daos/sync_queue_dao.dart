import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<List<SyncQueueData>> pendingItems() {
    final now = DateTime.now();
    return (select(syncQueue)
          ..where((q) =>
              q.nextRetryAt.isNull() | q.nextRetryAt.isSmallerOrEqualValue(now))
          ..orderBy([(q) => OrderingTerm.asc(q.id)]))
        .get();
  }

  Future<int> enqueue({
    required String entityTable,
    required String recordId,
    required String operation,
    required String payload,
  }) =>
      into(syncQueue).insert(SyncQueueCompanion.insert(
        entityTable: entityTable,
        recordId: recordId,
        operation: operation,
        payload: payload,
        createdAt: DateTime.now(),
      ));

  Future<void> markRetry(int id, int retryCount) {
    final backoff = Duration(seconds: 1 << retryCount); // exponential
    return (update(syncQueue)..where((q) => q.id.equals(id))).write(
      SyncQueueCompanion(
        retryCount: Value(retryCount),
        nextRetryAt: Value(DateTime.now().add(backoff)),
      ),
    );
  }

  Future<int> remove(int id) =>
      (delete(syncQueue)..where((q) => q.id.equals(id))).go();

  Future<int> queueLength() async {
    final count = syncQueue.id.count();
    final query = selectOnly(syncQueue)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
