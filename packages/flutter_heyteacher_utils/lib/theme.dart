import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_heyteacher_utils/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/user_store.dart';

class ThemeHepler {
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
  ThemeData get theme =>
      _themeMode == ThemeMode.light || _brightness == Brightness.light
          ? lightTheme
          : darkTheme;

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode newThemeMode) async {
    _themeMode = newThemeMode;
    _themeStreamController.sink.add(null);
    if (Auth.instance().autenticated) {
      UserStore.instance().update(UserData.fromThemeMode(themeMode: themeMode),
          fields: ["themeMode"]);
    }
  }

  Color get blueTextColor => _themeMode == ThemeMode.light || _brightness == Brightness.light
      ? Colors.blue.shade700
      : Colors.blue.shade300;
  Color get orangeTextColor => _themeMode == ThemeMode.light || _brightness == Brightness.light
      ? Colors.orange.shade700
      : Colors.orange.shade300;
  Color get greenTextColor => _themeMode == ThemeMode.light || _brightness == Brightness.light
      ? Colors.green.shade700
      : Colors.green.shade300;

  static ThemeHepler? _instance;
  static ThemeHepler instance(
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
      _instance ??= ThemeHepler._(
          initialDarkColorScheme: initialDarkColorScheme!,
          initialLightColorScheme: initialLightColorScheme!);
  ThemeHepler._(
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
    // load from store user the theme mode
    Auth.instance().autenticated
        ? UserStore.instance()
            .getOrNull(Auth.instance().uid!)
            .then((user) => _themeMode = switch (user?.themeMode) {
                  "dark" => ThemeMode.dark,
                  "light" => ThemeMode.light,
                  _ => ThemeMode.system,
                })
        : _themeMode = ThemeMode.system;
    // if store user theme mode isn't the default, notify to UI the changee
    if (_themeMode != ThemeMode.system) _themeStreamController.sink.add(null);
    // initializa dark and light theme
    darkTheme = _themeData(
        themeMode: ThemeMode.dark, colorScheme: _initialDarkColorScheme);
    lightTheme = _themeData(
        themeMode: ThemeMode.dark, colorScheme: _initialLightColorScheme);
  }

  final StreamController<dynamic> _themeStreamController =
      StreamController<dynamic>.broadcast();
  Stream<dynamic> get themeStream => _themeStreamController.stream;

  void setDefault() {
    darkTheme = _themeData(
        themeMode: ThemeMode.dark, colorScheme: _initialDarkColorScheme);
    lightTheme = _themeData(
        themeMode: ThemeMode.light, colorScheme: _initialLightColorScheme);
    _themeStreamController.sink.add(null);
  }

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
        cardTheme: CardTheme(
            elevation: 50, color: surfaceContainer.withValues(alpha: 0.8)),
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
