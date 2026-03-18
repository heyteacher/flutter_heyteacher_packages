import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_connectivity/connectivity.dart';
import 'package:flutter_heyteacher_locale/locale.dart'
    show FlutterHeyteacherLocaleLocalizations, LocaleViewModel, LocaleWrap;
import 'package:flutter_heyteacher_views/views.dart' show ThemeViewModel;
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  // ensureInitialized
  WidgetsFlutterBinding.ensureInitialized();
  // initialize locale
  await LocaleViewModel.instance.initLocale(
    supportedCountries: [
      'AR',
      'BR',
      'CA',
      'DE',
      'ES',
      'FR',
      'GB',
      'IT',
      'PT',
      'US',
    ],
  );
  runApp(const MyApp());
}

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  /// Creates the [MyApp].
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: LocaleViewModel.instance.localeStream,
    builder: (context, asyncSnapshot) => MaterialApp(
      theme: ThemeViewModel.instance.lightTheme,
      darkTheme: ThemeViewModel.instance.darkTheme,
      themeMode: ThemeMode.dark,
      home: const _MyHomePage(),
      locale: asyncSnapshot.data,
      supportedLocales: LocaleViewModel.instance.supportedLocales,
      localizationsDelegates: const [
        FlutterHeyteacherConnectivityLocalizations.delegate,
        FlutterHeyteacherLocaleLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    ),
  );
}

class _MyHomePage extends StatefulWidget {
  const _MyHomePage();

  @override
  State<_MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Flutter Heyteacher Connectivity'),
    ),
    body: Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          const ConnectivityCard(),
          const Padding(
            padding: EdgeInsets.all(8),
            child: LocaleWrap(),
          ),
          Expanded(
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: ThemeViewModel.instance.colorScheme.onSurface,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Enable and Disable your device connectivity.\n\n',
                    ),
                    TextSpan(
                      text:
                          'App Connectivity Status will be automatically '
                          'updated',
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
}
