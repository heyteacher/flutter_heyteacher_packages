library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [ThemeMode] list tile widget.
///
/// This widget is used to select the theme mode.
class ThemeListTile extends StatefulWidget {
  const ThemeListTile({super.key});

  @override
  State<ThemeListTile> createState() => _ThemeListTileState();
}

class _ThemeListTileState extends State<ThemeListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.contrast),
      title: Wrap(
        alignment: WrapAlignment.center,
        spacing: 2,
        children: [
          ChoiceChip(
              selected: ThemeMode.system == ThemeModel.instance().themeMode,
              label: Text(ThemeMode.system.name),
              avatar: Icon(Icons.smartphone),
              showCheckmark: false,
              onSelected: (bool selected) =>
                  _onSelected(selected ? ThemeMode.system : null)),
          ChoiceChip(
              selected: ThemeMode.dark == ThemeModel.instance().themeMode,
              label: Text(ThemeMode.dark.name),
              avatar: Icon(Icons.dark_mode),
              showCheckmark: false,
              onSelected: (bool selected) =>
                  _onSelected(selected ? ThemeMode.dark : null)),
          ChoiceChip(
              selected: ThemeMode.light == ThemeModel.instance().themeMode,
              label: Text(ThemeMode.light.name),
              avatar: Icon(Icons.light_mode),
              showCheckmark: false,
              onSelected: (bool selected) =>
                  _onSelected(selected ? ThemeMode.light : null)),
        ],
      ),
    );
  }

  _onSelected(ThemeMode? newSelection) => setState(() {
        ThemeModel.instance().setThemeMode(newSelection ?? ThemeMode.system);
      });
}

/// The [ThemeMode] class is used to manage the app's theme.
///
/// The theme is saved in the [SharedPreferencesAsync] on key `fhuThemeMode`.
/// Theme changes are yield on [themeStream].
/// The theme is set to [ThemeMode.system] by default.
class ThemeModel {
  final ({
    Color primary,
    Color disabled,
    Color onPrimary,
    Color secondary,
    Color onSecondary,
    Color error,
    Color onError,
    Color onSurface,
    Color surface,
    Color onSurfaceVariant,
    Color surfaceContainer,
  }) _initialDarkColorScheme, _initialLightColorScheme;

  ThemeData darkTheme = ThemeData.dark(), lightTheme = ThemeData.light();

  /// get current theme
  ThemeData get theme =>
      _themeMode == ThemeMode.light || _brightness == Brightness.light
          ? lightTheme
          : darkTheme;

  static const _sharedPreferencesThemeModeKey = 'fhuThemeMode';

  ThemeMode _themeMode;

  /// get current theme mode
  /// if not set, return [ThemeMode.system]
  ThemeMode get themeMode => _themeMode;

  final StreamController<dynamic> _themeStreamController =
      StreamController<dynamic>.broadcast();
  Stream<dynamic> get themeStream => _themeStreamController.stream;

  /// get the red color based on the current theme mode
  Color get redColor =>
      _themeMode == ThemeMode.light || _brightness == Brightness.light
          ? Colors.red.shade700
          : Colors.red.shade300;

  /// get the blue color based on the current theme mode
  Color get blueColor =>
      _themeMode == ThemeMode.light || _brightness == Brightness.light
          ? Colors.blue.shade700
          : Colors.blue.shade300;

  /// get the grey color based on the current theme mode
  Color get yellowColor =>
      _themeMode == ThemeMode.light || _brightness == Brightness.light
          ? Colors.yellow.shade700
          : Colors.yellow.shade300;

  /// get the green color based on the current theme mode
  Color get greenColor =>
      _themeMode == ThemeMode.light || _brightness == Brightness.light
          ? Colors.green.shade700
          : Colors.green.shade300;

  /// get the orange color based on the current theme mode
  Color get orangeColor =>
      _themeMode == ThemeMode.light || _brightness == Brightness.light
          ? Colors.orange.shade700
          : Colors.orange.shade300;

  /// get the purple color based on the current theme mode
  Color get purpleColor =>
      _themeMode == ThemeMode.light || _brightness == Brightness.light
          ? Colors.purple.shade700
          : Colors.purple.shade300;

  static ThemeModel? _instance;

  /// singleton instance of [ThemeModel]
  /// [initialDarkColorScheme] and [initialLightColorScheme] are used to
  /// initialize the dark and light theme
  /// if not set, default values are used.
  static ThemeModel instance(
          {({
            Color primary,
            Color disabled,
            Color onPrimary,
            Color secondary,
            Color onSecondary,
            Color error,
            Color onError,
            Color onSurface,
            Color surface,
            Color onSurfaceVariant,
            Color surfaceContainer,
          })? initialDarkColorScheme,
          ({
            Color primary,
            Color disabled,
            Color onPrimary,
            Color secondary,
            Color onSecondary,
            Color error,
            Color onError,
            Color onSurface,
            Color surface,
            Color onSurfaceVariant,
            Color surfaceContainer,
          })? initialLightColorScheme}) =>
      _instance ??= ThemeModel._(
          initialDarkColorScheme: initialDarkColorScheme ??
              (
                primary: Colors.white,
                disabled: Colors.white38,
                onPrimary: Colors.black,
                secondary: Colors.white70,
                onSecondary: Colors.grey.shade900,
                error: Colors.white,
                onError: Colors.redAccent,
                surface: Colors.grey.shade900,
                onSurface: Colors.white70,
                surfaceContainer: Colors.black.withValues(alpha: 0.8),
                onSurfaceVariant: Colors.white
              ),
          initialLightColorScheme: initialLightColorScheme ??
              (
                primary: Colors.black,
                disabled: Colors.grey.shade700,
                onPrimary: Colors.white,
                secondary: Colors.grey.shade900,
                onSecondary: Colors.white70,
                error: Colors.white,
                onError: Colors.redAccent,
                surface: Colors.white70,
                onSurface: Colors.grey.shade900,
                surfaceContainer: Colors.white.withValues(alpha: 0.6),
                onSurfaceVariant: Colors.black
              ));
  ThemeModel._(
      {required ({
        Color primary,
        Color disabled,
        Color onPrimary,
        Color secondary,
        Color onSecondary,
        Color error,
        Color onError,
        Color onSurface,
        Color surface,
        Color onSurfaceVariant,
        Color surfaceContainer,
      }) initialDarkColorScheme,
      required ({
        Color primary,
        Color disabled,
        Color onPrimary,
        Color secondary,
        Color onSecondary,
        Color error,
        Color onError,
        Color onSurface,
        Color surface,
        Color onSurfaceVariant,
        Color surfaceContainer,
      }) initialLightColorScheme})
      : _initialLightColorScheme = initialLightColorScheme,
        _initialDarkColorScheme = initialDarkColorScheme,
        _themeMode = ThemeMode.system {
    // initialize dark and light theme
    darkTheme = _themeData(
        themeMode: ThemeMode.dark, colorScheme: _initialDarkColorScheme);
    lightTheme = _themeData(
        themeMode: ThemeMode.dark, colorScheme: _initialLightColorScheme);

    SharedPreferencesAsync()
        .getString(_sharedPreferencesThemeModeKey)
        .then((themeModeName) {
      _themeMode = ThemeMode.values
              .where((element) => element.name == themeModeName)
              .firstOrNull ??
          ThemeMode.system;
      _themeStreamController.sink.add(null);
    });
  }

  /// set [themeMode] to [ThemeMode.system], [ThemeMode.light] or [ThemeMode.dark]
  /// and save it to [SharedPreferences]
  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    await SharedPreferencesAsync()
        .setString(_sharedPreferencesThemeModeKey, themeMode.name);
    _themeStreamController.sink.add(null);
  }

  /// set the theme to default values
  void setDefault() {
    darkTheme = _themeData(
        themeMode: ThemeMode.dark, colorScheme: _initialDarkColorScheme);
    lightTheme = _themeData(
        themeMode: ThemeMode.light, colorScheme: _initialLightColorScheme);
    _themeStreamController.sink.add(null);
  }

  /// update the theme with new values
  /// [primary], [disabled], [onPrimary], [secondary], [onSecondary],
  /// [error], [onError], [onSurface], [surface], [onSurfaceVariant],
  /// [surfaceContainer] are used to update the theme
  void update({
    ({Color light, Color dark})? primary,
    ({Color light, Color dark})? disabled,
    ({Color light, Color dark})? onPrimary,
    ({Color light, Color dark})? secondary,
    ({Color light, Color dark})? onSecondary,
    ({Color light, Color dark})? error,
    ({Color light, Color dark})? onError,
    ({Color light, Color dark})? onSurface,
    ({Color light, Color dark})? surface,
    ({Color light, Color dark})? onSurfaceVariant,
    ({Color light, Color dark})? surfaceContainer,
  }) {
    ({
      Color? primary,
      Color? disabled,
      Color? onPrimary,
      Color? secondary,
      Color? onSecondary,
      Color? error,
      Color? onError,
      Color? onSurface,
      Color? surface,
      Color? onSurfaceVariant,
      Color? surfaceContainer,
    }) lightColorScheme = (
          primary: primary?.light,
          disabled: disabled?.light,
          onPrimary: onPrimary?.light,
          secondary: secondary?.light,
          onSecondary: onSecondary?.light,
          onError: onError?.light,
          error: error?.light,
          surface: surface?.light,
          onSurface: onSurface?.light,
          surfaceContainer: surfaceContainer?.light,
          onSurfaceVariant: onSurfaceVariant?.light,
        ),
        darkColorScheme = (
          primary: primary?.dark,
          disabled: disabled?.dark,
          onPrimary: onPrimary?.dark,
          secondary: secondary?.dark,
          onSecondary: onSecondary?.dark,
          onError: onError?.dark,
          error: error?.dark,
          surface: surface?.dark,
          onSurface: onSurface?.dark,
          surfaceContainer: surfaceContainer?.dark,
          onSurfaceVariant: onSurfaceVariant?.dark,
        );
    lightTheme =
        _themeData(themeMode: ThemeMode.light, colorScheme: lightColorScheme);
    darkTheme =
        _themeData(themeMode: ThemeMode.dark, colorScheme: darkColorScheme);
    _themeStreamController.sink.add(null);
  }

  /// get the theme foreground color
  Color? themeForegroundColor(Color? color, {ThemeMode? themeMode}) =>
      (themeMode ?? _themeMode) == ThemeMode.light
          ? Color.lerp(color, Colors.black, 0.7)
          : Color.lerp(color, Colors.white, 0.7);

  /// get the theme background color
  Color? themeBackgroundColor(Color? color, {ThemeMode? themeMode}) =>
      (themeMode ?? _themeMode) == ThemeMode.light
          ? Color.lerp(color, Colors.white, 0.5)
          : Color.lerp(color, Colors.black, 0.5);

  /// get the theme background color
  ({Color light, Color dark}) backgroundColor(Color color) => (
        light: themeBackgroundColor(color, themeMode: ThemeMode.light)!,
        dark: themeBackgroundColor(color, themeMode: ThemeMode.dark)!
      );

  ThemeData _themeData(
      {required ThemeMode themeMode,
      required ({
        Color? primary,
        Color? disabled,
        Color? onPrimary,
        Color? secondary,
        Color? onSecondary,
        Color? error,
        Color? onError,
        Color? surface,
        Color? onSurface,
        Color? surfaceContainer,
        Color? onSurfaceVariant,
      }) colorScheme}) {
    var initialColorScheme = themeMode == ThemeMode.light
        ? _initialLightColorScheme
        : _initialDarkColorScheme;
    Color primary = colorScheme.primary ?? initialColorScheme.primary;
    Color disabled = colorScheme.disabled ?? initialColorScheme.disabled;
    Color onPrimary = colorScheme.onPrimary ?? initialColorScheme.onPrimary;
    Color secondary = colorScheme.secondary ?? initialColorScheme.secondary;
    Color onSecondary =
        colorScheme.onSecondary ?? initialColorScheme.onSecondary;
    Color error = colorScheme.error ?? initialColorScheme.error;
    Color onError = colorScheme.onError ?? initialColorScheme.onError;
    Color surface = colorScheme.surface ?? initialColorScheme.surface;
    Color onSurface = colorScheme.onSurface ?? initialColorScheme.onSurface;
    Color surfaceContainer =
        colorScheme.surfaceContainer ?? initialColorScheme.surfaceContainer;
    Color onSurfaceVariant =
        colorScheme.onSurfaceVariant ?? initialColorScheme.onSurfaceVariant;

    return ThemeData(
        brightness:
            themeMode == ThemeMode.light ? Brightness.light : Brightness.dark,
        disabledColor: disabled,
        colorScheme: ColorScheme(
          brightness:
              themeMode == ThemeMode.light ? Brightness.light : Brightness.dark,
          primary: primary,
          onPrimary: onPrimary,
          secondary: secondary,
          onSecondary: onSecondary,
          onError: onError,
          error: error,
          surface: surface,
          onSurface: onSurface,
          surfaceContainer: surfaceContainer,
          onSurfaceVariant: onSurfaceVariant,
        ),
        badgeTheme: BadgeThemeData(backgroundColor: onError, textColor: error),
        appBarTheme: AppBarTheme(iconTheme: IconThemeData(size: 40)),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          elevation: 0,
          selectedItemColor: onSurfaceVariant,
          unselectedItemColor: disabled,
          backgroundColor: Colors.transparent,
        ),
        cardTheme: CardTheme(elevation: 50, color: surfaceContainer),
        textTheme: TextTheme(
            displayLarge: TextStyle(
          fontSize: 120,
        )),
        snackBarTheme: SnackBarThemeData(
          //contentTextStyle: TextStyle(color: surface),
          insetPadding: EdgeInsets.all(20.0),
          elevation: 20,
          //backgroundColor: surface
        ),
        bottomSheetTheme:
            BottomSheetThemeData(backgroundColor: Colors.transparent)
        /* dark theme settings */
        );
  }

  Brightness get _brightness =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness;
}
