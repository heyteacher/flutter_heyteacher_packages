import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// A singleton controller for monitoring network connectivity status.
///
/// This class uses the `internet_connection_checker_plus` package to provide a
/// stream of connectivity changes and a method to check the current
/// connectivity state.
class ConnectivityViewModel {
  ConnectivityViewModel._();

  static ConnectivityViewModel? _instance;

  /// The singleton instance of [ConnectivityViewModel].
  // ignore: prefer_constructors_over_static_methods
  static ConnectivityViewModel get instance =>
      _instance ??= ConnectivityViewModel._();

  @visibleForTesting
  static set instance(ConnectivityViewModel instance) => _instance = instance;

  final InternetConnection _internetConnection =
      InternetConnection.createInstance();

  /// Disposes the controller, canceling the stream subscription to prevent
  ///  memory leaks.
  ///
  /// This should be called when the controller is no longer needed.
  void dispose() => unawaited(_internetConnection.dispose());

  /// A stream that emits the internet status whenever it changes.
  ///
  /// Emits `true` if there is an active internet connection
  /// Emits `false` if there is no active internet connection
  Stream<bool> get stream => _internetConnection.onStatusChange.map(
    (internetStatus) => internetStatus == InternetStatus.connected,
  );

  /// Returns `true` if there is an active internet connection
  /// Returns `false` if there is no active internet connection
  Future<bool> get connected async =>
      (await _internetConnection.internetStatus) == InternetStatus.connected;

  /// Returns `false` if there is an active internet connection
  /// Returns `true` if there is no active internet connection
  Future<bool> get notConnected async => !await connected;
}
