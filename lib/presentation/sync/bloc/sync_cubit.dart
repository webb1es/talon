import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/sync/sync_engine.dart';

// -- State --

class SyncState {
  final SyncStatus status;
  final int pendingCount;

  const SyncState({
    this.status = SyncStatus.idle,
    this.pendingCount = 0,
  });
}

// -- Cubit --

class SyncCubit extends Cubit<SyncState> {
  final SyncEngine _engine;
  late final VoidCallback _listener;

  SyncCubit(this._engine) : super(SyncState(status: _engine.status, pendingCount: _engine.pendingCount)) {
    _listener = () {
      emit(SyncState(status: _engine.status, pendingCount: _engine.pendingCount));
    };
    _engine.addListener(_listener);
  }

  void manualSync() => _engine.drain();

  @override
  Future<void> close() {
    _engine.removeListener(_listener);
    return super.close();
  }
}
