import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/context_helper.dart';
import 'package:flutter_heyteacher_utils/src/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/localizations.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class DevicePackageInfoListTile extends StatelessWidget {
  const DevicePackageInfoListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey("lt_version"),
      leading: Icon(
        Icons.smartphone,
        size: Theme.of(context).textTheme.displayMedium!.fontSize,
      ),
      title: FutureBuilder(
        future: deviceInfo,
        builder: (_, deviceSnapshot) =>
            Text("${FlutterHeyteacherUtilsLocalizations.of(context)!.id}"
                "$identifierInfo-${deviceSnapshot.data}"),
      ),
      subtitle: FutureBuilder<String>(
        future: packageVersion,
        builder: (_, snapshot) => Text(snapshot.data != null
            ? "${FlutterHeyteacherUtilsLocalizations.of(context)!.version}"
                "${snapshot.data}"
            : ""),
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

Future<String> get deviceInfo  async {
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

Future<String> get packageVersion async {
  final packageInfoPlatform = await PackageInfo.fromPlatform();
  return "${packageInfoPlatform.version}+${packageInfoPlatform.buildNumber}";
}

String get identifierInfo => (Auth.instance().uid?.substring(0, 5)) ?? "guest";

void _askSupport() async {
  final packageInfoPlatform = await PackageInfo.fromPlatform();
  final version = await packageVersion;
  final device = await deviceInfo;
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
