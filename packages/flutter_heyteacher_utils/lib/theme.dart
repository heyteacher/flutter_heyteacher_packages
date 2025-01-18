import 'dart:async';

import 'package:flutter/material.dart';

class ThemeHepler {
  ThemeData darkTheme = ThemeData.dark(), lightTheme = ThemeData.light();
  ThemeMode themeMode = ThemeMode.system;
  Color blueTextColor = Colors.blueAccent,
      orangeTextColor = Colors.orangeAccent ,
      greenTextColor = Colors.greenAccent;

  ThemeData get theme => switch (themeMode) {
        ThemeMode.dark => darkTheme,
        ThemeMode.light => lightTheme,
        ThemeMode.system => darkTheme
      };

  set theme(ThemeData theme) => switch (themeMode) {
        ThemeMode.dark => darkTheme = theme,
        ThemeMode.light => lightTheme = theme,
        ThemeMode.system => darkTheme = theme
      };

  static ThemeHepler? _instance;
  static ThemeHepler instance() => _instance ??= ThemeHepler._();
  ThemeHepler._();

  final StreamController<
      ({
        ThemeMode? themeMode,
        Color? onPrimary,
        Color? disabled,
        Color? primary,
        Color? onAlert,
        Color? alert,
        Color? onSurface,
        Color? surface,
        Color? onSurfaceVariant,
        Color? surfaceContainer,
      })?> _themeStreamController = StreamController<
      ({
        ThemeMode? themeMode,
        Color? onPrimary,
        Color? disabled,
        Color? primary,
        Color? onAlert,
        Color? alert,
        Color? onSurface,
        Color? surface,
        Color? onSurfaceVariant,
        Color? surfaceContainer,
      })?>.broadcast();
  Stream<
      ({
        ThemeMode? themeMode,
        Color? onPrimary,
        Color? disabled,
        Color? primary,
        Color? onAlert,
        Color? alert,
        Color? onSurface,
        Color? surface,
        Color? onSurfaceVariant,
        Color? surfaceContainer,
      })?> get themeStream => _themeStreamController.stream;

  void setDefault() {
    _themeStreamController.sink.add(null);
  }

  void updateTheme(
      {ThemeMode? themeMode,
      Color? onPrimary,
      Color? primary,
      Color? disabled,
      Color? onAlert,
      Color? alert,
      Color? onSurface,
      Color? surface,
      Color? onSurfaceVariant,
      Color? surfaceContainer}) {
    _themeStreamController.sink.add((
      themeMode: themeMode,
      onPrimary: onPrimary,
      primary: primary,
      disabled: disabled,
      onAlert: onAlert,
      alert: alert,
      onSurface: onSurface,
      surface: surface,
      onSurfaceVariant: onSurfaceVariant,
      surfaceContainer: surfaceContainer
    ));
  }
}
