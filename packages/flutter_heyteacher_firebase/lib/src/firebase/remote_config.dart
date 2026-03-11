/// Configures and initializes Firebase Remote Config for the application.
///
/// Firebase Remote Config allows for dynamic configuration of app parameters
/// from the Firebase console, enabling changes to the app's behavior and
/// appearance without requiring an app update. This library sets up default
/// values, fetch settings, and activates fetched configurations.
library;

import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Keys for values stored in `SharedPreferences`.
///
/// This enum standardizes the keys used for local data persistence, preventing
/// typos and making it easier to manage stored preferences.
enum FlutterHeyteacherUtilsSharedPreferencesKeys {

  /// Indicates whether the Firebase Cloud Messaging background handler needs
  /// to be initialized.
  htuFmcToBeInitialized,
}

/// Keys for values fetched from Firebase Remote Config.
enum FHURemoteConfigKeys {
  /// The fetch timeout in milliseconds for Firebase Remote Config.
  remoteConfigFetchTimeoutInMilliseconds,

  /// The minimum fetch interval in minutes for Firebase Remote Config.
  remoteConfigMinimumFetchIntervalInMinutes,

  /// The interval in minutes for the Firebase Cloud Messaging background task.
  fmcIntervalInMinutes,

  /// The Firebase Cloud Messaging topic name to subscribe to.
  fcmTopicName,
}

/// A view model for managing Firebase Remote Config.
///
/// This singleton class handles the initialization, fetching, and activation of
/// remote configuration values, allowing for dynamic updates to the app's
/// behavior and appearance without requiring a new release.
class RemoteConfigViewModel {
  @visibleForTesting
  /// Creates an instance of [RemoteConfigViewModel].
  RemoteConfigViewModel();
  final _logger = Logger('RemoteConfigViewModel');

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static RemoteConfigViewModel? _instance;

  /// Provides the singleton instance of [RemoteConfigViewModel].
  // ignore: prefer_constructors_over_static_methods
  static RemoteConfigViewModel get instance =>
      _instance ??= RemoteConfigViewModel();

  @visibleForTesting
  static set instance(RemoteConfigViewModel value) => _instance = value;

  /// Initializes Firebase Remote Config with default values and fetch settings.
  ///
  /// - Sets default parameters for fetch timeout and minimum fetch interval.
  /// - Configures `RemoteConfigSettings` based on these defaults.
  /// - For mobile platforms, listens for configuration updates and activates
  ///   them.
  /// - Fetches and activates the latest configuration from the Firebase
  /// backend.
  Future<void> initialize({Map<String, dynamic>? defaultParameters}) async {
    _logger.finer('<initialize>:');
    try {
      defaultParameters ??= {};
      defaultParameters.addAll({
        FHURemoteConfigKeys.remoteConfigFetchTimeoutInMilliseconds.name: 60000,
        FHURemoteConfigKeys.remoteConfigMinimumFetchIntervalInMinutes.name: 60,
      });

      // firebase remote config
      await _remoteConfig.setDefaults(defaultParameters);
      unawaited(
        _remoteConfig.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: Duration(
              milliseconds: _remoteConfig.getInt(
                FHURemoteConfigKeys.remoteConfigFetchTimeoutInMilliseconds.name,
              ),
            ),
            minimumFetchInterval: Duration(
              minutes: _remoteConfig.getInt(
                FHURemoteConfigKeys
                    .remoteConfigMinimumFetchIntervalInMinutes
                    .name,
              ),
            ),
          ),
        ),
      );
      _remoteConfig.onConfigUpdated.listen((event) async {
        _logger.config(
          '(initialize): activate remote config updated keys: '
          '${event.updatedKeys}',
        );
        unawaited(_remoteConfig.activate());
      });
      await _remoteConfig.fetchAndActivate();
    } on Exception catch (error, stackTrace) {
      _logger.severe('(initialize): error', error, stackTrace);
    }
  }

  /// Gets an integer value from Remote Config for the given [key].
  int getInt(String key) => _remoteConfig.getInt(key);

  /// Gets a string value from Remote Config for the given [key].
  String getString(String key) => _remoteConfig.getString(key);

  /// Gets a boolean value from Remote Config for the given [key].
  bool getBool(String key) => _remoteConfig.getBool(key);

  /// Gets a double value from Remote Config for the given [key].
  double getDouble(String key) => _remoteConfig.getDouble(key);

  /// Gets a numeric value from Remote Config for the given [key].
  /// It attempts to get an integer first, then falls back to a double.
  num getNum(String key) => _remoteConfig.getInt(key) != 0
      ? _remoteConfig.getInt(key)
      : _remoteConfig.getDouble(key);
}
