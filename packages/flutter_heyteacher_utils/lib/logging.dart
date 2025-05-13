/// Configures and initializes the application's logging system.
///
/// This library sets up a global logger that:
/// - Outputs detailed logs to the console when in debug mode (`kDebugMode`).
/// - Sends structured log events to Firebase Analytics.
/// - Dynamically sets the root logger level based on Firebase Remote Config
///   (or defaults to a verbose level in debug mode).
/// - Enriches log messages with application version, device information, and a unique identifier.
library;

import 'dart:math';
import 'package:flutter_heyteacher_utils/info_device_package.dart';
import 'formats.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Configures the root logger for the application.
///
/// Sets the logger's level based on `kDebugMode` and Firebase Remote Config.
/// It then attaches a listener that processes log records to:
/// 1. Print formatted logs to the console if `kDebugMode` is true.
/// 2. Send structured log events to Firebase Analytics, including version,
///    device info, level, message, error (if any), stack trace (if any), and a user identifier.
///    Message, error, and stack trace are truncated to 100 characters for Firebase.
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
