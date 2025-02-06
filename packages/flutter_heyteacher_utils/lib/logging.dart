import 'dart:math';

import 'package:flutter_heyteacher_utils/firebase/auth.dart';

import 'formats.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<String> _device() async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  if (kIsWeb) {
    final webDeviceInfo = await deviceInfoPlugin.webBrowserInfo;
    return "web ${webDeviceInfo.browserName} ua ${webDeviceInfo.userAgent}";
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      {
        final androidDeviceInfo = await deviceInfoPlugin.androidInfo;
        return "android ${androidDeviceInfo.model} "
        "sdk ${androidDeviceInfo.version.sdkInt}"
        "(${androidDeviceInfo.version.release})";
      }
    case TargetPlatform.iOS:
      {
        final iosDeviceInfo = await deviceInfoPlugin.iosInfo;
        return "ios ${iosDeviceInfo.model} "
        "sysver ${iosDeviceInfo.systemVersion}";
      }
    default:
      {
        return defaultTargetPlatform.name;
      }
  }
}

Future<void> configureLogging() async {
  // logging configuration, if debug mode force level ALL
  Logger.root.level = Level(
      kDebugMode
          ? "ALL"
          : FirebaseRemoteConfig.instance.getString("loggerRootLevelName"),
      kDebugMode
          ? 0
          : FirebaseRemoteConfig.instance.getInt("loggerRootLevelValue"));
  // get version
  final packageInfo = await PackageInfo.fromPlatform();
  final String version = "${packageInfo.version}+${packageInfo.buildNumber}";
  final String device = await _device();
  Logger.root.onRecord.listen((record) {
    // format error and stack trace
    final String error = record.error != null ? "\n${record.error}" : "";
    final String stackTrace =
        record.stackTrace != null ? "\n${record.stackTrace}" : "";
    // get uid from firebase auth
    final String uid = Auth.instance().uid ?? "guest";
    // print in standard output
    if (kDebugMode) {
      print('${timeWithSecondsFormatter.format(record.time)} '
          '- version $version '
          '- $device '
          '- ${record.level.name} '
          '- $uid '
          '- ${record.loggerName} '
          '- ${record.message} '
          '$error'
          '$stackTrace');
    }
    // firebase analytics logging
    // message error and stacktrace are limited to 100 char
    FirebaseAnalytics.instance.logEvent(name: "logger", parameters: {
      "time": record.time.toLocal().toIso8601String(),
      "version": version,
      "device": device,
      "level": record.level.name,
      "kDebugMode": kDebugMode.toString(),
      "name": record.loggerName,
      "message": record.message.substring(0, min(record.message.length, 100)),
      if (record.error != null)
        "error": error.substring(0, min(error.length, 100)).trim(),
      if (record.stackTrace != null)
        "stackTrace":
            stackTrace.substring(0, min(stackTrace.length, 100)).trim(),
      "uid": uid
    });
  });
}
