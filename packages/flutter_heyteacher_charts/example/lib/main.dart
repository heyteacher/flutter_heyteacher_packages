import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_charts_example/src/bar_chart_example_card.dart';
import 'package:flutter_heyteacher_charts_example/src/candlestick_chart_example_card.dart';
import 'package:flutter_heyteacher_charts_example/src/line_chart_example_card.dart';
import 'package:flutter_heyteacher_charts_example/src/scatter_chart_example_card.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show
        AdaptiveScaffold,
        AdaptiveWrap,
        ScreenSize,
        ThemeModeButton,
        ThemeViewModel;
import 'package:flutter_localizations/flutter_localizations.dart';

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
    builder: (context, asyncSnapshot) => MaterialApp(
      theme: asyncSnapshot.data?.themeData,
      darkTheme: ThemeViewModel.instance.darkTheme,
      themeMode: asyncSnapshot.data?.themeMode,
      home: const _MyHomePage(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
    ),
  );
}

class _MyHomePage extends StatefulWidget {
  const _MyHomePage();

  @override
  State<_MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  @override
  Widget build(BuildContext context) => AdaptiveScaffold(
    appBar: AppBar(
      title: const Text('Flutter Heyteacher Charts'),
      actions: const [ThemeModeButton()],
    ),
    bodyForLargeBuilder: _buildBody,
    bodyForSmallBuilder: _buildBody,
  );

  Widget _buildBody({
    required int crossAxisCount,
    required ScreenSize screenSize,
  }) => SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: AdaptiveWrap(
        crossAxisCount: crossAxisCount,
        children: const [
          Column(
            children: [ExampleLineChart(), Divider()],
          ),
          Column(
            children: [ExampleBarChart(), Divider()],
          ),
          Column(
            children: [ExampleScatterChart(), Divider()],
          ),
          Column(
            children: [ExampleCandlestickChart(), Divider()],
          ),
        ],
      ),
    ),
  );
}
