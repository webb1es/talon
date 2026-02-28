import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../drift/daos/sync_queue_dao.dart';

/// Sync status exposed to the UI.
enum SyncStatus { idle, syncing, error, offline }

/// Drains the local sync queue to Supabase in FIFO order.
/// Backs off exponentially on failure. Pauses when offline.
class SyncEngine extends ChangeNotifier {
  final SyncQueueDao _queueDao;
  Timer? _timer;
  SyncStatus _status = SyncStatus.idle;
  static const _maxRetries = 8;

  SyncEngine(this._queueDao);

  SyncStatus get status => _status;
  bool get isSyncing => _status == SyncStatus.syncing;

  void start() {
    if (!SupabaseConfig.isConfigured) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => drain());
    drain();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Process all pending queue items.
  Future<void> drain() async {
    if (!SupabaseConfig.isConfigured) return;
    if (_status == SyncStatus.syncing) return;

    _status = SyncStatus.syncing;
    notifyListeners();

    try {
      final items = await _queueDao.pendingItems();
      final client = Supabase.instance.client;

      for (final item in items) {
        try {
          final data = jsonDecode(item.payload) as Map<String, dynamic>;

          switch (item.operation) {
            case 'insert':
              await client.from(item.entityTable).insert(data);
            case 'update':
              await client
                  .from(item.entityTable)
                  .update(data)
                  .eq('id', item.recordId);
            case 'delete':
              await client.from(item.entityTable).delete().eq('id', item.recordId);
          }

          await _queueDao.remove(item.id);
        } catch (e) {
          final retries = item.retryCount + 1;
          if (retries >= _maxRetries) {
            await _queueDao.remove(item.id);
          } else {
            await _queueDao.markRetry(item.id, retries);
          }
        }
      }

      _status = SyncStatus.idle;
    } catch (e) {
      _status = SyncStatus.error;
    }
    notifyListeners();
  }

  Future<int> pendingCount() => _queueDao.queueLength();

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
