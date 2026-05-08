import 'dart:async';

// import 'package:firebase_auth_mocks/firebase_auth_mocks.dart'
//     show MockFirebaseAuth, MockUser;
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart'
    show FlutterHeyteacherLocaleLocalizations;
//import 'package:flutter_heyteacher_auth/auth.dart' show AuthViewModel;
import 'package:flutter_heyteacher_logger/flutter_heyteacher_logger.dart'
    show
        EnableLogsStorageChoiceListTile,
        FlutterHeyteacherLoggerLocalizations,
        LoggerListTile,
        LoggerViewModel,
        LoggingLevelDropDownMenuListTile,
        LoggingRouter;
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeViewModel;
import 'package:go_router/go_router.dart' show GoRoute, GoRouter;
import 'package:logging/logging.dart' show Level, Logger;

Future<void> main() async {
  // ensureInitialized
  WidgetsFlutterBinding.ensureInitialized();

  // Logging
  await LoggerViewModel.instance.initialize(defaultLevel: Level.FINEST);
  final logger = Logger('main')
    ..finest('(main): this is an finest message')
    ..finer('(main): this is an finer message')
    ..fine('(main): this is an fine message')
    ..info('(main): this is an info message')
    ..config('(main): this is an config message')
    ..warning('(main): this is an warning essage');
  try {
    throw Exception('this is an exception');
    //
    // ignore: avoid_catches_without_on_clauses
  } catch (e, s) {
    logger.severe('(main): this is an severe message', e, s);
  }
  logger.shout('(main): this is an shout message');
  //initialize Auth with MockFirebaseAuth
  // Run App
  runApp(const MyApp());
}

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  /// Creates the [MyApp].
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    theme: ThemeViewModel.instance.lightTheme,
    darkTheme: ThemeViewModel.instance.darkTheme,
    themeMode: ThemeMode.dark,
    localizationsDelegates: const [
      FlutterHeyteacherLoggerLocalizations.delegate,
      FlutterHeyteacherLocaleLocalizations.delegate,
    ],
    routerConfig: GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const _MyHomePage(),
          routes: [
            LoggingRouter.builder(),
          ],
        ),
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
  static final _logger = Logger('_MyHomePage');

  @override
  void initState() {
    super.initState();
    _logger.info('<initState>');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Flutter Heyteacher Logger'),
    ),
    body: Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      child: Column(
        children: [
          const LoggerListTile('', visible: true),
          const Divider(height: 1, color: Colors.white24),
          const EnableLogsStorageChoiceListTile(),
          const Divider(height: 1, color: Colors.white24),
          LoggingLevelDropDownMenuListTile(onChanged: () {}),
          const Divider(height: 1, color: Colors.white24),
        ],
      ),
    ),
  );
}
