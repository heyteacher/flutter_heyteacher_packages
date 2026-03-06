/// Provides a collection of pre-configured formatters for dates, times,
/// numbers, and durations.
///
/// This library centralizes common formatting patterns using `intl` package's
/// [DateFormat] and [NumberFormat], and offers custom functions for
/// human-readable duration strings.
library;

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_heyteacher_locale/src/l10n/flutter_heyteacher_locale.dart';
import 'package:flutter_heyteacher_locale/src/locale.dart';
import 'package:flutter_heyteacher_platform/platform.dart';
import 'package:intl/intl.dart';

/// A utility class providing static methods and pre-configured formatters for
/// common data types like dates, numbers, and durations.
///
/// This class is not meant to be instantiated.
class FormatterHelper {
  // A private constructor to prevent instantiation of this utility class.
  FormatterHelper._();
  static const _machineDateTimeFormatPattern = 'yyyyMMdd_HHmmss';

  /// Formatter for date and time, suitable for machine keys
  /// (e.g., "yyyyMMdd_HHmmss").
  static final DateFormat _machineDateTimeFormatter = DateFormat(
    _machineDateTimeFormatPattern,
  );

  static final DateFormat _machineDateFormatter = DateFormat('yyyyMMdd');

  static final DateFormat _machineTimeFormatter = DateFormat('HHmmss');

  /// Formatter for date and time (e.g., "dd/MM/yyyy HH:mm").
  static DateFormat get _dateTimeFormatter =>
      DateFormat.yMd(LocaleViewModel.instance.locale.toLanguageTag())..add_jm();

  /// Formatter for date only (e.g., "dd/MM/yyyy").
  static DateFormat get _dateFormatter =>
      DateFormat.yMd(LocaleViewModel.instance.locale.toLanguageTag());

  /// Formatter for date only (e.g., "dd/MM").
  static DateFormat get _ddMMFormatter =>
      DateFormat.Md(LocaleViewModel.instance.locale.toLanguageTag());

  /// Formatter for time with seconds (e.g., "HH:mm:ss").
  static DateFormat get _timeFormatter =>
      DateFormat.jm(LocaleViewModel.instance.locale.toLanguageTag());

  /// Formatter for time with seconds (e.g., "HH:mm:ss").
  static DateFormat get _timeWithSecondsFormatter =>
      DateFormat.jms(LocaleViewModel.instance.locale.toLanguageTag());

  /// Formatter for date and time with seconds (e.g., "dd/MM/yyyy HH:mm:ss").
  static DateFormat get _dateTimeWithSecondsFormatter =>
      DateFormat.yMd(LocaleViewModel.instance.locale.toLanguageTag()).add_jms();

  /// Formatter for integers (e.g., "0").
  static final NumberFormat _intFormatter = NumberFormat('0');

  /// Formatter for doubles with one decimal place (e.g., "0.0").
  static NumberFormat get _doubleFormatter => NumberFormat.decimalPatternDigits(
    locale: LocaleViewModel.instance.locale.toLanguageTag(),
    decimalDigits: 1,
  );

  /// Formats a [DateTime] into a machine-readable string `yyyyMMdd_HHmmss`.
  /// Returns [defaultValue] if [dateTime] is null.
  static String machineDateTimeFormat(
    DateTime? dateTime, {
    String defaultValue = '',
  }) => dateTime != null
      ? _machineDateTimeFormatter.format(dateTime)
      : defaultValue;

  /// Parses a machine-readable date string `yyyyMMdd_HHmmss` into a [DateTime]
  /// object. Returns `null` if [value] is null.
  /// 
  /// Source - (https://stackoverflow.com/a/78764981)
  /// Posted by Robert
  /// Retrieved 2026-03-06, License - CC BY-SA 4.0
  static DateTime? machineDateTimeParse(String? value) => value == null
      ? null
      : DateTime(
          int.parse(value.substring(0, 4)),
          int.parse(value.substring(4, 6)),
          int.parse(value.substring(6, 8)),
          int.parse(value.substring(9, 11)),
          int.parse(value.substring(11, 13)),
          int.parse(value.substring(13, 15)),
        );

  /// Formats a [DateTime] into a machine-readable date string `yyyyMMdd`.
  /// Returns [defaultValue] if [dateTime] is null.
  static String machineDateFormat(
    DateTime? dateTime, {
    String defaultValue = '',
  }) =>
      dateTime != null ? _machineDateFormatter.format(dateTime) : defaultValue;

  /// Formats a [DateTime] into a machine-readable time string `HHmmss`.
  /// Returns [defaultValue] if [dateTime] is null.
  static String machineTimeFormat(
    DateTime? dateTime, {
    String defaultValue = '',
  }) =>
      dateTime != null ? _machineTimeFormatter.format(dateTime) : defaultValue;

  /// Formats a [DateTime] into a human-readable string `dd/MM/yyyy HH:mm`.
  /// Returns [defaultValue] if [dateTime] is null.
  static String dateTimeFormat(
    DateTime? dateTime, {
    String defaultValue = '',
  }) => dateTime != null ? _dateTimeFormatter.format(dateTime) : defaultValue;

  /// Formats a [DateTime] into a human-readable date string `dd/MM/yyyy`.
  /// Returns [defaultValue] if [dateTime] is null.
  static String dateFormat(DateTime? dateTime, {String defaultValue = ''}) =>
      dateTime != null ? _dateFormatter.format(dateTime) : defaultValue;

  /// Formats a [DateTime] into a human-readable date string `dd/MM`.
  /// Returns [defaultValue] if [dateTime] is null.
  static String ddMMFormat(DateTime? dateTime, {String defaultValue = ''}) =>
      dateTime != null ? _ddMMFormatter.format(dateTime) : defaultValue;

  /// Formats a [DateTime] into a human-readable time string `HH:mm`.
  /// Returns [defaultValue] if [dateTime] is null.
  static String timeFormat(DateTime? dateTime, {String defaultValue = ''}) =>
      dateTime != null ? _timeFormatter.format(dateTime) : defaultValue;

  /// Formats a [DateTime] into a human-readable time string `HH:mm:ss`.
  /// Returns [defaultValue] if [dateTime] is null.
  static String timeWithSecondsFormat(
    DateTime? dateTime, {
    String defaultValue = '',
  }) => dateTime != null
      ? _timeWithSecondsFormatter.format(dateTime)
      : defaultValue;

  /// Formats a [DateTime] into a human-readable string `dd/MM/yyyy HH:mm:ss`.
  /// Returns [defaultValue] if [dateTime] is null.
  static String dateTimeWithSecondsFormat(
    DateTime? dateTime, {
    String defaultValue = '',
  }) => dateTime != null
      ? _dateTimeWithSecondsFormatter.format(dateTime)
      : defaultValue;

  /// Formats a [num] as an integer string.
  /// Returns [defaultValue] if [num] is null.
  static String intFormat(num? num, {String defaultValue = ''}) =>
      num != null ? _intFormatter.format(num) : defaultValue;

  /// Parses a string into an integer.
  static num intParse(String string) => _intFormatter.parse(string);

  /// Formats a [num] as a double string with one decimal place.
  /// Returns [defaultValue] if [num] is null.
  static String doubleFormat(num? num, {String defaultValue = ''}) =>
      num != null ? _doubleFormatter.format(num) : defaultValue;

  /// Converts a [DateTime] object to an integer representing milliseconds
  /// since the Unix epoch.
  ///
  /// Returns `null` if the input [value] is null.
  /// This is commonly used for serializing dates to JSON.
  static int? dateTimeToJson(DateTime? value) => value?.millisecondsSinceEpoch;

  /// Converts an integer representing milliseconds since the Unix epoch to a
  /// [DateTime] object.
  ///
  /// Returns `null` if the input [value] is null.
  /// This is commonly used for deserializing dates from JSON.
  static DateTime? dateTimeFromJson(int? value) =>
      value != null ? DateTime.fromMillisecondsSinceEpoch(value) : null;

  /// Formats a duration in milliseconds into a human-readable string suitable
  /// for Text-to-Speech (TTS).
  ///
  /// - [duration]: The duration to format.
  ///   and returns a localized string for minutes.
  /// Returns an empty string if [duration] is null.
  /// - [speakHours]: If `true`, hours are included in the output
  ///   (e.g., "one hours two minutes"). if `false` format minutes only.
  ///   (e.g., "seventy minutes fortyfive seconds").
  ///   Defaults to `true`.
  /// - [speakSeconds]: If `true`, seconds are included in the output
  ///   (e.g., "one hours two minutes and three seconds").
  ///   Defaults to `true`.
  static Future<String> formatDurationTts(
    Duration? duration, {
    bool speakHours = true,
    bool speakSeconds = true,
  }) async {
    if (duration != null) {
      late FlutterHeyteacherLocaleLocalizations i10n;
      if (ContextHelper.context != null) {
        i10n = FlutterHeyteacherLocaleLocalizations.of(
          ContextHelper.context!,
        )!;
      } else {
        i10n = await FlutterHeyteacherLocaleLocalizations.delegate.load(
          const Locale('en'),
        );
      }
      return '${duration.inHours > 0 && speakHours ? i10n.nHours(
                      duration.inHours,
                    ) : ''} '
              '${i10n.nMinutes(
                duration.inMinutes - (speakHours ? duration.inHours * 60 : 0),
              )} '
              '${speakSeconds ? i10n.nSeconds(
                      duration.inSeconds - (duration.inMinutes * 60),
                    ) : ''}'
          .trim();
    } else {
      return '';
    }
  }

  /// Formats a duration in milliseconds into a readable string
  /// (e.g., "hh:mm:ss" or "mm:ss").
  ///
  /// - [milliseconds]: The duration in milliseconds.
  /// - [showSeconds]: If `true`, seconds are included in the output
  ///    (e.g., "hh:mm:ss"). Defaults to `false`.
  /// - [showHoursIfZero]: If `true`, hours are always shown
  ///   (e.g., "00:mm:ss").
  ///   If `false` and the duration is less than one hour, hours are omitted
  ///   (e.g., "mm:ss").
  ///   Defaults to `true`.
  /// Returns an empty string if [milliseconds] is null.
  static String formatDuration(
    num? milliseconds, {
    bool showSeconds = false,
    bool showHoursIfZero = true,
  }) {
    if (milliseconds != null) {
      final duration = Duration(milliseconds: milliseconds.toInt());
      final numberFormat = NumberFormat('00');
      return ''
          "${showHoursIfZero || duration.inHours != 0 ? "${numberFormat.format(
                  duration.inHours,
                )}:" : ""}"
          '${numberFormat.format(duration.inMinutes - (duration.inHours * 60))}'
          "${showSeconds ? ":${numberFormat.format(
                  duration.inSeconds - (duration.inMinutes * 60),
                )}" : ""}";
    } else {
      return '';
    }
  }

  /// Calculates the difference between two [DateTime] objects in minutes as a
  /// [double].
  static double differenceInMinute(DateTime sup, DateTime inf) =>
      sup.difference(inf).inSeconds / 60;
}
