import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_meta/pubspec_version.dart';

void main() {
  runApp(const MyApp());
}

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  /// Creates the [MyApp].
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pubspec Version Example',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const _MyHomePage(title: 'Pubspec Version Example'),
    );
  }
}

class _MyHomePage extends StatefulWidget {
  const _MyHomePage({required this.title});

  final String title;

  @override
  State<_MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  String? _version = '1.0.0';
  String? _build = '202601010';
  final _fakePubspecVersion = _FakePubspecVersion();

  Future<void> _pubspecVersion(PubspecVersionCommand command) async {
    debugPrint('<_pubspecVersion>: command $command');
    _version = await _fakePubspecVersion.version(
      versionCommand: command,
    );
    _build = await _fakePubspecVersion.version(
      versionCommand: PubspecVersionCommand.showBuild,
    );
    debugPrint('(_pubspecVersion): version $_version build $_build');
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(_pubspecVersion(PubspecVersionCommand.show)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(widget.title),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: .center,
        spacing: 16,
        children: [
          const Text('pubspec.yaml version'),
          Text(
            '$_version',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Text('pubspec.yaml build'),
          Text(
            '$_build',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    ),
    floatingActionButton: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: [
        FloatingActionButton(
          onPressed: () => _pubspecVersion(PubspecVersionCommand.major),
          tooltip: 'Major',
          backgroundColor: Colors.greenAccent,
          child: const Text(
            '+\nMajor',
            textAlign: TextAlign.center,
          ),
        ),
        FloatingActionButton(
          onPressed: () => _pubspecVersion(PubspecVersionCommand.minor),
          tooltip: 'Minor',
          backgroundColor: Colors.yellowAccent,
          child: const Text(
            '+\nMinor',
            textAlign: TextAlign.center,
          ),
        ),
        FloatingActionButton(
          onPressed: () => _pubspecVersion(PubspecVersionCommand.patch),
          tooltip: 'Patch',
          backgroundColor: Colors.redAccent,
          child: const Text(
            '+\nPatch',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}

class _FakePubspecVersion extends PubspecVersion {
  _FakePubspecVersion() {
    tempDir = Directory.systemTemp.createTempSync();
    pubspecFile = File('${tempDir.path}/pubspec.yaml');
    pubspecFile.writeAsStringSync('name: test_pkg\nversion: 1.0.0+202601010');
  }

  late Directory tempDir;
  late File pubspecFile;

  @override
  void dispose() {
    tempDir.deleteSync(recursive: true);
  }

  @override
  File getPubspecFile() => pubspecFile;
}
