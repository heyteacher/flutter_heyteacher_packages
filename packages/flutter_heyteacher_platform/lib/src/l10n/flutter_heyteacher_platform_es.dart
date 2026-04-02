// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_platform.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class FlutterHeyteacherPlatformLocalizationsEs
    extends FlutterHeyteacherPlatformLocalizations {
  FlutterHeyteacherPlatformLocalizationsEs([String locale = 'es'])
    : super(locale);

  @override
  String get askSupport => 'Solicitar soporte';

  @override
  String get askSupportFor => 'Solicitar soporte para: ';

  @override
  String get deviceOfflineAskSupportWhenOnline =>
      'Dispositivo sin conexión. Solicite soporte cuando el dispositivo esté conectado a internet.';

  @override
  String get advancedFeaturesUnlocked =>
      '¡Características avanzadas desbloqueadas!';
}
