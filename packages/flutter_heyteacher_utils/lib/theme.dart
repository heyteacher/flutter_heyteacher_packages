/// Manages application-wide theming, including theme selection UI,
/// theme persistence, and dynamic theme updates.
///
/// This library provides:
/// - [ThemeCard]: A widget for users to select between light, dark, or system default themes.
/// - [ThemeModel]: A singleton class responsible for holding the current theme state,
///   persisting user preferences, providing theme data, and broadcasting theme changes.
///
library;

export 'src/theme.dart' show ThemeCard, ThemeModelView, ThemeCardState;