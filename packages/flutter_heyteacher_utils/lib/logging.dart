import 'dart:math';

import 'formats.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> configureLogging() async {
  // logging configuration, if debug mode force level ALL
  Logger.root.level = Level(
      kDebugMode
          ? "ALL"
          : FirebaseRemoteConfig.instance.getString("loggerRootLevelName"),
      kDebugMode
          ? 0
          : FirebaseRemoteConfig.instance
              .getInt("loggerRootLevelValue")); 
  // get version
  final packageInfo = await PackageInfo.fromPlatform();
  final String version = "${packageInfo.version}+${packageInfo.buildNumber}";
  Logger.root.onRecord.listen((record) {
    // format error and stack trace
    final String error = record.error != null ? "\n${record.error}" : "";
    final String stackTrace =
        record.stackTrace != null ? "\n${record.stackTrace}" : "";
    // get uid from firebase auth
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "guest";
    // print in standard output
    if (kDebugMode) {
      print('${timeWithSecondsFormatter.format(record.time)} '
        '- version $version '
        '- ${record.level.name} '
        '- $uid '
        '- ${record.loggerName} '
        '- ${record.message} '
        '$error'
        '$stackTrace');
    }
    // firebase analytics logging
    FirebaseAnalytics.instance.logEvent(name: "logger", parameters: {
      "time": record.time.toLocal().toIso8601String(),
      "version": version,
      "level": record.level.name,
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
