
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';


/// A singleton controller for monitoring network connectivity status.
///
/// This class uses the `connectivity_plus` package to provide a stream
/// of connectivity changes and a method to check the current connectivity 
/// state.
class ConnectivityViewModel {

  /// Disposes the singleton instance of [ConnectivityViewModel)

  ConnectivityViewModel._() {
    _streamSubscription = stream.listen((connected) {
      _logger.info('<onConnectivityChanged>: connected $connected');
    });
  }
  static final _logger = Logger('ConnectivityViewModel');

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<bool>? _streamSubscription;

  static ConnectivityViewModel? _instance;

  /// The singleton instance of [ConnectivityViewModel].
  // ignore: prefer_constructors_over_static_methods
  static ConnectivityViewModel get instance =>
      _instance ??= ConnectivityViewModel._();

  @visibleForTesting
  static set instance(ConnectivityViewModel instance) => _instance = instance;

  /// Disposes the controller, canceling the stream subscription to prevent
  ///  memory leaks.
  ///
  /// This should be called when the controller is no longer needed.
  void dispose() {
    unawaited(_streamSubscription?.cancel());
  }

  /// A stream that emits the connectivity status whenever it changes.
  ///
  /// Emits `true` if there is at least one active connection 
  /// (e.g., WiFi, mobile data).
  /// Emits `false` if there are no active connections 
  /// (`ConnectivityResult.none`).
  Stream<bool> get stream => _connectivity.onConnectivityChanged.map(
      (connectivityResultList) => connectivityResultList
          .where((connectivityResult) =>
              connectivityResult != ConnectivityResult.none)
          .isNotEmpty);

  /// A future that completes with the current connectivity status.
  ///
  /// Returns `true` if there is at least one active connection, 
  /// `false` otherwise.
  Future<bool> get connected async => (await _connectivity.checkConnectivity())
      .where(
          (connectivityResult) => connectivityResult != ConnectivityResult.none)
      .isNotEmpty;

  /// A future that completes with the opposite of [connected].
  Future<bool> get notConnected async => !await connected;
}
