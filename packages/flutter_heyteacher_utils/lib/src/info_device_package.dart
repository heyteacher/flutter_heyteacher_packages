/// Provides utilities for retrieving device and application package information,
/// and a widget to display this information along with a support request option.
///
/// This library includes:
/// - [DevicePackageInfoCard]: A [ListTile] widget that displays formatted
///   device and package version information, and a button to initiate a support email.
/// - [InfoDevicePackageModel]: A singleton class that fetches detailed device
///   information (OS, model, browser) and package information (version, build number).
library;

import 'dart:async';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/context_helper.dart';
import 'package:flutter_heyteacher_utils/formats.dart';
import 'package:flutter_heyteacher_utils/logger.dart';
import 'package:flutter_heyteacher_utils/src/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:flutter_heyteacher_utils/src/firebase/storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// A widget that displays device and package information in a list tile format.
///
/// It asynchronously fetches and shows the device identifier, device details (model, OS version),
/// and the application's version and build number.
/// It also includes a "Support" button that opens the default email client
/// It shows the device type, version, and a button to ask for support.
class DevicePackageInfoCard extends StatelessWidget {
  const DevicePackageInfoCard({super.key});

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
            key: const ValueKey('lt_fhu_version'),
            leading: IconButton(
              icon: const Icon(Icons.smartphone),
              onPressed: InfoDevicePackageModel.instance._incrementTapCounter,
            ),
            title: FutureBuilder(
              future: InfoDevicePackageModel.instance.deviceInfo,
              builder: (_, deviceSnapshot) =>
                  Text('${FlutterHeyteacherUtilsLocalizations.of(context)!.id}'
                      '${deviceSnapshot.data}-${deviceSnapshot.data}'),
            ),
            subtitle: FutureBuilder<String>(
              future: InfoDevicePackageModel.instance.packageVersion,
              builder: (_, devicePackageSnapshot) => Text(
                  '${FlutterHeyteacherUtilsLocalizations.of(context)!.version}'
                  '${devicePackageSnapshot.data}'),
            ),
            trailing: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary,
                  foregroundColor:
                      Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: InfoDevicePackageModel.instance._askSupport,
                child: Text(FlutterHeyteacherUtilsLocalizations.of(context)!
                    .askSupport))),
      );
}

/// A singleton model class responsible for fetching and providing
/// device-specific information and application package details.
///
/// Access the singleton instance via `InfoDevicePackageModel.instance`.
class InfoDevicePackageModel {
  static InfoDevicePackageModel? _instance;

  /// Provides the singleton instance of [InfoDevicePackageModel].
  static InfoDevicePackageModel get instance =>
      _instance ??= InfoDevicePackageModel._();

  StreamSubscription? _streamSubscription;

  /// Private constructor for the singleton.
  InfoDevicePackageModel._() {
    _streamSubscription = Stream.periodic(const Duration(seconds: 5))
        .listen((_) => _tapCounter = 0);
  }

  dispose() {
    _streamSubscription?.cancel();
    _tapCounterReachedStreamController.close();
  }

  /// The current tap counter value.
  ///
  int _tapCounter = 0;

  /// A stream controller to broadcast the tap counter.
  final StreamController<bool> _tapCounterReachedStreamController =
      StreamController<bool>.broadcast();

  /// A stream that emits an event whenever tap counter changes.
  ///
  /// Widgets can listen to this stream to rebuild when the theme is updated.
  /// The emitted value is typically `null` and serves as a notification.
  Stream<bool> get tapCounterReachedStream =>
      _tapCounterReachedStreamController.stream;

  /// Increments the tap counter and broadcasts the new value.
  void _incrementTapCounter() =>
      _tapCounterReachedStreamController.sink.add((++_tapCounter) >= 5);

  /// Asynchronously retrieves detailed information about the current device.
  ///
  /// For web, it returns browser name and user agent.
  /// For mobile (Android/iOS), it returns model, OS version, and SDK/system version.
  /// For other platforms, it returns the platform name.
  Future<String> get deviceInfo async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (kIsWeb) {
      final webDeviceInfo = await deviceInfoPlugin.webBrowserInfo;
      return 'w-${webDeviceInfo.browserName}-ua-${webDeviceInfo.userAgent}';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        {
          final androidDeviceInfo = await deviceInfoPlugin.androidInfo;
          return 'a-${androidDeviceInfo.model}-'
              'sdk-${androidDeviceInfo.version.sdkInt}-'
              '${androidDeviceInfo.version.release}';
        }
      case TargetPlatform.iOS:
        {
          final iosDeviceInfo = await deviceInfoPlugin.iosInfo;
          return 'i-${iosDeviceInfo.model}-'
              'sysver-${iosDeviceInfo.systemVersion}';
        }
      default:
        {
          return defaultTargetPlatform.name;
        }
    }
  }

  /// Asynchronously retrieves the application's package version and build number.
  ///
  /// Formats it as "version+buildNumber".
  Future<String> get packageVersion async {
    final packageInfoPlatform = await PackageInfo.fromPlatform();
    return '${packageInfoPlatform.version}+${packageInfoPlatform.buildNumber}';
  }

  /// Gets a user identifier string.
  ///
  /// It returns the first 5 characters of the authenticated user's UID if available,
  /// otherwise defaults to "guest".
  String get identifierInfo =>
      (AuthModel.instance().uid?.substring(0, 5)) ?? 'guest';

  /// uploads the logs to Firebase Storage and returns the log filename
  Future<String> storeLogs() async {
    final machineDate = machineDateFormatter.format(clock.now());
    final machineTime = machineTimeFormatter.format(clock.now());
    final randomId = Random().nextInt(1000000000).toString().padLeft(10, '0');
    final logFilename =
        'applogs/$machineDate/$machineTime-${InfoDevicePackageModel.instance.identifierInfo}-$randomId.log';
    StorageModel.instance
        .uploadString(logFilename, await LoggerModel.instance().logs2Text);
    return logFilename;
  }

  /// Constructs and launches a "mailto" URI to allow users to ask for support.
  ///
  /// The email is pre-filled with:
  /// - A subject line indicating the app name.
  /// - A body containing the user's identifier, device information, and app version,
  ///   formatted for easy support.
  void _askSupport() async {
    final i10n =
        FlutterHeyteacherUtilsLocalizations.of(ContextHelper.context!)!;
    final packageInfoPlatform = await PackageInfo.fromPlatform();
    final version = await InfoDevicePackageModel.instance.packageVersion;
    final device = await InfoDevicePackageModel.instance.deviceInfo;
    final identifierInfo = InfoDevicePackageModel.instance.identifierInfo;
    final logFilename = await storeLogs();
    final subject = '${i10n.askSupportFor}'
        '${packageInfoPlatform.appName}';
    final body = '------------------------------------\n'
        'Identifier:\t$identifierInfo\n'
        'Device:\t$device\n'
        'Version:\t$version\n'
        'Logs:\t$logFilename\n'
        '------------------------------------\n'
        '\n';
    final uri = Uri(
      scheme: 'mailto',
      path: 'heyteacher70@gmail.com',
      query: 'subject=$subject&body=${Uri.encodeFull(body)}',
    );
    launchUrl(uri);
  }
}
