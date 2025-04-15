import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_heyteacher_utils/platform_helper.dart';
import 'package:logging/logging.dart';

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
