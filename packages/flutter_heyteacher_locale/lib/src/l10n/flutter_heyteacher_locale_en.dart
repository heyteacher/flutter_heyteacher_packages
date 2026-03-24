// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_locale.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class FlutterHeyteacherLocaleLocalizationsEn
    extends FlutterHeyteacherLocaleLocalizations {
  FlutterHeyteacherLocaleLocalizationsEn([String locale = 'en'])
    : super(locale);

  @override
  String nSeconds(num nSeconds) {
    String _temp0 = intl.Intl.pluralLogic(
      nSeconds,
      locale: localeName,
      other: '$nSeconds seconds',
      one: '1 second',
      zero: '0 seconds',
    );
    return '$_temp0';
  }

  @override
  String nMinutes(num minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutesString minutes',
      one: '1 minute',
      zero: '0 minutes',
    );
    return '$_temp0';
  }

  @override
  String nHours(num hours) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);

    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hoursString hours',
      one: '1 hour',
      zero: '0 hour',
    );
    return '$_temp0';
  }

  @override
  String defaultValue(Object defaultValue) {
    return 'Default: $defaultValue';
  }

  @override
  String get skip => 'Skip';

  @override
  String get description => 'Description';

  @override
  String get contentUnavailableOfflineRetryWhenOnline =>
      'Content unavailable offline.\n\nRetry when the device is connected to the internet.';

  @override
  String ttsTest(Object languageCode, Object countryCode) {
    return 'This is a test. Language is $languageCode, country is $countryCode';
  }
}
