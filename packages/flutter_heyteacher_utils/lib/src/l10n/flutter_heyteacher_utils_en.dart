// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class FlutterHeyteacherUtilsLocalizationsEn
    extends FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get account => 'Account';

  @override
  String get userNotAutenticated => 'User not autenticated';

  @override
  String get notAuthenticated => 'Not Authenticated';

  @override
  String get errorOnRetrieveData => 'Error on retrieve Data';

  @override
  String get timeoutOnRetrieveData => 'Timeout on retieve data';

  @override
  String get confirm => 'Confirm';

  @override
  String get areYouSureToConfirmTheAction =>
      'Are you sure to confirm the action?';

  @override
  String get encryptionPassphraseIsEmptySetIt =>
      'Encryption Passphrase is empty, set it';

  @override
  String get missingEncryptionSecretKeyImportIt =>
      'Missing Encryption Secret Key, import it';

  @override
  String get errorOnEncryptionCheckPassphrase =>
      'Error on encryption, check the Encryption Passphrase';

  @override
  String get errorOnDecryptionCheckPassphrase =>
      'Error on decryption, check the Encryption Passphrase';

  @override
  String get id => 'Id: ';

  @override
  String get version => 'Version: ';

  @override
  String get askSupport => 'Ask Support';

  @override
  String get askSupportFor => 'Ask support for: ';

  @override
  String get logging => 'Logging';

  @override
  String nMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: 'one minute',
    );
    return '$_temp0';
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
