import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_platform/flutter_heyteacher_platform.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart' show ThemeViewModel;

Future<void> main() async {
  // ensureInitialized
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  /// Creates the [MyApp].
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeViewModel.instance.lightTheme,
    darkTheme: ThemeViewModel.instance.darkTheme,
    themeMode: ThemeMode.dark,
    home: const _MyHomePage(),
    localizationsDelegates: const [
      FlutterHeyteacherPlatformLocalizations.delegate,
    ],
  );
}

class _MyHomePage extends StatelessWidget {
  const _MyHomePage();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Flutter Heyteacher Platform'),
    ),
    body: Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          const DevicePackageInfoCard(
            supportEmail: 'support@example-com',
          ),
          Expanded(
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: ThemeViewModel.instance.colorScheme.onSurface,
                  ),
                  children: [
                    TextSpan(
                      text: 'Platform isMobile: ${PlatformHelper.isMobile}\n',
                      style: _style(context, value: PlatformHelper.isMobile),
                    ),
                    TextSpan(
                      text:
                          'Platform isNotMobile: '
                          '${PlatformHelper.isNotMobile}\n',
                      style: _style(context, value: PlatformHelper.isNotMobile),
                    ),
                    TextSpan(
                      text: 'Platform isAndroid: ${PlatformHelper.isAndroid}\n',
                      style: _style(context, value: PlatformHelper.isAndroid),
                    ),
                    TextSpan(
                      text: 'Platform isIOS: ${PlatformHelper.isIOS}\n',
                      style: _style(context, value: PlatformHelper.isIOS),
                    ),
                    TextSpan(
                      text:
                          'Platform isFlutterTest: '
                          '${PlatformHelper.isFlutterTest}\n',
                      style: _style(
                        context,
                        value: PlatformHelper.isFlutterTest,
                      ),
                    ),
                    TextSpan(
                      text: 'Platform isWeb: ${PlatformHelper.isWeb}\n',
                      style: _style(context, value: PlatformHelper.isWeb),
                    ),
                    TextSpan(
                      text: 'Platform isNotWeb: ${PlatformHelper.isNotWeb}\n',
                      style: _style(context, value: PlatformHelper.isNotWeb),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  TextStyle _style(BuildContext context, {required bool value}) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      color: value
          ? ThemeViewModel.instance.greenColor
          : ThemeViewModel.instance.redColor,
    );
  }
}
