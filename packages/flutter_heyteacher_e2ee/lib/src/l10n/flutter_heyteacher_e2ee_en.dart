// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_e2ee.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class FlutterHeyteacherE2EELocalizationsEn
    extends FlutterHeyteacherE2EELocalizations {
  FlutterHeyteacherE2EELocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get encryptionPassphraseIsEmptySetIt =>
      'Encryption Passphrase is empty, set it';

  @override
  String get missingEncryptionSecretKeyImportIt =>
      'Missing Encryption Key, import it';

  @override
  String get errorOnEncryptionCheckPassphrase =>
      'Error on encryption, check the Encryption Passphrase';

  @override
  String get errorOnDecryptionCheckPassphrase =>
      'Error on decryption, check the Encryption Passphrase';

  @override
  String get areYouSureToChangeEncryptionPassphrase =>
      'If you change the Encryption Passphrase, you will not be able to access data encrypted with the old passphrase.\n\nAre you sure you want to change the Encryption Passphrase?';

  @override
  String get areYouSureToImportEncryptionSecretKey =>
      'If you import an Encryption Key, the old key will be overridden and data encrypted with the old key will be lost.\n\nAre you sure you want to import the Encryption Key?';

  @override
  String get encryptionSecretKeyImported => 'Encryption Key imported';

  @override
  String get encryptionPassphrase => 'Passphrase';

  @override
  String get encryptionSecretKey => 'Encryption Key';

  @override
  String
  get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase =>
      'Scan the QR code with another device or store it in a secure place.\nThe QR code is encrypted with the Encryption Passphrase.\nYou must set the same Encryption Passphrase on the new device.';

  @override
  String get missingMasterSecretKeyJwk =>
      'Missing Master Secret Key JWK, E2EE not initialized';

  @override
  String get show => 'Show';

  @override
  String get scan => 'Scan';

  @override
  String get edit => 'Edit';
}
