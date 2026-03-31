import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart'
    show FakeFirebaseFirestore;
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_auth/flutter_heyteacher_auth.dart'
    show AuthViewModel;
import 'package:flutter_heyteacher_e2ee/flutter_heyteacher_e2ee.dart'
    show E2EEViewModel;
import 'package:flutter_heyteacher_store_example/src/data/track_data.dart'
    show TrackData;
import 'package:flutter_heyteacher_store_example/src/store/track_store.dart'
    show TrackStore;
import 'package:flutter_heyteacher_store_example/src/views/details_screen.dart';
import 'package:flutter_heyteacher_store_example/src/views/list_screen.dart'
    show ListScreen;
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeViewModel;
import 'package:go_router/go_router.dart' show GoRoute, GoRouter;

Future<void> main() async {
  // ensureInitialized
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

  // mock sign-in
  unawaited(
    AuthViewModel.instance.signInWithEmailAndPassword(
      email: 'test@example.com',
      password: 'test@example.com',
    ),
  );
  // initialize E2EE passfrase (aka AAD)
  unawaited(E2EEViewModel.instance(AuthViewModel.instance.uid).setAAD());

  // mock firestore with mock authentication
  final firestore = FakeFirebaseFirestore(
    authObject: AuthViewModel.instance.authForFakeFirestore,
  );
  TrackStore.instance = TrackStore(firebaseFirestore: firestore);

  await TrackStore.instance.set(
    TrackData(
      startTime: DateTime.parse('2024-02-27 13:27:56'),
      stopTime: DateTime.parse('2024-02-27 14:26:24'),
      avgRpm: 130,
      distanceInMeters: 10000,
      avgBpm: await E2EEViewModel.instance(
        AuthViewModel.instance.uid,
      ).encrypt('150'),
    ),
  );
  await TrackStore.instance.set(
    TrackData(
      startTime: DateTime.parse('2024-04-27 13:27:56'),
      stopTime: DateTime.parse('2024-04-27 14:00:56'),
      distanceInMeters: 20000,
      avgRpm: 140,
      avgBpm: await E2EEViewModel.instance(
        AuthViewModel.instance.uid,
      ).encrypt('170'),
    ),
  );
  await TrackStore.instance.set(
    TrackData(
      startTime: DateTime.parse('2023-07-12 17:15:22'),
      stopTime: DateTime.parse('2023-07-12 21:14:45'),
      distanceInMeters: 30000,
      avgRpm: 140,
      avgBpm: await E2EEViewModel.instance(
        AuthViewModel.instance.uid,
      ).encrypt('100'),
    ),
  );
  await TrackStore.instance.set(
    TrackData(
      startTime: DateTime.parse('2023-09-12 17:15:22'),
      stopTime: DateTime.parse('2023-09-12 20:00:00'),
      distanceInMeters: 30000,
      avgRpm: 160,
      avgBpm: await E2EEViewModel.instance(
        AuthViewModel.instance.uid,
      ).encrypt('140'),
    ),
  );
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
    debugShowCheckedModeBanner: false,
    routerConfig: GoRouter(
      routes: [
        GoRoute(
          path: '/',
          name: 'list',
          builder: (context, state) => const ListScreen(),
          routes: [
            GoRoute(
              path: '/details/:id',
              name: 'details',
              builder: (context, state) => DetailsScreen(
                id: state.pathParameters['id'] ?? '',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
