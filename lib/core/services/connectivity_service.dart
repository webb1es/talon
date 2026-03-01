import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

/// Exposes network connectivity state as a stream and synchronous check.
@lazySingleton
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  late final StreamController<bool> _controller;
  late final Stream<bool> onConnectivityChanged;
  bool _isOnline = true;

  ConnectivityService() {
    _controller = StreamController<bool>.broadcast();
    onConnectivityChanged = _controller.stream;
    _connectivity.onConnectivityChanged.listen(_update);
    // Check initial state
    _connectivity.checkConnectivity().then(_update);
  }

  bool get isOnline => _isOnline;

  void _update(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (online != _isOnline) {
      _isOnline = online;
      _controller.add(_isOnline);
    }
  }

  @disposeMethod
  void dispose() {
    _controller.close();
  }
}
