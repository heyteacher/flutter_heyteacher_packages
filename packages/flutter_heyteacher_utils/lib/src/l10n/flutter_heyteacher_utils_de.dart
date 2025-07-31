// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class FlutterHeyteacherUtilsLocalizationsDe
    extends FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get account => 'Konto';

  @override
  String get userNotAuthenticated => 'Benutzer nicht authentifiziert';

  @override
  String get notAuthenticated => 'Nicht authentifiziert';

  @override
  String get errorOnRetrieveData => 'Fehler beim Abrufen der Daten';

  @override
  String get timeoutOnRetrieveData =>
      'Zeitüberschreitung beim Abrufen der Daten';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get areYouSureToConfirmTheAction =>
      'Sind Sie sicher, dass Sie die Aktion bestätigen möchten?';

  @override
  String get encryptionPassphraseIsEmptySetIt =>
      'Verschlüsselungspasswort ist leer, bitte festlegen';

  @override
  String get missingEncryptionSecretKeyImportIt =>
      'Fehlender geheimer Verschlüsselungsschlüssel, bitte importieren';

  @override
  String get errorOnEncryptionCheckPassphrase =>
      'Fehler bei der Verschlüsselung, überprüfen Sie das Verschlüsselungspasswort';

  @override
  String get errorOnDecryptionCheckPassphrase =>
      'Fehler bei der Entschlüsselung, überprüfen Sie das Verschlüsselungspasswort';

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

  @override
  String nMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes Minuten',
      one: '$minutes Minuten',
    );
    return '$_temp0 ';
  }

  @override
  String get areYouSureToChangeEncryptionPassphrase =>
      'Sind Sie sicher, dass Sie das Verschlüsselungspasswort ändern möchten?';

  @override
  String get areYouSureToImportEncryptionSecretKey =>
      'Sind Sie sicher, dass Sie den geheimen Verschlüsselungsschlüssel importieren möchten?';

  @override
  String get encryptionSecretKeyImported =>
      'Geheimer Verschlüsselungsschlüssel importiert';

  @override
  String get encryptionPassphrase => 'Verschlüsselungspasswort';

  @override
  String get encryptionSecretKey => 'Geheimer Verschlüsselungsschlüssel';

  @override
  String get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase =>
      'Scannen Sie den QR-Code mit einem anderen Gerät oder speichern Sie ihn an einem sicheren Ort. Denken Sie daran, dasselbe Passwort zu verwenden.';

  @override
  String get errorWorkflowTaskAlreadyInitialized =>
      'Workflow-Aufgabe bereits initialisiert';

  @override
  String get errorWorkflowNotInitialized => 'Workflow nicht initialisiert';

  @override
  String get contentUnavailableOfflineRetryWhenOnline =>
      'Inhalt offline nicht verfügbar.\\n\\nBitte versuchen Sie es erneut, wenn Sie mit dem Internet verbunden sind.';

  @override
  String get deleteUserData => 'Benutzerdaten löschen';

  @override
  String get doYouConfirmDeletionUserData =>
      'Möchten Sie das Löschen der Benutzerdaten bestätigen?';

  @override
  String get task => 'Aufgabe';

  @override
  String get description => 'Beschreibung';

  @override
  String get tasks => 'Aufgaben';
}
