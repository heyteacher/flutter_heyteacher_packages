import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_auth/auth.dart'
    show
        AccountCard,
        AuthViewModel,
        FlutterHeyteacherAuthLocalizations,
        GoAuthRoute;
import 'package:flutter_heyteacher_logger/logger.dart' show LoggerViewModel;
import 'package:flutter_heyteacher_views/views.dart'
    show ThemeViewModel, showSnackBar;
import 'package:go_router/go_router.dart' show GoRoute, GoRouter;
import 'package:url_launcher/url_launcher.dart' show launchUrl;

Future<void> main() async {
  // ensureInitialized
  WidgetsFlutterBinding.ensureInitialized();
  // Logging
  await LoggerViewModel.instance.initialize();
  runApp(const MyApp());
}

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  /// Creates the [MyApp].
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Flutter Heyteacher Auth',
    theme: ThemeViewModel.instance.lightTheme,
    darkTheme: ThemeViewModel.instance.darkTheme,
    themeMode: ThemeMode.dark,
    localizationsDelegates: const [
      FlutterHeyteacherAuthLocalizations.delegate,
    ],
    routerConfig: GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const _MyHomePage(
            title: 'Flutter Heyteacher Auth',
          ),
          routes: [
            GoAuthRoute.builder(
              landingRoutePath: '/',
              fakeSignIn: _fakeSignIn,
            ),
          ],
        ),
      ],
    ),
  );

  /// fake sign in for testing purposes
  Future<void> _fakeSignIn() async {
    if (AuthViewModel.instance.notAutenticated) {
      await AuthViewModel.instance.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password',
      );
    }
  }
}

class _MyHomePage extends StatefulWidget {
  const _MyHomePage({required this.title});

  final String title;

  @override
  State<_MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
    ),
    body: Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        spacing: 8,
        children: [
          AccountCard(
            deleteAccountConfirmMessage:
                'Are you sure to delete your user data?',
            deleteAccountCallback: () async {
              // insert here your logic to delete user data
              showSnackBar(
                context: context,
                message: 'User data deleted successfully',
                duration: 5,
              );
            },
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
                    const TextSpan(text: 'This example uses\n\n'),
                    WidgetSpan(
                      child: InkWell(
                        onTap: () => launchUrl(
                          Uri.https(
                            'pub.dev',
                            '/packages/firebase_auth_mocks',
                          ),
                        ),
                        child: Text(
                          'MockFirebaseAuth',
                          style: Theme.of(context).textTheme.headlineMedium!
                              .copyWith(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                    const TextSpan(
                      text:
                          '\n\nto simulate firebase authentication with only '
                          'one user registered:\n\n',
                    ),
                    const TextSpan(
                      text: 'user name: ',
                    ),
                    const TextSpan(
                      text: 'Test User\n',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const TextSpan(
                      text: 'email: ',
                    ),
                    const TextSpan(
                      text: 'test@example.com\n',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const TextSpan(
                      text: 'password: ',
                    ),
                    const TextSpan(
                      text: 'password',
                      style: TextStyle(fontStyle: FontStyle.italic),
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
