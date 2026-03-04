/// Provides an extension on [Color] to convert it to a 32-bit integer
/// representation.
///
/// This is useful for scenarios where an integer representation of a color is
/// needed, for example, in interoperability with systems that expect colors in
/// this format.
library;

import 'dart:ui';

/// Extension on the [Color] class to provide a method for converting
/// the color to its 32-bit integer ARGB representation.
extension ColorEx on Color {
  /// Converts a double value (typically in the range 0.0 to 1.0 for a color
  /// component) to an 8-bit integer (0 to 255).
  static int _floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }

  /// Returns a 32-bit integer value representing this color in ARGB format.
  ///
  /// This is equivalent to the deprecated `Color.value` property.
  ///
  /// The bits are assigned as follows:
  ///
  /// * Bits 24-31 are the alpha value.
  /// * Bits 16-23 are the red value.
  /// * Bits 8-15 are the green value.
  /// * Bits 0-7 are the blue value.
  int get toInt32 {
    return _floatToInt8(a) << 24 |
        _floatToInt8(r) << 16 |
        _floatToInt8(g) << 8 |
        _floatToInt8(b) << 0;
  }
}
