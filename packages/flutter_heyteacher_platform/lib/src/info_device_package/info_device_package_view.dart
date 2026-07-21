/// Provides utilities for retrieving device and application package
/// information and a widget to display this information along with a
/// support request option.
///
/// This library includes:
/// - [DevicePackageInfoListTile]: A [ListTile] widget that displays formatted
///   device and package version information, and a button to initiate
///   a support email.
/// - [InfoDevicePackageViewModel]: A singleton class that fetches detailed
///   device information (OS, model, browser) and package information
///   (version, build number).
library;

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_platform/flutter_heyteacher_platform.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';

/// A widget that displays device and package information in a list tile format.
///
/// It asynchronously fetches and shows the device identifier, device details
/// (model, OS version),
/// and the application's version and build number.
/// It also includes a "Support" button that opens the default email client
/// It shows the device type, version, and a button to ask for support.
class DevicePackageInfoListTile extends StatelessWidget {
  /// Creates a [DevicePackageInfoListTile].
  const DevicePackageInfoListTile({required String supportEmail, super.key})
    : _supportEmail = supportEmail;

  final String _supportEmail;

  @override
  Widget build(BuildContext context) => ListTile(
    key: const ValueKey('lt_fhu_version'),
    leading: IconButton(
      icon: const Icon(Icons.smartphone),
      onPressed: () {
        if (InfoDevicePackageViewModel.instance.tapCounterReached) {
          // tab counter already reached
          return;
        }
        InfoDevicePackageViewModel.instance.incrementTapCounter();
        if (InfoDevicePackageViewModel.instance.tapCounterReached) {
          showSnackBar(
            context: context,
            message: FlutterHeyteacherPlatformLocalizations.of(
              context,
            )!.advancedFeaturesUnlocked,
          );
        }
      },
    ),
    title: Wrap(
      children: [
        FutureBuilder<String>(
          future: InfoDevicePackageViewModel.instance.packageVersion,
          builder: (_, devicePackageSnapshot) => Text(
            devicePackageSnapshot.data ?? '',
          ),
        ),
        if (InfoDevicePackageViewModel.instance.runningWithWasm)
          const Badge(
            label: Wrap(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(Icons.rocket, size: 14),
                ),
                Text('WASM'),
              ],
            ),
            backgroundColor: Colors.red,
            textColor: Colors.white,
            //largeSize: 12,
          ),
      ],
    ),
    subtitle: FutureBuilder(
      future: InfoDevicePackageViewModel.instance.deviceInfo,
      builder: (_, deviceSnapshot) => Text(
        'id: ${deviceSnapshot.data}',
      ),
    ),
    trailing: IconButton(
      onPressed: () => InfoDevicePackageViewModel.instance.askSupport(
        context: context,
        supportEmail: _supportEmail,
      ),
      icon: const Icon(Icons.support),
      tooltip: FlutterHeyteacherPlatformLocalizations.of(context)!.askSupport,
    ),
  );
}
