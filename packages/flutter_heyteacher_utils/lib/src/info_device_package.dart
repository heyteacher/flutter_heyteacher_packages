/// Provides utilities for retrieving device and application package
/// information and a widget to display this information along with a
/// support request option.
///
/// This library includes:
/// - [DevicePackageInfoCard]: A [ListTile] widget that displays formatted
///   device and package version information, and a button to initiate
///   a support email.
/// - [InfoDevicePackageViewModel]: A singleton class that fetches detailed
///   device information (OS, model, browser) and package information
///   (version, build number).
library;

import 'dart:async';

import 'package:clock/clock.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/formats.dart';
import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:flutter_heyteacher_utils/logger.dart';
import 'package:flutter_heyteacher_utils/platform_helper.dart';
import 'package:flutter_heyteacher_utils/src/connectivity.dart';
import 'package:flutter_heyteacher_utils/src/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/src/firebase/remote_config.dart';
import 'package:flutter_heyteacher_utils/src/firebase/storage.dart';
import 'package:flutter_heyteacher_utils/src/logger/logger_view_model.dart';
import 'package:flutter_heyteacher_utils/src/widgets.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// A widget that displays device and package information in a list tile format.
///
/// It asynchronously fetches and shows the device identifier, device details
/// (model, OS version),
/// and the application's version and build number.
/// It also includes a "Support" button that opens the default email client
/// It shows the device type, version, and a button to ask for support.
class DevicePackageInfoCard extends StatelessWidget {
  /// Creates a [DevicePackageInfoCard].
  const DevicePackageInfoCard({super.key});

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      key: const ValueKey('lt_fhu_version'),
      leading: IconButton(
        icon: const Icon(Icons.smartphone),
        onPressed: InfoDevicePackageViewModel.instance._incrementTapCounter,
      ),
      title: FutureBuilder(
        future: InfoDevicePackageViewModel.instance.deviceInfo,
        builder: (_, deviceSnapshot) => Text(
          '${FlutterHeyteacherUtilsLocalizations.of(context)!.id}'
          '${deviceSnapshot.data}',
        ),
      ),
      subtitle: FutureBuilder<String>(
        future: InfoDevicePackageViewModel.instance.packageVersion,
        builder: (_, devicePackageSnapshot) => Text(
          '${FlutterHeyteacherUtilsLocalizations.of(context)!.version}'
          '${devicePackageSnapshot.data}',
        ),
      ),
      trailing: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: ThemeViewModel.instance.colorScheme.primary,
          foregroundColor: ThemeViewModel.instance.colorScheme.onPrimary,
        ),
        onPressed: () =>
            InfoDevicePackageViewModel.instance._askSupport(context),
        child: Text(
          FlutterHeyteacherUtilsLocalizations.of(context)!.askSupport,
        ),
      ),
    ),
  );
}

/// A singleton model class responsible for fetching and providing
/// device-specific information and application package details.
///
/// Access the singleton instance via `InfoDevicePackageModel.instance`.
class InfoDevicePackageViewModel {
  /// Private constructor for the singleton.
  InfoDevicePackageViewModel._() {
    _streamSubscription = Stream<dynamic>.periodic(
      const Duration(seconds: 5),
    ).listen((_) => _tapCounter = 0);
  }
  static final _logger = Logger('InfoDevicePackageViewModel');
  static InfoDevicePackageViewModel? _instance;

  /// Provides the singleton instance of [InfoDevicePackageViewModel].
  // ignore: prefer_constructors_over_static_methods
  static InfoDevicePackageViewModel get instance =>
      _instance ??= InfoDevicePackageViewModel._();

  StreamSubscription<dynamic>? _streamSubscription;

  /// on dispose object
  void dispose() {
    unawaited(_streamSubscription?.cancel());
    unawaited(_tapCounterReachedStreamController.close());
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
    final deviceInfoPlugin = DeviceInfoPlugin();
    if (PlatformHelper.isWeb) {
      final webDeviceInfo = await deviceInfoPlugin.webBrowserInfo;
      return (!kDebugMode)? 'ua-${webDeviceInfo.userAgent}': 'ua-debug';
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
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        {
          return defaultTargetPlatform.name;
        }
    }
  }

  /// Asynchronously retrieves the application's package version and build
  /// number.
  ///
  /// Formats it as "version+buildNumber".
  Future<String> get packageVersion async {
    final packageInfoPlatform = await PackageInfo.fromPlatform();
    return '${packageInfoPlatform.version}+${packageInfoPlatform.buildNumber}';
  }

  /// Gets a user identifier string.
  ///
  /// It returns the first 7 characters of the authenticated user's UID if
  /// available, otherwise defaults to "guest".
  String get identifierInfo =>
      AuthViewModel.instance.uid?.substring(0, 7) ?? 'guest';

  /// uploads the logs to Firebase Storage and returns the log filename.
  ///
  /// If `enableLogsStorage` is false, returns "Logs storage disabled" message
  /// instead.
  Future<String> storeLogs({DateTime? startTime}) async {
    if (!await LoggerViewModel.instance().enableLogsStorage) {
      _logger.finer('enableLogsStorage is false, return null');
      return 'Logs storage disabled';
    }
    if (await ConnectivityViewModel.instance.notConnected) {
      // await connection
      await ConnectivityViewModel.instance.stream
          .where((connected) => connected)
          .first;
    }
    final machineStartDateTime = FormatterHelper.machineDateTimeFormat(
      startTime ?? clock.now(),
    );
    final machineStopTime = FormatterHelper.machineTimeFormat(clock.now());
    final relativeFilename =
        '$machineStartDateTime-$machineStopTime'
        '-${InfoDevicePackageViewModel.instance.identifierInfo}.log.gz';

    final content = await LoggerViewModel.instance().logs2Text(
      startTime: startTime?.subtract(const Duration(seconds: 10)),
    );
    unawaited(
      StorageViewModel.instance.appLogsUpload(
        relativeFilename: relativeFilename,
        content: content,
        encodeGZip: true,
      ),
    );
    return relativeFilename;
  }

  /// Constructs and launches a "mailto" URI to allow users to ask for support.
  ///
  /// The email is pre-filled with:
  /// - A subject line indicating the app name.
  /// - A body containing the user's identifier, device information, and app
  ///   version, formatted for easy support.
  Future<void> _askSupport(BuildContext context) async {
    assert(
      RemoteConfigViewModel.instance.getString('supportEmail').isNotEmpty,
      'supportEmail is empty',
    );
    final i10n = FlutterHeyteacherUtilsLocalizations.of(context)!;
    if (await ConnectivityViewModel.instance.notConnected && context.mounted) {
      showSnackBar(
        context: context,
        message: i10n.deviceOfflineAskSupportWhenOnline,
        error: true,
      );
      return;
    }
    final logFilename = await storeLogs();
    final packageInfoPlatform = await PackageInfo.fromPlatform();
    final version = await InfoDevicePackageViewModel.instance.packageVersion;
    final device = await InfoDevicePackageViewModel.instance.deviceInfo;
    final identifierInfo = InfoDevicePackageViewModel.instance.identifierInfo;
    final subject =
        '${i10n.askSupportFor}'
        '${packageInfoPlatform.appName}';
    final body =
        '------------------------------------\n'
        'Identifier:\t$identifierInfo\n'
        'Device:\t$device\n'
        'Version:\t$version\n'
        'Logs:\t$logFilename\n'
        '------------------------------------\n'
        '\n';
    final uri = Uri(
      scheme: 'mailto',
      path: RemoteConfigViewModel.instance.getString('supportEmail'),
      query: 'subject=$subject&body=${Uri.encodeFull(body)}',
    );
    unawaited(launchUrl(uri));
  }
}
