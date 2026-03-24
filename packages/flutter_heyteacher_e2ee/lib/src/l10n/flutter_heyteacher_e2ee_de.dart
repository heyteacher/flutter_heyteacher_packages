// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_e2ee.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class FlutterHeyteacherE2EELocalizationsDe
    extends FlutterHeyteacherE2EELocalizations {
  FlutterHeyteacherE2EELocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get encryptionPassphraseIsEmptySetIt =>
      'Verschlüsselungspassphrase ist leer, bitte festlegen';

  @override
  String get missingEncryptionSecretKeyImportIt =>
      'Fehlender Kryptografischen Schlüssel, bitte importieren';

  @override
  String get errorOnEncryptionCheckPassphrase =>
      'Fehler bei der Verschlüsselung, überprüfen Sie die Verschlüsselungspassphrase';

  @override
  String get errorOnDecryptionCheckPassphrase =>
      'Fehler bei der Entschlüsselung, überprüfen Sie die Verschlüsselungspassphrase';

  @override
  String get areYouSureToChangeEncryptionPassphrase =>
      'Wenn Sie die Verschlüsselungspassphrase ändern, können Sie nicht mehr auf Daten zugreifen, die mit der alten Passphrase verschlüsselt wurden.\n\nMöchten Sie die Verschlüsselungspassphrase wirklich ändern?';

  @override
  String get areYouSureToImportEncryptionSecretKey =>
      'Wenn Sie einen Kryptografischen Schlüssel importieren, wird der alte Schlüssel überschrieben und mit dem alten Schlüssel verschlüsselte Daten gehen verloren.\n\nMöchten Sie den Kryptografischen Schlüssel wirklich importieren?';

  @override
  String get encryptionSecretKeyImported =>
      'Kryptografischen Schlüssel importiert';

  @override
  String get encryptionPassphrase => 'Passwort';

  @override
  String get encryptionSecretKey => 'Kryptografischen Schlüssel';

  @override
  String
  get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase =>
      'Scannen Sie den QR-Code mit einem anderen Gerät oder speichern Sie ihn an einem sicheren Ort.\nDer QR-Code ist mit der Verschlüsselungspassphrase verschlüsselt.\nSie müssen auf dem neuen Gerät dieselbe Verschlüsselungspassphrase festlegen.';

  @override
  String get missingMasterSecretKeyJwk =>
      'Fehlender Master Secret Key JWK, E2EE nicht initialisiert';
}
