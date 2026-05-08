import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeViewModel;
import 'package:flutter_localizations/flutter_localizations.dart'
    show
        GlobalCupertinoLocalizations,
        GlobalMaterialLocalizations,
        GlobalWidgetsLocalizations;

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
  // initialise TTS
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
    builder: (context, localeAsyncSnapshot) => MaterialApp(
      theme: ThemeViewModel.instance.lightTheme,
      darkTheme: ThemeViewModel.instance.darkTheme,
      themeMode: ThemeMode.dark,
      home: const _MyHomePage(),
      localizationsDelegates: const [
        FlutterHeyteacherLocaleLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleViewModel.instance.supportedLocales,
      locale: localeAsyncSnapshot.data,
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
      title: const Text('Flutter Heyteacher Locale'),
    ),
    body: Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      child: Column(
        children: [
          const LocaleListTile(),
          const Divider(height: 1, color: Colors.white24),
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
                      text: FlutterHeyteacherLocaleLocalizations.of(
                        context,
                      )!.nHours(2),
                    ),
                    const TextSpan(text: '\n'),
                    TextSpan(
                      text: FlutterHeyteacherLocaleLocalizations.of(
                        context,
                      )!.nMinutes(3),
                    ),
                    const TextSpan(text: '\n'),
                    TextSpan(
                      text: FlutterHeyteacherLocaleLocalizations.of(
                        context,
                      )!.nSeconds(4),
                    ),
                    const TextSpan(text: '\n'),
                    TextSpan(
                      text: FlutterHeyteacherLocaleLocalizations.of(
                        context,
                      )!.defaultValue(123456789),
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
