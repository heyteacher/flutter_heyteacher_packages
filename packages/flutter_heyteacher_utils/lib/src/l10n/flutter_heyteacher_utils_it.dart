// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class FlutterHeyteacherUtilsLocalizationsIt extends FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get account => 'Account';

  @override
  String get userNotAutenticated => 'Utente non autenticato';

  @override
  String get notAuthenticated => 'Non Autenticato';

  @override
  String get errorOnRetrieveData => 'errore durante il caricamento dei dati';

  @override
  String get timeoutOnRetrieveData => 'Timeout durante in caricamento dei dati';

  @override
  String get confirm => 'Conferma';

  @override
  String get areYouSureToConfirmTheAction => 'Sei sicuro di confermare l\'azione?';

  @override
  String get encryptionPassphraseIsEmptySetIt => 'Password di Criptazione non valorizzata, impostala';

  @override
  String get missingEncryptionSecretKeyImportIt => 'Chiave Secreta di Criptazione non presente, importala';

  @override
  String get errorOnEncryptionCheckPassphrase => 'Errore durante la criptazione, controlla la Password di Criptazione';

  @override
  String get errorOnDecryptionCheckPassphrase => 'Errore durante la decriptazione, controlla la Password di Criptazione';

  @override
  String get id => 'Id: ';

  @override
  String get version => 'Versione: ';

  @override
  String get askSupport => 'Chiedi supporto';

  @override
  String get askSupportFor => 'Chiedi supporto per: ';

  @override
  String get logging => 'Registrazione';

  @override
  String nMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '$minutes minuto',
    );
    return '$_temp0';
  }

  @override
  String get areYouSureToChangeEncryptionPassphrase => 'If you change Encryption Passphrase you\'ll not able to access data encrypted with this passphrase.\n\nAre you sure to change Encryption Passphrase';

  @override
  String get areYouSureToImportEncryptionSecretKey => 'If you import a Encryption Secret Key, old key is overidden and data encrypted with old key will be lost.\n\nAre you sure import Encryption Secret Key?';

  @override
  String get encryptionSecretKeyImported => 'Encryption Secret Key imported';

  @override
  String get encryptionPassphrase => 'Encryption Passphrase';

  @override
  String get encryptionSecretKey => 'Encryption Secret Key';

  @override
  String get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase => 'Scan QR code into another device or store in a secure place.\nThe QR code is encrypted with the Encryptrion Passphrase.\nYou must set the same Encryptrion Passphrase into the new device';
}
