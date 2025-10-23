/// Configures and initializes Firebase Remote Config for the application.
///
/// Firebase Remote Config allows for dynamic configuration of app parameters
/// from the Firebase console, enabling changes to the app's behavior and
/// appearance without requiring an app update. This library sets up default
/// values, fetch settings, and activates fetched configurations.
library;

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_heyteacher_utils/platform_helper.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SharedPreferencesKeys {
  fhuThemeMode,
  fhuExecWorkerInIsolate,
  fhuLocale,
  fhuLoggingLevel,
    /// The name of the locally overridden logger level.
  htuLoggerLevelName,

  /// The value of the locally overridden logger level.
  htuLoggerLevelValue,

  /// A boolean flag to enable or disable log storage locally.
  htuEnableLogsStorage,
    /// Indicates whether the alarm manager needs to be initialized.
  htuFmcToBeInitialized,
}

enum RemoteConfigKeys {
  remoteConfigFetchTimeoutInMilliseconds,
  remoteConfigMinimumFetchIntervalInMinutes, 
  execWorkerInIsolate,
  /// The UID of a user for whom the logger level should be set to `FINEST`.
  loggerUIDRootLevelFinest,

  /// The default logger level name for debug builds.
  loggerDebugRootLevelName,

  /// The default logger level name for release builds.
  loggerRootLevelName,

  /// The default logger level value for debug builds.
  loggerDebugRootLevelValue,

  /// The default logger level value for release builds.
  loggerRootLevelValue,

  /// A boolean flag to enable or disable log storage via remote config.
  enableLogsStorage,

  /// the interval in minutes to check car bluetooth status.
  fmcIntervalInMinutes,

  /// the Firebase Cloud Messaging topic name
  fcmTopicName;

  /// Gets the appropriate remote config key for the logger level name based on
  /// the build mode (`kDebugMode`).
  static String get levelName =>
      kDebugMode ? loggerDebugRootLevelName.name : loggerRootLevelName.name;

  /// Gets the appropriate remote config key for the logger level value based on
  /// the build mode (`kDebugMode`).
  static String get levelValue =>
      kDebugMode ? loggerDebugRootLevelValue.name : loggerRootLevelValue.name;
}

class RemoteConfigViewModel {
  final _logger = Logger('RemoteConfigViewModel');

  final _remoteConfig = FirebaseRemoteConfig.instance;

  static RemoteConfigViewModel? _instance;
  
  @visibleForTesting
  RemoteConfigViewModel();

  /// Provides the singleton instance of [RemoteConfigViewModel].
  static RemoteConfigViewModel get instance =>
      _instance ??= RemoteConfigViewModel();

  @visibleForTesting
  static set instance(RemoteConfigViewModel value) => _instance = value;

  /// Initializes Firebase Remote Config with default values and fetch settings.
  ///
  /// - Sets default parameters for fetch timeout and minimum fetch interval.
  /// - Configures `RemoteConfigSettings` based on these defaults.
  /// - For mobile platforms, listens for configuration updates and activates them.
  /// - Fetches and activates the latest configuration from the Firebase backend.
  Future<void> initialize({Map<String, dynamic>? defaultParameters}) async {
    _logger.finest('<initialize>:');
    try {
      defaultParameters ??= {};
      defaultParameters.addAll({
        RemoteConfigKeys.remoteConfigFetchTimeoutInMilliseconds.name: 60000,
        RemoteConfigKeys.remoteConfigMinimumFetchIntervalInMinutes.name: 60,
      });

      // firebase remote config
      await _remoteConfig.setDefaults(defaultParameters);
      _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: Duration(
            milliseconds: _remoteConfig.getInt(
              RemoteConfigKeys.remoteConfigFetchTimeoutInMilliseconds.name,
            ),
          ),
          minimumFetchInterval: Duration(
            minutes: _remoteConfig.getInt(
              RemoteConfigKeys.remoteConfigMinimumFetchIntervalInMinutes.name,
            ),
          ),
        ),
      );
      _remoteConfig.onConfigUpdated.listen((RemoteConfigUpdate event) async {
        _logger.config(
          '(initialize): activate remote config updated keys: ${event.updatedKeys}',
        );
        _remoteConfig.activate();
      });
      await _remoteConfig.fetchAndActivate();
    } catch (error, stackTrace) {
      _logger.severe('(initialize): error', error, stackTrace);
    }
  }


  Future<bool> get execWorkerInIsolate async =>
      PlatformHelper.isNotWeb && (await SharedPreferencesAsync().getBool(
        SharedPreferencesKeys.fhuExecWorkerInIsolate.name,
      ) ??
      RemoteConfigViewModel.instance.getBool(
        RemoteConfigKeys.execWorkerInIsolate.name,
      ));

  int getInt(String key) => _remoteConfig.getInt(key);
  String getString(String key) => _remoteConfig.getString(key);
  bool getBool(String key) => _remoteConfig.getBool(key);
  double getDouble(String key) => _remoteConfig.getDouble(key);
  num getNum(String key) => _remoteConfig.getInt(key) != 0
      ? _remoteConfig.getInt(key)
      : _remoteConfig.getDouble(key);
}
