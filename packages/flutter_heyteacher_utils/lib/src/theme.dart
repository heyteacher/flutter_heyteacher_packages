/// Manages application-wide theming, including theme selection UI,
/// theme persistence, and dynamic theme updates.
///
/// This library provides:
/// - [ThemeCard]: A widget for users to select between light, dark, or system default themes.
/// - [ThemeModel]: A singleton class responsible for holding the current theme state,
///   persisting user preferences, providing theme data, and broadcasting theme changes.
///
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A [ListTile] widget that allows users to select the application's [ThemeMode].
///
/// It presents [ChoiceChip] options for system, dark, and light themes.
/// Changes are propagated through the [ThemeModel] singleton.
class ThemeCard extends StatefulWidget {
  const ThemeCard({super.key});

  @override
  State<ThemeCard> createState() => ThemeCardState<ThemeCard>();
}

class ThemeCardState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const Icon(Icons.contrast),
          title: Wrap(
            alignment: WrapAlignment.center,
            spacing: 2,
            children: [
              ChoiceChip(
                  selected: ThemeMode.system == ThemeModel.instance().themeMode,
                  label: Text(ThemeMode.system.name),
                  avatar: const Icon(Icons.smartphone),
                  showCheckmark: false,
                  onSelected: (bool selected) =>
                      onSelected(selected ? ThemeMode.system : null)),
              ChoiceChip(
                  selected: ThemeMode.dark == ThemeModel.instance().themeMode,
                  label: Text(ThemeMode.dark.name),
                  avatar: const Icon(Icons.dark_mode),
                  showCheckmark: false,
                  onSelected: (bool selected) =>
                      onSelected(selected ? ThemeMode.dark : null)),
              ChoiceChip(
                  selected: ThemeMode.light == ThemeModel.instance().themeMode,
                  label: Text(ThemeMode.light.name),
                  avatar: const Icon(Icons.light_mode),
                  showCheckmark: false,
                  onSelected: (bool selected) =>
                      onSelected(selected ? ThemeMode.light : null)),
            ],
          ),
        ),
      );

  /// Called when a [ChoiceChip] is selected.
  ///
  /// Updates the [ThemeModel] with the [newSelection]. If [newSelection] is null
  /// (which can happen if a chip is deselected, though not in this specific UI setup),
  /// it defaults to [ThemeMode.system].
  @protected
  void onSelected(ThemeMode? newSelection) => setState(() {
        ThemeModel.instance().setThemeMode(newSelection ?? ThemeMode.system);
      });
}

/// Manages the application's theme, including light and dark modes,
/// custom color schemes, and persistence of the selected theme.
///
/// This class follows a singleton pattern, accessible via `ThemeModel.instance()`.
///
/// Key functionalities:
/// - Persists the selected [ThemeMode] using [SharedPreferences] (via a hypothetical `SharedPreferencesAsync`).
/// - Provides [ThemeData] for both light and dark modes, customizable at initialization and runtime.
/// - Exposes a [themeStream] to notify listeners of theme changes.
/// - Offers convenient getters for theme-dependent colors (e.g., `redColor`, `greenColor`).
/// - Allows dynamic updates to the theme's color scheme.
///
/// The theme mode is stored under the key `_sharedPreferencesThemeModeKey` in shared preferences.
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

  /// The [ThemeData] for the dark theme.
  ThemeData darkTheme = ThemeData.dark(), lightTheme = ThemeData.light();

  /// Gets the current [ThemeData] based on the selected [themeMode] and system brightness.
  ///
  /// If [themeMode] is [ThemeMode.system], it considers the platform's brightness.
  /// Otherwise, it uses the explicitly set light or dark theme.
  ThemeData get theme =>
      _themeMode == ThemeMode.light || _brightness == Brightness.light
          ? lightTheme
          : darkTheme;

  /// The key used to store the selected theme mode in [SharedPreferences].
  static const _sharedPreferencesThemeModeKey = 'fhuThemeMode';

  ThemeMode _themeMode;

  /// Gets the current selected [ThemeMode].
  ///
  /// Defaults to [ThemeMode.system] if no theme has been explicitly set or loaded.
  ThemeMode get themeMode => _themeMode;

  /// A stream controller to broadcast theme changes.
  final StreamController<ThemeMode> _themeStreamController =
      StreamController<ThemeMode>.broadcast();

  /// A stream that emits an event whenever the theme changes.
  ///
  /// Widgets can listen to this stream to rebuild when the theme is updated.
  /// The emitted value is typically `null` and serves as a notification.
  Stream<ThemeMode> get themeStream => _themeStreamController.stream.distinct();

  /// Gets a red color that adapts to the current theme (light/dark).
  Color get redColor =>
      _themeMode == ThemeMode.light || _brightness == Brightness.light
          ? Colors.red.shade800
          : Colors.red.shade200;

  /// Gets a blue color that adapts to the current theme (light/dark).
  Color get blueColor =>
      _themeMode == ThemeMode.light || _brightness == Brightness.light
          ? Colors.blue.shade800
          : Colors.blue.shade200;

  /// Gets a yellow color that adapts to the current theme (light/dark).
  Color get yellowColor =>
      _themeMode == ThemeMode.light || _brightness == Brightness.light
          ? Colors.yellow.shade800
          : Colors.yellow.shade200;

  /// Gets a green color that adapts to the current theme (light/dark).
  Color get greenColor =>
      _themeMode == ThemeMode.light || _brightness == Brightness.light
          ? Colors.green.shade800
          : Colors.green.shade200;

  /// Gets an orange color that adapts to the current theme (light/dark).
  Color get orangeColor =>
      _themeMode == ThemeMode.light || _brightness == Brightness.light
          ? Colors.orange.shade800
          : Colors.orange.shade200;

  /// get the purple color based on the current theme mode
  Color get purpleColor =>
      _themeMode == ThemeMode.light || _brightness == Brightness.light
          ? Colors.purple.shade800
          : Colors.purple.shade200;

  static ThemeModel? _instance;

  /// Provides the singleton instance of [ThemeModel].
  ///
  /// On first call, it initializes the [ThemeModel] with optional
  /// [initialDarkColorScheme] and [initialLightColorScheme]. If these are not
  /// provided, default color schemes are used.
  ///
  /// Subsequent calls return the existing instance.
  /// This method also triggers the loading of the persisted theme mode.
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
                onError: Colors.red,
                surface: Colors.white70,
                onSurface: Colors.grey.shade900,
                surfaceContainer: Colors.white.withValues(alpha: 0.6),
                onSurfaceVariant: Colors.black
              ));

  /// Private constructor for the [ThemeModel] singleton.
  ///
  /// Initializes [_initialLightColorScheme] and [_initialDarkColorScheme],
  /// sets the default [_themeMode] to [ThemeMode.system],
  /// creates the initial [darkTheme] and [lightTheme] based on the provided schemes,
  /// and attempts to load the persisted theme mode from [SharedPreferencesAsync].
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
      _themeStreamController.sink.add(_themeMode);
    });
  }

  /// Sets the application's [ThemeMode] to the provided [themeMode].
  ///
  /// This new [themeMode] is persisted to [SharedPreferences] (via `SharedPreferencesAsync`)
  /// and an event is emitted on the [themeStream] to notify listeners.
  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    await SharedPreferencesAsync()
        .setString(_sharedPreferencesThemeModeKey, themeMode.name);
    _themeStreamController.sink.add(_themeMode);
  }

  /// Resets the light and dark themes to their initial default color schemes.
  ///
  /// This uses the `_initialDarkColorScheme` and `_initialLightColorScheme`
  /// that were provided at initialization or the default ones if none were given.
  /// An event is emitted on the [themeStream].
  void setDefault() {
    darkTheme = _themeData(
        themeMode: ThemeMode.dark, colorScheme: _initialDarkColorScheme);
    lightTheme = _themeData(
        themeMode: ThemeMode.light, colorScheme: _initialLightColorScheme);
    _themeStreamController.sink.add(_themeMode);
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
    _themeStreamController.sink.add(_themeMode);
  }

  /// Calculates a suitable foreground color based on a given [color] and [themeMode].
  ///
  /// It interpolates the [color] towards black for light themes and towards white
  /// for dark themes to ensure readability.
  /// If [themeMode] is not provided, the current [_themeMode] is used.
  Color? themeForegroundColor(Color? color, {ThemeMode? themeMode}) =>
      (themeMode ?? _themeMode) == ThemeMode.light
          ? Color.lerp(color, Colors.black, 0.7)
          : Color.lerp(color, Colors.white, 0.7);

  /// Calculates a suitable background color based on a given [color] and [themeMode].
  ///
  /// It interpolates the [color] towards white for light themes and towards black
  /// for dark themes.
  /// If [themeMode] is not provided, the current [_themeMode] is used.
  Color? themeBackgroundColor(Color? color, {ThemeMode? themeMode}) =>
      (themeMode ?? _themeMode) == ThemeMode.light
          ? Color.lerp(color, Colors.white, 0.5)
          : Color.lerp(color, Colors.black, 0.5);

  /// Generates a pair of light and dark background colors based on a given [color].
  ///
  /// Uses [themeBackgroundColor] internally for both [ThemeMode.light] and [ThemeMode.dark].
  ({Color light, Color dark}) backgroundColor(Color color) => (
        light: themeBackgroundColor(color, themeMode: ThemeMode.light)!,
        dark: themeBackgroundColor(color, themeMode: ThemeMode.dark)!
      );

  /// Constructs a [ThemeData] object for a specific [themeMode] (light or dark)
  /// using a provided [colorScheme].
  ///
  /// If parts of the [colorScheme] are not provided (i.e., are null),
  /// it falls back to the corresponding colors from the `_initialLightColorScheme`
  /// or `_initialDarkColorScheme` based on the [themeMode].
  /// It also sets various theme properties like [AppBarTheme], [BottomNavigationBarThemeData], etc.
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
        appBarTheme: const AppBarTheme(iconTheme: IconThemeData(size: 40)),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          elevation: 0,
          selectedItemColor: onSurfaceVariant,
          unselectedItemColor: disabled,
          backgroundColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(elevation: 50, color: surfaceContainer),
        textTheme: const TextTheme(
            displayLarge: TextStyle(
          fontSize: 120,
        )),
        snackBarTheme: const SnackBarThemeData(
          //contentTextStyle: TextStyle(color: surface),
          insetPadding: EdgeInsets.all(20.0),
          elevation: 20,
          //backgroundColor: surface
        ),
        bottomSheetTheme:
            const BottomSheetThemeData(backgroundColor: Colors.transparent)
        /* dark theme settings */
        );
  }

  /// Gets the current platform brightness (light or dark) from the [SchedulerBinding].
  ///
  /// This is used when [themeMode] is set to [ThemeMode.system] to determine which theme to apply.
  Brightness get _brightness =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness;
}
