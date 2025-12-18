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
  String get errorOnRetrieveData => 'Fehler beim Abrufen von Daten';

  @override
  String get timeoutOnRetrieveData =>
      'Zeitüberschreitung beim Abrufen von Daten';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get areYouSureToConfirmTheAction =>
      'Möchten Sie die Aktion wirklich bestätigen?';

  @override
  String get encryptionPassphraseIsEmptySetIt =>
      'Verschlüsselungspassphrase ist leer, bitte festlegen';

  @override
  String get missingEncryptionSecretKeyImportIt =>
      'Fehlender Verschlüsselungs-Geheimschlüssel, bitte importieren';

  @override
  String get errorOnEncryptionCheckPassphrase =>
      'Fehler bei der Verschlüsselung, überprüfen Sie die Verschlüsselungspassphrase';

  @override
  String get errorOnDecryptionCheckPassphrase =>
      'Fehler bei der Entschlüsselung, überprüfen Sie die Verschlüsselungspassphrase';

  @override
  String get id => 'ID: ';

  @override
  String get version => 'Version: ';

  @override
  String get askSupport => 'Support anfragen';

  @override
  String get askSupportFor => 'Support anfragen für: ';

  @override
  String get logging => 'Protokollierung';

  @override
  String get loggingLevel => 'Protokollierungsstufe';

  @override
  String nMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes Minuten',
      one: 'eine Minute',
    );
    return '$_temp0';
  }

  @override
  String get areYouSureToChangeEncryptionPassphrase =>
      'Wenn Sie die Verschlüsselungspassphrase ändern, können Sie nicht mehr auf Daten zugreifen, die mit der alten Passphrase verschlüsselt wurden.\n\nMöchten Sie die Verschlüsselungspassphrase wirklich ändern?';

  @override
  String get areYouSureToImportEncryptionSecretKey =>
      'Wenn Sie einen Verschlüsselungs-Geheimschlüssel importieren, wird der alte Schlüssel überschrieben und mit dem alten Schlüssel verschlüsselte Daten gehen verloren.\n\nMöchten Sie den Verschlüsselungs-Geheimschlüssel wirklich importieren?';

  @override
  String get encryptionSecretKeyImported =>
      'Verschlüsselungs-Geheimschlüssel importiert';

  @override
  String get encryptionPassphrase => 'Verschlüsselungspassphrase';

  @override
  String get encryptionSecretKey => 'Verschlüsselungs-Geheimschlüssel';

  @override
  String
  get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase =>
      'Scannen Sie den QR-Code mit einem anderen Gerät oder speichern Sie ihn an einem sicheren Ort.\nDer QR-Code ist mit der Verschlüsselungspassphrase verschlüsselt.\nSie müssen auf dem neuen Gerät dieselbe Verschlüsselungspassphrase festlegen.';

  @override
  String get errorWorkflowTaskAlreadyInitialized =>
      'Workflow-Aufgabe bereits initialisiert';

  @override
  String get errorWorkflowNotInitialized => 'Workflow nicht initialisiert';

  @override
  String get contentUnavailableOfflineRetryWhenOnline =>
      'Inhalt offline nicht verfügbar.\n\nVersuchen Sie es erneut, wenn das Gerät mit dem Internet verbunden ist.';

  @override
  String get deleteUserData => 'Löschung der Benutzerdaten planen';

  @override
  String doYouConfirmDeletionUserData(Object expireDateTime) {
    return 'Bestätigen Sie die Löschung Ihrer Benutzerdaten?\nSeien Sie vorsichtig! Diese Aktion kann erst nach $expireDateTime rückgängig gemacht werden.';
  }

  @override
  String get restoreUserData => 'Benutzerdaten wiederherstellen';

  @override
  String doYouConfirmRestoringUserData(Object expireDateTime) {
    return 'Sie haben die Löschung Ihrer Benutzerdaten für $expireDateTime geplant.\nBestätigen Sie, dass Sie die geplante Löschung abbrechen möchten?';
  }

  @override
  String get task => 'Aufgabe';

  @override
  String get description => 'Beschreibung';

  @override
  String get tasks => 'Aufgaben';

  @override
  String get skip => 'Überspringen';

  @override
  String get deviceOfflineAskSupportWhenOnline =>
      'Gerät offline. Support anfragen, wenn das Gerät mit dem Internet verbunden ist.';

  @override
  String defaultValue(Object defaultValue) {
    return 'Standard: $defaultValue';
  }

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
  String get search => 'Suchen';

  @override
  String get enableLogsStorage => 'Protokollspeicherung aktivieren';
}
