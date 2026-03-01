import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../core/services/connectivity_service.dart';
import '../drift/daos/sync_queue_dao.dart';

/// Sync status exposed to the UI.
enum SyncStatus { idle, syncing, error, offline }

/// Drains the local sync queue to Supabase in FIFO order.
/// Backs off exponentially on failure. Pauses when offline.
class SyncEngine extends ChangeNotifier {
  final SyncQueueDao _queueDao;
  final ConnectivityService _connectivity;
  Timer? _timer;
  StreamSubscription<bool>? _connectivitySub;
  SyncStatus _status = SyncStatus.idle;
  int _pendingCount = 0;
  static const _maxRetries = 8;
  static const _pollInterval = Duration(seconds: 15);

  SyncEngine(this._queueDao, this._connectivity);

  SyncStatus get status => _status;
  int get pendingCount => _pendingCount;
  bool get isSyncing => _status == SyncStatus.syncing;

  void start() {
    _connectivitySub?.cancel();
    _connectivitySub = _connectivity.onConnectivityChanged.listen((online) {
      if (online) {
        _setStatus(SyncStatus.idle);
        drain();
      } else {
        _timer?.cancel();
        _setStatus(SyncStatus.offline);
      }
    });

    if (!_connectivity.isOnline) {
      _setStatus(SyncStatus.offline);
      _refreshCount();
      return;
    }

    _scheduleTimer();
    drain();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  /// Process all pending queue items.
  Future<void> drain() async {
    if (!SupabaseConfig.isConfigured) return;
    if (_status == SyncStatus.syncing) return;
    if (!_connectivity.isOnline) {
      _setStatus(SyncStatus.offline);
      return;
    }

    _setStatus(SyncStatus.syncing);

    try {
      final items = await _queueDao.pendingItems();
      if (items.isEmpty) {
        _pendingCount = 0;
        _setStatus(SyncStatus.idle);
        _scheduleTimer();
        return;
      }

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

      await _refreshCount();
      _setStatus(_pendingCount > 0 ? SyncStatus.error : SyncStatus.idle);
    } catch (e) {
      await _refreshCount();
      _setStatus(SyncStatus.error);
    }

    _scheduleTimer();
  }

  Future<void> _refreshCount() async {
    _pendingCount = await _queueDao.queueLength();
    notifyListeners();
  }

  void _setStatus(SyncStatus s) {
    if (_status == s) return;
    _status = s;
    notifyListeners();
  }

  void _scheduleTimer() {
    _timer?.cancel();
    if (_connectivity.isOnline) {
      _timer = Timer(_pollInterval, drain);
    }
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
