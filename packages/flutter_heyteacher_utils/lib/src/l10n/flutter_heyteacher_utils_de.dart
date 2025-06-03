// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class FlutterHeyteacherUtilsLocalizationsDe
    extends FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get account => 'Account';

  @override
  String get userNotAutenticated => 'Benutzer nicht authentifiziert';

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
      'If you change Encryption Passphrase you\'ll not able to access data encrypted with this passphrase.\n\nAre you sure to change Encryption Passphrase';

  @override
  String get areYouSureToImportEncryptionSecretKey =>
      'If you import a Encryption Secret Key, old key is overidden and data encrypted with old key will be lost.\n\nAre you sure import Encryption Secret Key?';

  @override
  String get encryptionSecretKeyImported => 'Encryption Secret Key imported';

  @override
  String get encryptionPassphrase => 'Encryption Passphrase';

  @override
  String get encryptionSecretKey => 'Encryption Secret Key';

  @override
  String get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase =>
      'Scan QR code into another device or store in a secure place.\nThe QR code is encrypted with the Encryptrion Passphrase.\nYou must set the same Encryptrion Passphrase into the new device';
}
