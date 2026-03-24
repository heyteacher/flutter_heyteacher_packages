// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_locale.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class FlutterHeyteacherLocaleLocalizationsFr
    extends FlutterHeyteacherLocaleLocalizations {
  FlutterHeyteacherLocaleLocalizationsFr([String locale = 'fr'])
    : super(locale);

  @override
  String nSeconds(num nSeconds) {
    String _temp0 = intl.Intl.pluralLogic(
      nSeconds,
      locale: localeName,
      other: '$nSeconds sec',
      one: '1 sec',
      zero: '0 sec',
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
      other: '$hoursString heures',
      one: '1 heure',
      zero: '0 heure',
    );
    return '$_temp0';
  }

  @override
  String defaultValue(Object defaultValue) {
    return 'Par défaut : $defaultValue';
  }

  @override
  String get skip => 'Passer';

  @override
  String get description => 'Description';

  @override
  String get contentUnavailableOfflineRetryWhenOnline =>
      'Contenu indisponible hors ligne.\n\nRéessayez lorsque l\'appareil est connecté à internet.';

  @override
  String ttsTest(Object languageCode, Object countryCode) {
    return 'Ceci est un test. La langue est $languageCode, le pays est $countryCode';
  }
}
