library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logging/logging.dart';

/// A singleton controller for monitoring network connectivity status.
///
/// This class uses the `connectivity_plus` package to provide a stream
/// of connectivity changes and a method to check the current connectivity state.
class ConnectivityModelView {
  static final _logger = Logger('ConnectivityController');

  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _streamSubscription;

  static ConnectivityModelView? _instance;

  /// The singleton instance of [ConnectivityModelView].
  static ConnectivityModelView get instance =>
      _instance ??= ConnectivityModelView._();

  ConnectivityModelView._() {
    _streamSubscription = stream.listen((connected) {
      _logger.finest('onConnectivityChanged: $connected');
    });
  }

  /// Disposes the controller, canceling the stream subscription to prevent memory leaks.
  ///
  /// This should be called when the controller is no longer needed.
  dispose() {
    _streamSubscription?.cancel();
  }

  /// A stream that emits the connectivity status whenever it changes.
  ///
  /// Emits `true` if there is at least one active connection (e.g., WiFi, mobile data).
  /// Emits `false` if there are no active connections (`ConnectivityResult.none`).
  Stream<bool> get stream => _connectivity.onConnectivityChanged.map(
      (connectivityResultList) => connectivityResultList
          .where((connectivityResult) =>
              connectivityResult != ConnectivityResult.none)
          .isNotEmpty);

  /// A future that completes with the current connectivity status.
  ///
  /// Returns `true` if there is at least one active connection, `false` otherwise.
  Future<bool> get connected async => (await _connectivity.checkConnectivity())
      .where(
          (connectivityResult) => connectivityResult != ConnectivityResult.none)
      .isNotEmpty;

  Future<bool> get notConnected async => !await connected;
}
