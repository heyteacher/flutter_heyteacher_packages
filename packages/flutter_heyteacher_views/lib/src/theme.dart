/// Manages application-wide theming, including theme selection UI,
/// theme persistence, and dynamic theme updates.
///
/// This library provides:
/// - [ThemeCard]: A widget for users to select between light, dark, or system
///   default themes.
/// - [ThemeViewModel]: A singleton class responsible for holding the current
///   theme state, persisting user preferences, providing theme data, and
///    broadcasting theme changes.
///
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys for values stored in `SharedPreferences`.
///
/// This enum standardizes the keys used for local data persistence, preventing
/// typos and making it easier to manage stored preferences.
enum _SharedPreferencesKeys {
  /// The key for storing the user's selected theme mode (e.g., 'light',
  /// 'dark', 'system').
  fhuThemeMode,
}

/// A [ListTile] widget that allows users to select the application's
/// [ThemeMode].
///
/// It presents [ChoiceChip] options for system, dark, and light themes.
/// Changes are propagated through the [ThemeViewModel] singleton.
class ThemeCard extends StatefulWidget {
  /// Creates a [ThemeCard].
  const ThemeCard({super.key});

  @override
  State<ThemeCard> createState() => ThemeCardState<ThemeCard>();
}

/// The state for [ThemeCard], which builds the UI for theme selection.
///
/// This class is generic (`<T extends StatefulWidget>`) to allow it to be
/// extended by other state classes that may want to override its behavior,
/// such as the `onSelected` method.
class ThemeCardState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.contrast),
      title: Wrap(
        alignment: WrapAlignment.center,
        spacing: 2,
        children: [
          SegmentedButton<ThemeMode?>(
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            segments: <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                label: Text(ThemeMode.system.name),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                label: Text(ThemeMode.dark.name),
                icon: const Icon(
                  Icons.dark_mode,
                ),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                label: Text(ThemeMode.light.name),
                icon: const Icon(
                  Icons.light_mode,
                ),
              ),
            ],
            selected: <ThemeMode>{ThemeViewModel.instance.themeMode},
            onSelectionChanged: onSelected,
          ),
        ],
      ),
    ),
  );

  /// Called when a [ChoiceChip] is selected.
  ///
  /// Updates the [ThemeViewModel] with the [newSelection]. If [newSelection]
  /// is null (which can happen if a chip is deselected, though not in this
  /// specific UI setup),
  /// it defaults to [ThemeMode.system].
  ///
  /// - [newSelection]: The [ThemeMode] selected by the user.
  @protected
  void onSelected(Set<ThemeMode?> newSelection) => setState(() {
    unawaited(
      ThemeViewModel.instance.setThemeMode(
        newSelection.first ?? ThemeMode.system,
      ),
    );
  });
}

/// Manages the application's theme, including light and dark modes,
/// custom color schemes, and persistence of the selected theme.
///
/// This class follows a singleton pattern, accessible via
/// `ThemeViewModel.instance`.
///
/// Key functionalities:
/// - Persists the selected [ThemeMode] using [SharedPreferences].
/// - Provides [ThemeData] for both light and dark modes, customizable at
///   initialization and runtime.
/// - Exposes a [themeStream] to notify listeners of theme changes.
/// - Offers convenient getters for theme-dependent colors
///   (e.g., `redColor`, `greenColor`).
/// - Allows dynamic updates to the theme's color scheme.
///
/// The theme mode is stored under the key
/// `SharedPreferencesKeys.fhuThemeMode.name`
/// in shared preferences.
/// The theme is set to [ThemeMode.system] by default.
class ThemeViewModel {
  /// Private constructor for the [ThemeViewModel] singleton.
  ///
  /// Initializes [_lightColorScheme] and [_darkColorScheme],
  /// sets the default [_themeMode] to [ThemeMode.system],
  /// creates the initial [darkTheme] and [lightTheme] based on the provided
  /// schemes, and attempts to load the persisted theme mode from
  /// [SharedPreferences].
  @visibleForTesting
  ThemeViewModel({
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
    })
    darkColorScheme,
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
    })
    lightColorScheme,
  }) : _lightColorScheme = lightColorScheme,
       _darkColorScheme = darkColorScheme,
       _themeMode = ThemeMode.system {
    // initialize dark and light theme
    darkTheme = _themeData(
      themeMode: ThemeMode.dark,
      colorScheme: _darkColorScheme,
    );
    lightTheme = _themeData(
      themeMode: ThemeMode.dark,
      colorScheme: _lightColorScheme,
    );

    unawaited(
      SharedPreferencesAsync()
          .getString(
            _SharedPreferencesKeys.fhuThemeMode.name,
          )
          .then((
            themeModeName,
          ) {
            _themeMode =
                ThemeMode.values
                    .where((element) => element.name == themeModeName)
                    .firstOrNull ??
                ThemeMode.system;
            _themeStreamController.sink.add(theme);
          }),
    );
  }
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
  })
  _darkColorScheme;
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
  })
  _lightColorScheme;

  /// The [ThemeData] for the dark theme.
  ThemeData darkTheme = ThemeData.dark();

  /// The [ThemeData] for the light theme.
  ThemeData lightTheme = ThemeData.light();

  /// Gets the current [ThemeData] based on the selected [themeMode] and
  /// system brightness.
  ///
  /// If [themeMode] is [ThemeMode.system], it considers the platform's
  /// brightness.
  /// Otherwise, it uses the explicitly set light or dark theme.
  ThemeData get theme => isLight ? lightTheme : darkTheme;

  ThemeMode _themeMode;

  /// The current selected [ThemeMode].
  ///
  /// Defaults to [ThemeMode.system] if no theme has been explicitly set or
  /// loaded.
  ThemeMode get themeMode => _themeMode;

  /// A stream controller to broadcast theme changes.
  final StreamController<ThemeData> _themeStreamController =
      StreamController<ThemeData>.broadcast();

  /// A stream that emits an event whenever the theme changes.
  ///
  /// Widgets can listen to this stream to rebuild when the theme is updated.
  /// The emitted value is typically `null` and serves as a notification.
  Stream<ThemeData> get themeStream => _themeStreamController.stream.distinct();

  /// Returns true if theme mode is light
  bool get isLight =>
      _themeMode == ThemeMode.light ||
      (_themeMode == ThemeMode.system && _brightness == Brightness.light);

  /// Returns true if theme mode is dark
  bool get isDark => !isLight;

  /// A gray color that adapts to the current theme (light/dark).
  Color get greyColor => isLight ? Colors.grey.shade600 : Colors.grey.shade400;

  /// A dark grey color that adapts to the current theme (light/dark).
  Color get darkGreyColor =>
      isLight ? Colors.grey.shade900 : Colors.grey.shade600;

  /// A cyan color that adapts to the current theme (light/dark).
  Color get cyanColor => isLight ? Colors.cyan.shade800 : Colors.cyan.shade200;

  /// A blue color that adapts to the current theme (light/dark).
  Color get blueColor => isLight ? Colors.blue.shade800 : Colors.blue.shade200;

  /// A purple color that adapts to the current theme (light/dark).
  Color get purpleColor =>
      isLight ? Colors.purple.shade800 : Colors.purple.shade200;

  /// A deep purple color that adapts to the current theme (light/dark).
  Color get deepPurpleColor =>
      isLight ? Colors.deepPurple.shade800 : Colors.deepPurple.shade200;

  /// A green color that adapts to the current theme (light/dark).
  Color get greenColor =>
      isLight ? Colors.green.shade800 : Colors.green.shade200;

  /// A yellow color that adapts to the current theme (light/dark).
  Color get yellowColor =>
      isLight ? Colors.yellow.shade800 : Colors.yellow.shade200;

  /// An orange color that adapts to the current theme (light/dark).
  Color get orangeColor =>
      isLight ? Colors.orange.shade800 : Colors.orange.shade200;

  /// An deep orange color that adapts to the current theme (light/dark).
  Color get deepOrangeColor =>
      isLight ? Colors.deepOrange.shade800 : Colors.deepOrange.shade200;

  /// A amber color that adapts to the current theme (light/dark).
  Color get amberColor =>
      isLight ? Colors.amber.shade700 : Colors.amber.shade300;

  /// A red color that adapts to the current theme (light/dark).
  Color get redColor => isLight ? Colors.red.shade700 : Colors.red.shade300;

  /// An pink color that adapts to the current theme (light/dark).
  Color get pinkColor => isLight ? Colors.pink.shade800 : Colors.pink.shade200;

  static final ({
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
  })
  _defaultDarkColorScheme = (
    primary: Colors.white,
    disabled: Colors.grey.shade700,
    onPrimary: Colors.black,
    secondary: Colors.white70,
    onSecondary: Colors.grey.shade900,
    error: Colors.white,
    onError: Colors.redAccent,
    surface: Colors.black.withValues(alpha: 0.8),
    onSurface: Colors.white70,
    surfaceContainer: Colors.grey.shade900,
    onSurfaceVariant: Colors.white,
  );

  static final ({
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
  })
  _defaultLightColorScheme = (
    primary: Colors.black,
    disabled: Colors.grey.shade700,
    onPrimary: Colors.white,
    secondary: Colors.grey.shade900,
    onSecondary: Colors.white70,
    error: Colors.white,
    onError: Colors.red,
    surface: Colors.grey.shade400,
    onSurface: Colors.grey.shade900,
    surfaceContainer: Color.lerp(Colors.grey.shade400, Colors.white, 0.3)!,
    onSurfaceVariant: Colors.black,
  );

  static ThemeViewModel? _instance;

  /// Provides the singleton instance of [ThemeViewModel].
  ///
  /// On first call, it initializes the [ThemeViewModel] with optional
  /// [_defaultDarkColorScheme] and [_defaultLightColorScheme]. If these are not
  /// provided, default color schemes are used.
  ///
  /// Subsequent calls return the existing instance.
  /// This method also triggers the loading of the persisted theme mode.
  // ignore: prefer_constructors_over_static_methods
  static ThemeViewModel get instance => _instance ??= ThemeViewModel(
    darkColorScheme: _defaultDarkColorScheme,
    lightColorScheme: _defaultLightColorScheme,
  );

  static set instance(ThemeViewModel instance) => _instance = instance;

  /// The [ColorScheme] of the current theme.
  ColorScheme get colorScheme =>
      isDark ? darkTheme.colorScheme : lightTheme.colorScheme;

  /// Sets the application's [ThemeMode] to the provided [themeMode].
  ///
  /// This new [themeMode] is persisted to [SharedPreferences]
  /// (via `SharedPreferencesAsync`)
  /// and the new theme is emitted on the [themeStream] to notify listeners.
  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    await SharedPreferencesAsync().setString(
      _SharedPreferencesKeys.fhuThemeMode.name,
      themeMode.name,
    );
    _themeStreamController.sink.add(theme);
  }

  /// Resets the light and dark themes to their initial default color schemes.
  ///
  /// This uses the `_initialDarkColorScheme` and `_initialLightColorScheme`
  /// that were provided at initialization or the default ones if none were
  /// given. An event is emitted on the [themeStream].
  /// An event is emitted on the [themeStream].
  void setDefault() {
    darkTheme = _themeData(
      themeMode: ThemeMode.dark,
      colorScheme: _darkColorScheme,
    );
    lightTheme = _themeData(
      themeMode: ThemeMode.light,
      colorScheme: _lightColorScheme,
    );
    _themeStreamController.sink.add(theme);
  }

  /// Updates the theme with new color values.
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
    final lightColorScheme = (
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
    );
    final darkColorScheme = (
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
    lightTheme = _themeData(
      themeMode: ThemeMode.light,
      colorScheme: lightColorScheme,
    );
    darkTheme = _themeData(
      themeMode: ThemeMode.dark,
      colorScheme: darkColorScheme,
    );
    _themeStreamController.sink.add(theme);
  }

  /// Calculates a suitable foreground color based on a given [color]
  /// and [themeMode].
  ///
  /// It interpolates the [color] towards black for light themes and
  /// towards white for dark themes to ensure readability.
  /// If [themeMode] is not provided, the current [_themeMode] is used.
  Color? themeForegroundColor(Color? color, {ThemeMode? themeMode}) =>
      (themeMode ?? _themeMode) == ThemeMode.light
      ? Color.lerp(color, Colors.black, 0.7)
      : Color.lerp(color, Colors.white, 0.7);

  /// Calculates a suitable background color based on a given [color]
  /// and [themeMode].
  ///
  /// It interpolates the [color] towards white for light themes and towards
  /// black for dark themes.
  /// If [themeMode] is not provided, the current [_themeMode] is used.
  Color? themeBackgroundColor(Color? color, {ThemeMode? themeMode}) =>
      (themeMode ?? _themeMode) == ThemeMode.light
      ? Color.lerp(color, Colors.white, 0.5)
      : Color.lerp(color, Colors.black, 0.5);

  /// Generates a pair of light and dark background colors based on a given
  /// [color].
  ///
  /// Uses [themeBackgroundColor] internally for both [ThemeMode.light] and
  /// [ThemeMode.dark].
  ({Color light, Color dark}) backgroundColor(Color color) => (
    light: themeBackgroundColor(color, themeMode: ThemeMode.light)!,
    dark: themeBackgroundColor(color, themeMode: ThemeMode.dark)!,
  );

  /// Constructs a [ThemeData] object for a specific [themeMode] (light or dark)
  /// using a provided [colorScheme].
  ///
  /// If parts of the [colorScheme] are not provided (i.e., are `null`),
  /// it falls back to the corresponding colors from the
  /// `_initialLightColorScheme`
  /// or `_darkColorScheme` based on the [themeMode].
  /// It also sets various theme properties like [AppBarTheme],
  /// [BottomNavigationBarThemeData], etc.
  ThemeData _themeData({
    required ThemeMode themeMode,
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
    })
    colorScheme,
  }) {
    final initialColorScheme = themeMode == ThemeMode.light
        ? _lightColorScheme
        : _darkColorScheme;
    final primary = colorScheme.primary ?? initialColorScheme.primary;
    final disabled = colorScheme.disabled ?? initialColorScheme.disabled;
    final onPrimary = colorScheme.onPrimary ?? initialColorScheme.onPrimary;
    final secondary = colorScheme.secondary ?? initialColorScheme.secondary;
    final onSecondary =
        colorScheme.onSecondary ?? initialColorScheme.onSecondary;
    final error = colorScheme.error ?? initialColorScheme.error;
    final onError = colorScheme.onError ?? initialColorScheme.onError;
    final surface = colorScheme.surface ?? initialColorScheme.surface;
    final onSurface = colorScheme.onSurface ?? initialColorScheme.onSurface;
    final surfaceContainer =
        colorScheme.surfaceContainer ?? initialColorScheme.surfaceContainer;
    final onSurfaceVariant =
        colorScheme.onSurfaceVariant ?? initialColorScheme.onSurfaceVariant;

    return ThemeData(
      brightness: themeMode == ThemeMode.light
          ? Brightness.light
          : Brightness.dark,
      disabledColor: disabled,
      colorScheme: ColorScheme(
        brightness: themeMode == ThemeMode.light
            ? Brightness.light
            : Brightness.dark,
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
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        unselectedLabelColor: disabled,
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: WidgetStatePropertyAll(primary),
          foregroundColor: WidgetStatePropertyAll(onPrimary),
        ),
      ),
      badgeTheme: BadgeThemeData(backgroundColor: onError, textColor: error),
      appBarTheme: const AppBarTheme(iconTheme: IconThemeData(size: 40)),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: disabled,
        backgroundColor: surfaceContainer,
      ),
      cardTheme: CardThemeData(color: surfaceContainer),
      snackBarTheme: const SnackBarThemeData(
        insetPadding: EdgeInsets.all(20),
        contentTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Gets the current platform brightness (light or dark) from the
  /// [SchedulerBinding].
  ///
  /// This is used when [themeMode] is set to [ThemeMode.system] to determine
  /// which theme to apply.
  Brightness get _brightness =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness;
}
