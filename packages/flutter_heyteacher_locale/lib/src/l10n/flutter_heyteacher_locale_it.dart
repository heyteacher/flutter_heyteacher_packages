// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_locale.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class FlutterHeyteacherLocaleLocalizationsIt
    extends FlutterHeyteacherLocaleLocalizations {
  FlutterHeyteacherLocaleLocalizationsIt([String locale = 'it'])
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
      other: '$minutesString minuti',
      one: '1 minuto',
      zero: '0 minuti',
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
      other: '$hoursString ore',
      one: '1 ora',
      zero: '0 ore',
    );
    return '$_temp0';
  }

  @override
  String defaultValue(Object defaultValue) {
    return 'Predefinito: $defaultValue';
  }

  @override
  String get skip => 'Salta';

  @override
  String get description => 'Descrizione';

  @override
  String get contentUnavailableOfflineRetryWhenOnline =>
      'Contenuto non disponibile offline.\n\nRiprova quando il dispositivo è connesso a internet.';

  @override
  String ttsTest(Object languageCode, Object countryCode) {
    return 'Questa è una prova. La lingua è $languageCode, il paese è $countryCode';
  }
}
