import 'dart:async';
import 'package:flutter/material.dart';

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

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    _themeStreamController.sink.add(null);
  }

  Color get blueTextColor => _themeMode == ThemeMode.light? Colors.blue: Colors.blue.shade300;
  Color get orangeTextColor => _themeMode ==ThemeMode.light? Colors.orange:Colors.orange.shade300;
  Color get greenTextColor => _themeMode ==ThemeMode.light? Colors.green:Colors.green.shade300;

  static ThemeHepler? _instance;
  static ThemeHepler instance(
          {bool initialize = false,
          ThemeMode? themeMode,
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
      initialize
          ? _instance = ThemeHepler._(
              themeMode: themeMode!,
              initialDarkColorScheme: initialDarkColorScheme!,
              initialLightColorScheme: initialLightColorScheme!)
          : _instance!;
  ThemeHepler._(
      {required ThemeMode themeMode,
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
        _themeMode = themeMode {
    darkTheme = _themeData(
        themeMode: ThemeMode.dark, colorScheme: _initialDarkColorScheme);
    lightTheme = _themeData(
        themeMode: ThemeMode.dark, colorScheme: _initialLightColorScheme);
  }

  final StreamController<dynamic> _themeStreamController =
      StreamController<dynamic>.broadcast();
  Stream<dynamic> get themeStream => _themeStreamController.stream;

  setDefault() {
    darkTheme = _themeData(
        themeMode: ThemeMode.dark, colorScheme: _initialDarkColorScheme);
    lightTheme = _themeData(
        themeMode: ThemeMode.light, colorScheme: _initialLightColorScheme);
    _themeStreamController.sink.add(null);
  }

  updateColorScheme(
      {Color? primary,
      Color? disabled,
      Color? onPrimary,
      Color? secondary,
      Color? onSecondary,
      Color? onError,
      Color? error,
      Color? onSurface,
      Color? surface,
      Color? onSurfaceVariant,
      Color? surfaceContainer}) {
    var colorScheme = (
      primary: primary,
      disabled: disabled,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      onError: onError,
      error: error,
      surface: surface,
      onSurface: onSurface,
      surfaceContainer: surfaceContainer,
      onSurfaceVariant: onSurfaceVariant,
    );
    switch (_themeMode) {
      case ThemeMode.light:
        lightTheme =
            _themeData(themeMode: ThemeMode.light, colorScheme: colorScheme);
      default:
        darkTheme =
            _themeData(themeMode: ThemeMode.dark, colorScheme: colorScheme);
    }
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
            themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light,
        disabledColor: disabled,
        colorScheme: ColorScheme(
          brightness:
              themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light,
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
}
