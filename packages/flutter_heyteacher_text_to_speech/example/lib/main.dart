import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart';
import 'package:flutter_heyteacher_text_to_speech/flutter_heyteacher_text_to_speech.dart'
    show
        EnableTTSChoiceCard,
        FlutterHeyteacherTextToSpeechLocalizations,
        TTSViewModel;
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ProgressIndicatorWidget, ThemeViewModel;
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
        FlutterHeyteacherTextToSpeechLocalizations.delegate,
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
  bool _loading = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Flutter Heyteacher Text to Speech'),
    ),
    body: Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        spacing: 8,
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: LocaleWrap(),
          ),
          const EnableTTSChoiceCard(),
          Expanded(
            child: Center(
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.only(left: 12, right: 16),
                      child: ProgressIndicatorWidget(
                        constraints: BoxConstraints(
                          minHeight: 128,
                          minWidth: 128,
                          maxHeight: 128,
                          maxWidth: 128,
                        ),
                      ),
                    )
                  : IconButton(
                      alignment: Alignment.topRight,
                      iconSize: 128,
                      icon: const Icon(Icons.volume_up),
                      onPressed: () async {
                        setState(() => _loading = true);
                        unawaited(
                          TTSViewModel.instance().speak(
                            FlutterHeyteacherLocaleLocalizations.of(
                              context,
                            )!.ttsTest(
                              LocaleViewModel.instance.locale.languageCode,
                              LocaleViewModel.instance.locale.countryCode ?? '',
                            ),
                            checkTTSThreshold: false,
                          ),
                        );
                        await Future<void>.delayed(const Duration(seconds: 5));
                        setState(() => _loading = false);
                      },
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}
