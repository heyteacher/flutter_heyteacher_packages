// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class FlutterHeyteacherUtilsLocalizationsDe extends FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get userNotAutenticated => 'Benutzer nicht authentifiziert';

  @override
  String get notAuthenticated => 'Nicht authentifiziert';

  @override
  String get errorOnRetrieveData => 'Fehler beim Abrufen der Daten';

  @override
  String get timeoutOnRetrieveData => 'Zeitüberschreitung beim Abrufen der Daten';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get areYouSureToConfirmTheAction => 'Sind Sie sicher, dass Sie die Aktion bestätigen möchten?';

  @override
  String get encryptionPassphraseIsEmptySetIt => 'Verschlüsselungspasswort ist leer, bitte festlegen';

  @override
  String get missingEncryptionSecretKeyImportIt => 'Fehlender geheimer Verschlüsselungsschlüssel, bitte importieren';

  @override
  String get errorOnEncryptionCheckPassphrase => 'Fehler bei der Verschlüsselung, überprüfen Sie das Verschlüsselungspasswort';

  @override
  String get errorOnDecryptionCheckPassphrase => 'Fehler bei der Entschlüsselung, überprüfen Sie das Verschlüsselungspasswort';

  @override
  String get id => 'Id: ';

  @override
  String get version => 'Version: ';

  @override
  String get askSupport => 'Support anfordern';

  @override
  String get askSupportFor => 'Support anfordern für: ';

  @override
  String get logging => 'Protokollierung';
}
