import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_auth/flutter_heyteacher_auth.dart'
    show AuthViewModel, FlutterHeyteacherAuthLocalizations;
import 'package:flutter_heyteacher_e2ee/flutter_heyteacher_e2ee.dart'
    show
        E2EESecretKeyListTile,
        E2EEValue,
        E2EEViewModel,
        FlutterHeyteacherE2EELocalizations;
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeViewModel, showSnackBar;

Future<void> main() async {
  // ensureInitialized
  WidgetsFlutterBinding.ensureInitialized();

  // local sign in
  await AuthViewModel.instance.localInitialize();
  unawaited(
    E2EEViewModel.instance(AuthViewModel.instance.uid).setAAD('debugPassword'),
  );

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
    localizationsDelegates: const [
      FlutterHeyteacherAuthLocalizations.delegate,
      FlutterHeyteacherE2EELocalizations.delegate,
    ],
    home: const _MyHomePage(),
  );
}

class _MyHomePage extends StatefulWidget {
  const _MyHomePage();

  @override
  State<_MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  final TextEditingController _secretKeyTextEditingController =
      TextEditingController();

  String? _plainText =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
      'Quisque gravida condimentum dui, non vestibulum ipsum gravida ac. '
      'Donec ultrices risus ac libero tincidunt, nec interdum libero '
      'condimentum';

  E2EEValue? _e2eeValue;

  @override
  void initState() {
    super.initState();
    _secretKeyTextEditingController.text = _plainText!;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Flutter Heyteacher E2EE')),
    body: Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      child: ListView(
        children: [
          const Divider(height: 1, color: Colors.white24),
          const E2EESecretKeyListTile(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Colors.white24),
          ),
          TextFormField(
            controller: _secretKeyTextEditingController,
            minLines: 20,
            maxLines: null,
            keyboardType: TextInputType.text,
            onChanged: (value) => _plainText = value,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: ThemeViewModel.instance.colorScheme.onSurface,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _plainText == null ? null : _encryptText,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('ENCRYPT'),
                ),
              ),
              OutlinedButton(
                onPressed: _e2eeValue == null ? null : _decryptText,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('DECRYPT'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Future<void> _decryptText() async {
    try {
      _plainText = await E2EEViewModel.instance(
        AuthViewModel.instance.uid,
      ).decrypt(_e2eeValue!);
      _secretKeyTextEditingController.text = _plainText!;
      _e2eeValue = null;
      setState(() {});
    } on Exception catch (e) {
      if (mounted) {
        showSnackBar(
          context: context,
          message: e.toString(),
          duration: 5,
          error: true,
        );
      }
    }
  }

  Future<void> _encryptText() async {
    try {
      _e2eeValue = await E2EEViewModel.instance(
        AuthViewModel.instance.uid,
      ).encrypt(_plainText!);
      _secretKeyTextEditingController.text = jsonEncode(
        _e2eeValue!.toJson(),
      );
      _plainText = null;
      setState(() {});
    } on Exception catch (e) {
      if (mounted) {
        showSnackBar(
          context: context,
          message: e.toString(),
          duration: 5,
          error: true,
        );
      }
    }
  }
}
