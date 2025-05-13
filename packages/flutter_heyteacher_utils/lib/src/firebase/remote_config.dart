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

/// Initializes Firebase Remote Config with default values and fetch settings.
///
/// - Sets default parameters for fetch timeout and minimum fetch interval.
/// - Configures `RemoteConfigSettings` based on these defaults.
/// - For mobile platforms, listens for configuration updates and activates them.
/// - Fetches and activates the latest configuration from the Firebase backend.
Future<void> configureRemoteConfig() async {
  final log = Logger("configureRemoteConfig");

  // firebase remote config
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setDefaults({
    "remoteConfigFetchTimeoutInMilliseconds": 60000,
    "remoteConfigMinimumFetchIntervalInMinutes": 60,
  });
  remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: Duration(
        milliseconds:
            remoteConfig.getInt("remoteConfigFetchTimeoutInMilliseconds")),
    minimumFetchInterval: Duration(
        minutes: remoteConfig.getInt("remoteConfigFetchTimeoutInMilliseconds")),
  ));
  if (PlatformHelper.isMobile) {
    remoteConfig.onConfigUpdated.listen((RemoteConfigUpdate event) async {
      log.config("activate remote config updated keys: ${event.updatedKeys}");
      remoteConfig.activate();
    });
  }
  await remoteConfig.fetchAndActivate();
}
