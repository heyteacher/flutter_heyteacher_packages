import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_site/flutter_heyteacher_site.dart'
    show
        FlutterHeyteacherSiteLocalizations;
import 'package:flutter_heyteacher_site_example/src/carousel_screen.dart';
import 'package:flutter_heyteacher_site_example/src/home_screen.dart';
import 'package:flutter_heyteacher_site_example/src/markdown_screen.dart';
import 'package:flutter_heyteacher_site_example/src/slides_screen.dart';
import 'package:flutter_heyteacher_site_example/src/videos_screen.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeViewModel;
import 'package:go_router/go_router.dart' show GoRoute, GoRouter;

Future<void> main() async {
  // ensureInitialized
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// This Widget is the main application widget.
class MyApp extends StatefulWidget {
  /// Creates the [MyApp].
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<({ThemeData themeData, ThemeMode themeMode})>?
  _themeStreamSubscription;
  
  ThemeMode? _themeMode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_init);
  }

  Future<void> _init(_) async {
    unawaited(_themeStreamSubscription?.cancel());
    _themeStreamSubscription = ThemeViewModel.instance.themeStream.listen(
      (event) => setState(() => _themeMode = event.themeMode),
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    theme: ThemeViewModel.instance.lightTheme,
    darkTheme: ThemeViewModel.instance.darkTheme,
    themeMode: _themeMode,
    localizationsDelegates: const [
      FlutterHeyteacherSiteLocalizations.delegate,
    ],
    debugShowCheckedModeBanner: false,
    routerConfig: GoRouter(
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: '/markdown',
              name: 'markdown',
              builder: (context, state) => const MarkdownScreen(),
            ),
            GoRoute(
              path: '/videos',
              name: 'videos',
              builder: (context, state) => const VideosScreen(),
            ),
            GoRoute(
              path: '/slides',
              name: 'slides',
              builder: (context, state) => const SlidesScreen(),
            ),
            GoRoute(
              path: '/carousel',
              name: 'carousel',
              builder: (context, state) => const CarouselScreen(),
            ),
          ],
        ),
      ],
    ),
  );
}
