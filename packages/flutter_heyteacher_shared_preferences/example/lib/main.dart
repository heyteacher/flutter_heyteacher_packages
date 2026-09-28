import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart';
import 'package:flutter_heyteacher_shared_preferences/flutter_heyteacher_shared_preferences.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';

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
    title: 'Flutter Heyteacher Shared Preferences',
    localizationsDelegates: const [
      FlutterHeyteacherLocaleLocalizations.delegate,
    ],
    home: const _Home(),
    debugShowCheckedModeBanner: false,
  );
}

/// This Widget is the main application widget.
class _Home extends StatefulWidget {
  /// Creates the [_Home].
  const _Home();

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  StreamSubscription<({String key, bool? value})>? _boolStreamSubscription;

  StreamSubscription<({String key, int? value})>? _intStreamSubscription;

  StreamSubscription<({String key, String? value})>? _stringStreamSubscription;

  @override
  void initState() {
    super.initState();
    unawaited(_boolStreamSubscription?.cancel());
    _boolStreamSubscription = SharedPreferencesViewModel.instance
        .stream<bool>(key: 'boolean_key')
        .listen(_showSnackBar);
    unawaited(_intStreamSubscription?.cancel());
    _intStreamSubscription = SharedPreferencesViewModel.instance
        .stream<int>(key: 'integer_key')
        .listen(_showSnackBar);
    unawaited(_stringStreamSubscription?.cancel());
    _stringStreamSubscription = SharedPreferencesViewModel.instance
        .stream<String>(key: 'string_key')
        .listen(_showSnackBar);
  }

  void _showSnackBar(({String key, Object? value}) entry) => mounted
      ? showSnackBar(
          context: context,
          message:
              "shared preferences key '${entry.key}' "
              "changed value: '${entry.value}'",
        )
      : null;

  @override
  void dispose() {
    unawaited(_boolStreamSubscription?.cancel());
    unawaited(_intStreamSubscription?.cancel());
    unawaited(_stringStreamSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Flutter Heyteacher Shared Preferences')),
    body: ListView(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      children: const [
        SharedPreferencesListTile(
          sharedPreferencesKey: 'boolean_key',
          label: 'Boolean Key',
          icon: Icon(Icons.edit_note),
          values: [true, false],
          defaultValue: true,
        ),
        Divider(height: 1, color: Colors.white24),
        SharedPreferencesListTile(
          sharedPreferencesKey: 'integer_key',
          label: 'Integer Key',
          icon: Icon(Icons.edit_note),
          values: [1, 2, 3],
          defaultValue: 2,
          labels: ['1 second', '2 seconds', '3 seconds'],
        ),
        Divider(height: 1, color: Colors.white24),
        SharedPreferencesListTile(
          sharedPreferencesKey: 'string_key',
          label: 'String Key',
          icon: Icon(Icons.edit_note),
          values: ['one', 'two', 'three'],
          defaultValue: 'two',
        ),
        Divider(height: 1, color: Colors.white24),
      ],
    ),
  );
}
