import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_auth/flutter_heyteacher_auth.dart'
    show
        AccountListTile,
        AuthViewModel,
        FlutterHeyteacherAuthLocalizations,
        GoAuthRoute;
import 'package:flutter_heyteacher_logger/flutter_heyteacher_logger.dart'
    show LoggerViewModel;
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeViewModel, showSnackBar;
import 'package:go_router/go_router.dart' show GoRoute, GoRouter;

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
          builder: (context, state) => const _MyHomePage(),
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
  const _MyHomePage();

  @override
  State<_MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Flutter Heyteacher Auth'),
    ),
    body: Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      child: Column(
        children: [
          const Divider(height: 1, color: Colors.white24),
          AccountListTile(
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
                      text: AuthViewModel.instance.autenticated
                          ? 'User Authenticated'
                          : 'User Not Authenticated',
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(
                            color: AuthViewModel.instance.autenticated
                                ? ThemeViewModel.instance.greenColor
                                : ThemeViewModel.instance.redColor,
                          ),
                    ),
                    const TextSpan(
                      text: '\nuid: ',
                    ),
                    TextSpan(
                      text: AuthViewModel.instance.user?.uid ?? 'none',
                      style: const TextStyle(fontStyle: FontStyle.italic)
                          .copyWith(
                            color: AuthViewModel.instance.autenticated
                                ? ThemeViewModel.instance.greenColor
                                : ThemeViewModel.instance.redColor,
                          ),
                    ),
                    const TextSpan(
                      text: '\nuser name: ',
                    ),
                    TextSpan(
                      text: AuthViewModel.instance.user?.displayName ?? 'none',
                      style: const TextStyle(fontStyle: FontStyle.italic)
                          .copyWith(
                            color: AuthViewModel.instance.autenticated
                                ? ThemeViewModel.instance.greenColor
                                : ThemeViewModel.instance.redColor,
                          ),
                    ),
                    const TextSpan(
                      text: '\nemail: ',
                    ),
                    TextSpan(
                      text: AuthViewModel.instance.user?.email ?? 'none',
                      style: const TextStyle(fontStyle: FontStyle.italic)
                          .copyWith(
                            color: AuthViewModel.instance.autenticated
                                ? ThemeViewModel.instance.greenColor
                                : ThemeViewModel.instance.redColor,
                          ),
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
