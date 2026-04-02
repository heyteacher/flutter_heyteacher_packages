// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_platform.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class FlutterHeyteacherPlatformLocalizationsFr
    extends FlutterHeyteacherPlatformLocalizations {
  FlutterHeyteacherPlatformLocalizationsFr([String locale = 'fr'])
    : super(locale);

  @override
  String get askSupport => 'Demander de l\'aide';

  @override
  String get askSupportFor => 'Demander de l\'aide pour : ';

  @override
  String get deviceOfflineAskSupportWhenOnline =>
      'Appareil hors ligne. Demandez de l\'aide lorsque l\'appareil est connecté à internet.';

  @override
  String get advancedFeaturesUnlocked =>
      'Fonctionnalités avancées déverrouillées!';
}
