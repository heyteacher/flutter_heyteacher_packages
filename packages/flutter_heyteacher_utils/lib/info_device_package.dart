import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_heyteacher_utils/context_helper.dart';
import 'package:flutter_heyteacher_utils/src/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<String> deviceInfo() async {
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

Future<String> packageVersion() async {
  final packageInfoPlatform = await PackageInfo.fromPlatform();
  return "${packageInfoPlatform.version}+${packageInfoPlatform.buildNumber}";
}

String get identifierInfo => (Auth.instance().uid?.substring(0, 5)) ?? "guest";

void askSupport() async {
  final packageInfoPlatform = await PackageInfo.fromPlatform();
  final version = await packageVersion();
  final device = await deviceInfo();
  final subject =
      "${FlutterHeyteacherUtilsLocalizations.of(ContextHelper.context!)!.askSupportFor}"
      "${packageInfoPlatform.appName}";
  final body = "------------------------------------\n"
      "Identifier:\t$identifierInfo-$device\n"
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
