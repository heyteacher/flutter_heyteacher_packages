/// Provides a collection of pre-configured formatters for dates, times, numbers,
/// and durations.
///
/// This library centralizes common formatting patterns using `intl` package's
/// [DateFormat] and [NumberFormat], and offers custom functions for
/// human-readable duration strings.
library;

import 'package:intl/intl.dart';

class FormatterHelper {
  static const _machineDateTimeFormatPattern = 'yyyyMMdd_HHmmss';

  /// Formatter for date and time, suitable for machine keys (e.g., "yyyyMMdd_HHmmss").
  static final DateFormat _machineDateTimeFormatter = DateFormat(
    _machineDateTimeFormatPattern,
  );

  static final DateFormat _machineDateFormatter = DateFormat('yyyyMMdd');

  static final DateFormat _machineTimeFormatter = DateFormat('HHmmss');

  /// Formatter for date and time (e.g., "dd/MM/yyyy HH:mm").
  static final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');

  /// Formatter for date only (e.g., "dd/MM/yyyy").
  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  /// Formatter for date only (e.g., "dd/MM").
  static final DateFormat _ddMMFormatter = DateFormat('dd/MM');

  /// Formatter for time with seconds (e.g., "HH:mm:ss").
  static final DateFormat _timeFormatter = DateFormat('HH:mm');

  /// Formatter for time with seconds (e.g., "HH:mm:ss").
  static final DateFormat _timeWithSecondsFormatter = DateFormat('HH:mm:ss');

  /// Formatter for date and time with seconds (e.g., "dd/MM/yyyy HH:mm:ss").
  static final DateFormat _dateTimeWithSecondsFormatter = DateFormat(
    'dd/MM/yyyy HH:mm:ss',
  );

  /// Formatter for integers (e.g., "0").
  static final NumberFormat _intFormatter = NumberFormat('0');

  /// Formatter for doubles with one decimal place (e.g., "0.0").
  static final NumberFormat _doubleFormatter = NumberFormat('0.0');

  static String machineDateTimeFormat(
    DateTime? dateTime, {
    String defaultValue = '',
  }) => dateTime != null
      ? _machineDateTimeFormatter.format(dateTime)
      : defaultValue;

  static DateTime machineDateTimeParse(String? value) =>
      _dateTimeWithSecondsFormatter.parse(
        '${value!.substring(6, 8)}/'
        '${value.substring(4, 6)}/'
        '${value.substring(0, 4)} '
        '${value.substring(9, 11)}:'
        '${value.substring(11, 13)}:'
        '${value.substring(13, 15)}',
      );

  static String machineDateFormat(
    DateTime? dateTime, {
    String defaultValue = '',
  }) =>
      dateTime != null ? _machineDateFormatter.format(dateTime) : defaultValue;

  static String machineTimeFormat(
    DateTime? dateTime, {
    String defaultValue = '',
  }) =>
      dateTime != null ? _machineTimeFormatter.format(dateTime) : defaultValue;

  static String dateTimeFormat(
    DateTime? dateTime, {
    String defaultValue = '',
  }) => dateTime != null ? _dateTimeFormatter.format(dateTime) : defaultValue;

  static String dateFormat(DateTime? dateTime, {String defaultValue = ''}) =>
      dateTime != null ? _dateFormatter.format(dateTime) : defaultValue;

  static String ddMMFormat(DateTime? dateTime, {String defaultValue = ''}) =>
      dateTime != null ? _ddMMFormatter.format(dateTime) : defaultValue;

  static String timeFormat(DateTime? dateTime, {String defaultValue = ''}) =>
      dateTime != null ? _timeFormatter.format(dateTime) : defaultValue;

  static String timeWithSecondsFormat(
    DateTime? dateTime, {
    String defaultValue = '',
  }) => dateTime != null
      ? _timeWithSecondsFormatter.format(dateTime)
      : defaultValue;

  static String dateTimeWithSecondsFormat(
    DateTime? dateTime, {
    String defaultValue = '',
  }) => dateTime != null
      ? _dateTimeWithSecondsFormatter.format(dateTime)
      : defaultValue;

  static String intFormat(num? num, {String defaultValue = ''}) =>
      num != null ? _intFormatter.format(num) : defaultValue;

  static num intParse(String string) => _intFormatter.parse(string);

  static String doubleFormat(num? num, {String defaultValue = ''}) =>
      num != null ? _doubleFormatter.format(num) : defaultValue;

  static int dateTimeToJson(DateTime value) => value.millisecondsSinceEpoch;

  static DateTime dateTimeFromJson(int value) =>
      DateTime.fromMillisecondsSinceEpoch(value);

  /// Formats a duration in milliseconds into a human-readable string suitable for Text-to-Speech (TTS).
  ///
  /// Uses provided localization functions [nHours] and [nMinutes] to generate
  /// localized strings like "X hours Y minutes".
  ///
  /// - [milliseconds]: The duration in milliseconds.
  /// - [nHours]: A function that takes an integer (number of hours) and returns a localized string for hours.
  /// - [nMinutes]: A function that takes an integer (number of minutes) and returns a localized string for minutes.
  /// Returns an empty string if [milliseconds] is null.
  static String formatDurationTts(
    num? milliseconds,
    Function(int) nHours,
    Function(int) nMinutes,
  ) {
    if (milliseconds != null) {
      Duration duration = Duration(milliseconds: milliseconds.toInt());
      return ''
              '${duration.inHours > 0 ? nHours(duration.inHours) : ""} '
              '${nMinutes(duration.inMinutes - (duration.inHours * 60))}'
          .trim();
    } else {
      return '';
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
  static String formatDuration(
    num? milliseconds, {
    bool showSeconds = false,
    bool showHoursIfZero = true,
  }) {
    if (milliseconds != null) {
      Duration duration = Duration(milliseconds: milliseconds.toInt());
      NumberFormat numberFormat = NumberFormat('00');
      return ''
          "${showHoursIfZero || duration.inHours != 0 ? "${numberFormat.format(duration.inHours)}:" : ""}"
          '${numberFormat.format(duration.inMinutes - (duration.inHours * 60))}'
          "${showSeconds ? ":${numberFormat.format(duration.inSeconds - (duration.inMinutes * 60))}" : ""}";
    } else {
      return '';
    }
  }

  static double differenceInMinute(DateTime sup, DateTime inf) =>
      (sup.difference(inf).inSeconds / 60);
}
