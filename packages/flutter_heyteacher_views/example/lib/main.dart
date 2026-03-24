import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/views.dart' show ThemeViewModel;
import 'package:flutter_heyteacher_views_example/src/app_router.dart' show AppRouter;

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
  Widget build(BuildContext context) => StreamBuilder(
    stream: ThemeViewModel.instance.themeStream,
    builder: (_, _) => MaterialApp.router(
      theme: ThemeViewModel.instance.lightTheme,
      darkTheme: ThemeViewModel.instance.darkTheme,
      themeMode: ThemeViewModel.instance.themeMode,
      title: 'Flutter Demo',
      localizationsDelegates: const [],
      routerConfig: AppRouter.instance.router,
    ),
  );
}
