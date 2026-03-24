// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_locale.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class FlutterHeyteacherLocaleLocalizationsDe
    extends FlutterHeyteacherLocaleLocalizations {
  FlutterHeyteacherLocaleLocalizationsDe([String locale = 'de'])
    : super(locale);

  @override
  String nSeconds(num nSeconds) {
    String _temp0 = intl.Intl.pluralLogic(
      nSeconds,
      locale: localeName,
      other: '$nSeconds Sek.',
      one: '1 Sek.',
      zero: '0 Sek.',
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
      other: '$minutesString Minuten',
      one: '1 Minute',
      zero: '0 Minuten',
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
      other: '$hoursString Stunden',
      one: '1 Stunde',
      zero: '0 Stunden',
    );
    return '$_temp0';
  }

  @override
  String defaultValue(Object defaultValue) {
    return 'Standard: $defaultValue';
  }

  @override
  String get skip => 'Überspringen';

  @override
  String get description => 'Beschreibung';

  @override
  String get contentUnavailableOfflineRetryWhenOnline =>
      'Inhalt offline nicht verfügbar.\n\nVersuchen Sie es erneut, wenn das Gerät mit dem Internet verbunden ist.';

  @override
  String ttsTest(Object languageCode, Object countryCode) {
    return 'Dies ist ein Test. Sprache ist $languageCode, Land ist $countryCode';
  }
}
