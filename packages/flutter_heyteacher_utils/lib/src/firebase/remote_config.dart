/// Configures and initializes Firebase Remote Config for the application.
///
/// Firebase Remote Config allows for dynamic configuration of app parameters
/// from the Firebase console, enabling changes to the app's behavior and
/// appearance without requiring an app update. This library sets up default
/// values, fetch settings, and activates fetched configurations.
library;

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_heyteacher_utils/platform_helper.dart';
import 'package:logging/logging.dart';

enum RemoteConfigKeys {
  remoteConfigFetchTimeoutInMilliseconds,
  remoteConfigMinimumFetchIntervalInMinutes
}

class RemoteConfigModel {
  final _logger = Logger('RemoteConfigModel');

  final _remoteConfig = FirebaseRemoteConfig.instance;

  static RemoteConfigModel? _instance;
  RemoteConfigModel._();

  /// Provides the singleton instance of [RemoteConfigModel].
  static RemoteConfigModel get instance => _instance ??= RemoteConfigModel._();

  /// Initializes Firebase Remote Config with default values and fetch settings.
  ///
  /// - Sets default parameters for fetch timeout and minimum fetch interval.
  /// - Configures `RemoteConfigSettings` based on these defaults.
  /// - For mobile platforms, listens for configuration updates and activates them.
  /// - Fetches and activates the latest configuration from the Firebase backend.
  Future<void> initialize({Map<String, dynamic>? defaultParameters}) async {
    try {
      final log = Logger('configureRemoteConfig');

      defaultParameters ??= {};
      defaultParameters.addAll({
        RemoteConfigKeys.remoteConfigFetchTimeoutInMilliseconds.name: 60000,
        RemoteConfigKeys.remoteConfigMinimumFetchIntervalInMinutes.name: 60,
      });

      // firebase remote config
      await _remoteConfig.setDefaults(defaultParameters);
      _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: Duration(
            milliseconds: _remoteConfig.getInt(
                RemoteConfigKeys.remoteConfigFetchTimeoutInMilliseconds.name)),
        minimumFetchInterval: Duration(
            minutes: _remoteConfig.getInt(RemoteConfigKeys
                .remoteConfigMinimumFetchIntervalInMinutes.name)),
      ));
      if (PlatformHelper.isMobile) {
        _remoteConfig.onConfigUpdated.listen((RemoteConfigUpdate event) async {
          log.config(
              'activate remote config updated keys: ${event.updatedKeys}');
          _remoteConfig.activate();
        });
      }
      await _remoteConfig.fetchAndActivate();
    } catch (e, s) {
      _logger.severe('initialize: error, offline?', e, s);
    }
  }

  int getInt(String key) => _remoteConfig.getInt(key);
  String getString(String key) => _remoteConfig.getString(key);
  bool getBool(String key) => _remoteConfig.getBool(key);
  double getDouble(String key) => _remoteConfig.getDouble(key);
  num getNum(String key) => _remoteConfig.getInt(key) != 0
      ? _remoteConfig.getInt(key)
      : _remoteConfig.getDouble(key);
}
