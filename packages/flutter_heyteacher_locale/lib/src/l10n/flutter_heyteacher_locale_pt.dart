// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_locale.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class FlutterHeyteacherLocaleLocalizationsPt
    extends FlutterHeyteacherLocaleLocalizations {
  FlutterHeyteacherLocaleLocalizationsPt([String locale = 'pt'])
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
    return 'Padrão: $defaultValue';
  }

  @override
  String get skip => 'Pular';

  @override
  String get description => 'Descrição';

  @override
  String get contentUnavailableOfflineRetryWhenOnline =>
      'Conteúdo indisponível offline.\n\nTente novamente quando o dispositivo estiver conectado à internet.';

  @override
  String ttsTest(Object languageCode, Object countryCode) {
    return 'Este é um teste. A língua é $languageCode, o país é $countryCode';
  }
}
