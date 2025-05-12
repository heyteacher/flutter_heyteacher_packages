import 'dart:math';
import 'package:flutter_heyteacher_utils/info_device_package.dart';
import 'formats.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

Future<void> configureLogging() async {
  // logging configuration, if debug mode force level ALL
  Logger.root.level = Level(
      kDebugMode
          ? "FINE"
          : FirebaseRemoteConfig.instance.getString("loggerRootLevelName"),
      kDebugMode
          ? 500
          : FirebaseRemoteConfig.instance.getInt("loggerRootLevelValue"));
  // get version
  final version = await InfoDevicePackageModel.instance.packageVersion;
  // get device info
  final String device = await InfoDevicePackageModel.instance.deviceInfo;
  // get identifier info
  final identifierInfo = InfoDevicePackageModel.instance.identifierInfo;
  Logger.root.onRecord.listen((record) {
    // format error and stack trace
    final String error = record.error != null ? "\n${record.error}" : "";
    final String stackTrace =
        record.stackTrace != null ? "\n${record.stackTrace}" : "";
    // print in standard output
    if (kDebugMode) {
      print('${timeWithSecondsFormatter.format(record.time)} '
          '- version $version '
          '- $device '
          '- ${record.level.name} '
          '- $identifierInfo '
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
      "uid": identifierInfo
    });
  });
}
