/// Provides utilities for retrieving device and application package information,
/// and a widget to display this information along with a support request option.
///
/// This library includes:
/// - [DevicePackageInfoListTile]: A [ListTile] widget that displays formatted
///   device and package version information, and a button to initiate a support email.
/// - [InfoDevicePackageModel]: A singleton class that fetches detailed device
///   information (OS, model, browser) and package information (version, build number).
library;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/context_helper.dart';
import 'package:flutter_heyteacher_utils/src/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/localizations.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// A widget that displays device and package information in a list tile format.
///
/// It asynchronously fetches and shows the device identifier, device details (model, OS version),
/// and the application's version and build number.
/// It also includes a "Support" button that opens the default email client
/// It shows the device type, version, and a button to ask for support.
class DevicePackageInfoListTile extends StatelessWidget {
  const DevicePackageInfoListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey("lt_fhu_version"),
      leading: Icon(
        Icons.smartphone,
      ),
      title: FutureBuilder(
        future: InfoDevicePackageModel.instance.deviceInfo,
        builder: (_, deviceSnapshot) =>
            Text("${FlutterHeyteacherUtilsLocalizations.of(context)!.id}"
                "${deviceSnapshot.data}-${deviceSnapshot.data}"),
      ),
      subtitle: FutureBuilder<String>(
        future: InfoDevicePackageModel.instance.packageVersion,
        builder: (_, devicePackageSnapshot) =>
            Text("${FlutterHeyteacherUtilsLocalizations.of(context)!.version}"
                "${devicePackageSnapshot.data}"),
      ),
      trailing: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: ThemeModel.instance().theme.colorScheme.primary,
            foregroundColor: ThemeModel.instance().theme.colorScheme.onPrimary,
          ),
          onPressed: _askSupport,
          child:
              Text(FlutterHeyteacherUtilsLocalizations.of(context)!.support)),
    );
  }
}

/// Constructs and launches a "mailto" URI to allow users to ask for support.
///
/// The email is pre-filled with:
/// - A subject line indicating the app name.
/// - A body containing the user's identifier, device information, and app version,
///   formatted for easy support.
void _askSupport() async {
  final packageInfoPlatform = await PackageInfo.fromPlatform();
  final version = await InfoDevicePackageModel.instance.packageVersion;
  final device = await InfoDevicePackageModel.instance.deviceInfo;
  final subject =
      "${FlutterHeyteacherUtilsLocalizations.of(ContextHelper.context!)!.askSupportFor}"
      "${packageInfoPlatform.appName}";
  final body = "------------------------------------\n"
      "Identifier:\t${InfoDevicePackageModel.instance.identifierInfo}-$device\n"
      "Version:\t$version\n"
      "------------------------------------\n"
      "\n";
  final uri = Uri(
    scheme: "mailto",
    path: "heyteacher70@gmail.com",
    query: "subject=$subject&body=${Uri.encodeFull(body)}",
  );
  launchUrl(uri);
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

  /// Private constructor for the singleton.
  InfoDevicePackageModel._();

  /// Asynchronously retrieves detailed information about the current device.
  ///
  /// For web, it returns browser name and user agent.
  /// For mobile (Android/iOS), it returns model, OS version, and SDK/system version.
  /// For other platforms, it returns the platform name.
  Future<String> get deviceInfo async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (kIsWeb) {
      final webDeviceInfo = await deviceInfoPlugin.webBrowserInfo;
      return "w-${webDeviceInfo.browserName}-ua-${webDeviceInfo.userAgent}";
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        {
          final androidDeviceInfo = await deviceInfoPlugin.androidInfo;
          return "a-${androidDeviceInfo.model}-"
              "sdk-${androidDeviceInfo.version.sdkInt}-"
              "${androidDeviceInfo.version.release}";
        }
      case TargetPlatform.iOS:
        {
          final iosDeviceInfo = await deviceInfoPlugin.iosInfo;
          return "i-${iosDeviceInfo.model}-"
              "sysver-${iosDeviceInfo.systemVersion}";
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
    return "${packageInfoPlatform.version}+${packageInfoPlatform.buildNumber}";
  }

  /// Gets a user identifier string.
  ///
  /// It returns the first 5 characters of the authenticated user's UID if available,
  /// otherwise defaults to "guest".
  String get identifierInfo =>
      (Auth.instance().uid?.substring(0, 5)) ?? "guest";
}
