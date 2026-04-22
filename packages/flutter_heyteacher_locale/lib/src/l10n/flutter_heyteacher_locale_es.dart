// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_locale.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class FlutterHeyteacherLocaleLocalizationsEs
    extends FlutterHeyteacherLocaleLocalizations {
  FlutterHeyteacherLocaleLocalizationsEs([String locale = 'es'])
    : super(locale);

  @override
  String nSeconds(num nSeconds) {
    String _temp0 = intl.Intl.pluralLogic(
      nSeconds,
      locale: localeName,
      other: '$nSeconds segs',
      one: '1 seg',
      zero: '0 seg',
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
      other: '$minutesString minutos',
      one: '1 minuto',
      zero: '0 minutos',
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
      other: '$hoursString horas',
      one: '1 hora',
      zero: '0 horas',
    );
    return '$_temp0';
  }

  @override
  String defaultValue(Object defaultValue) {
    return 'Predeterminado: $defaultValue';
  }

  @override
  String booleanValue(String booleanValue) {
    String _temp0 = intl.Intl.selectLogic(
      booleanValue,
      {
        'true': 'Sí',
        'false': 'No',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get skip => 'Omitir';

  @override
  String get description => 'Descripción';

  @override
  String get contentUnavailableOfflineRetryWhenOnline =>
      'Contenido no disponible sin conexión.\n\nIntente de nuevo cuando el dispositivo esté conectado a internet.';

  @override
  String ttsTest(Object languageCode, Object countryCode) {
    return 'Este es un test. El idioma es $languageCode, el país es $countryCode';
  }
}
