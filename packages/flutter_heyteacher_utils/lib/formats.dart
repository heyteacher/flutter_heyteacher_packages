/// Provides a collection of pre-configured formatters for dates, times, numbers,
/// and durations.
///
/// This library centralizes common formatting patterns using `intl` package's
/// [DateFormat] and [NumberFormat], and offers custom functions for
/// human-readable duration strings.
library;

import 'package:intl/intl.dart';

/// Formatter for date and time, suitable for machine keys (e.g., "yyyyMMdd_HHmmss").
final DateFormat machineDateTimeFormatter = DateFormat("yyyyMMdd_HHmmss");

final DateFormat machineDateFormatter = DateFormat("yyyyMMdd");

final DateFormat machineTimeFormatter = DateFormat("HHmmss");

/// Formatter for date and time (e.g., "dd/MM/yyyy HH:mm").
final DateFormat dateTimeFormatter = DateFormat("dd/MM/yyyy HH:mm");

/// Formatter for date only (e.g., "dd/MM/yyyy").
final DateFormat dateFormatter = DateFormat("dd/MM/yyyy");

/// Formatter for time with seconds (e.g., "HH:mm:ss").
final DateFormat timeWithSecondsFormatter = DateFormat("HH:mm:ss");

/// Formatter for date and time with seconds (e.g., "dd/MM/yyyy HH:mm:ss").
final DateFormat dateTimeWithSecondsFormatter = DateFormat("dd/MM/yyyy HH:mm:ss");

/// Formatter for integers (e.g., "0").
final NumberFormat intFormatter = NumberFormat("0");

/// Formatter for doubles with one decimal place (e.g., "0.0").
final NumberFormat doubleFormatter = NumberFormat("0.0");

/// Formats a duration in milliseconds into a human-readable string suitable for Text-to-Speech (TTS).
///
/// Uses provided localization functions [nHours] and [nMinutes] to generate
/// localized strings like "X hours Y minutes".
///
/// - [milliseconds]: The duration in milliseconds.
/// - [nHours]: A function that takes an integer (number of hours) and returns a localized string for hours.
/// - [nMinutes]: A function that takes an integer (number of minutes) and returns a localized string for minutes.
/// Returns an empty string if [milliseconds] is null.
String formatDurationTts(
    num? milliseconds, Function(int) nHours, Function(int) nMinutes) {
  if (milliseconds != null) {
    Duration duration = Duration(milliseconds: milliseconds.toInt());
    return ""
        "${duration.inHours >= 0 ? nHours(duration.inHours) : ""} "
        "${nMinutes(duration.inMinutes - (duration.inHours * 60))}";
  } else {
    return "";
  }
}

/// Formats a duration in milliseconds into a readable string (e.g., "hh:mm:ss" or "mm:ss").
///
/// - [milliseconds]: The duration in milliseconds.
/// - [showSeconds]: If `true`, seconds are included in the output (e.g., "hh:mm:ss"). Defaults to `false`.
/// - [showHoursIfZero]: If `true`, hours are always shown (e.g., "00:mm:ss").
///   If `false` and the duration is less than one hour, hours are omitted (e.g., "mm:ss").
///   Defaults to `true`.
/// Returns an empty string if [milliseconds] is null.
String formatDuration(num? milliseconds,
    {bool showSeconds = false, bool showHoursIfZero = true}) {
  if (milliseconds != null) {
    Duration duration = Duration(milliseconds: milliseconds.toInt());
    NumberFormat numberFormat = NumberFormat("00");
    return ""
        "${showHoursIfZero || duration.inHours != 0 ? "${numberFormat.format(duration.inHours)}:" : ""}"
        "${numberFormat.format(duration.inMinutes - (duration.inHours * 60))}"
        "${showSeconds ? ":${numberFormat.format(duration.inSeconds - (duration.inMinutes * 60))}" : ""}";
  } else {
    return "";
  }
}
