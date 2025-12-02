/// Defines screen size categories based on width.
enum ScreenSize {
  /// For screens smaller than 600 logical pixels.
  small,

  /// For screens between 600 and 1200 logical pixels.
  medium,

  /// For screens 1200 logical pixels or wider.
  large;

  /// Determines the [ScreenSize] from a given [width].
  static ScreenSize of(double width) => width < 600
      ? ScreenSize.small
      : width < 1200
      ? ScreenSize.medium
      : ScreenSize.large;
}
