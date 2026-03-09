import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_connectivity/connectivity.dart';
import 'package:flutter_heyteacher_views/views.dart'
    show FutureStreamBuilder, ThemeViewModel;

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
    title: 'Flutter Heyteacher Connectivity',
    theme: ThemeViewModel.instance.lightTheme,
    darkTheme: ThemeViewModel.instance.darkTheme,
    themeMode: ThemeMode.dark,
    home: const _MyHomePage(title: 'Flutter Heyteacher Connectivity'),
  );
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
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.wifi,
              ),
              title: const Text('App Connectivity Status'),
              trailing: FutureStreamBuilder(
                future: ConnectivityViewModel.instance.connected,
                stream: ConnectivityViewModel.instance.stream,
                builder: (context, snapshot) => switch (snapshot.data) {
                  true => Badge(
                    label: Text(
                      'ON',

                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(color: Colors.white),
                    ),
                    backgroundColor: ThemeViewModel.instance.greenColor,
                  ),
                  false => Badge(
                    label: Text(
                      'OFF',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(color: Colors.white),
                    ),
                    backgroundColor: ThemeViewModel.instance.redColor,
                  ),
                  null => const CircularProgressIndicator(),
                },
              ),
            ),
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
