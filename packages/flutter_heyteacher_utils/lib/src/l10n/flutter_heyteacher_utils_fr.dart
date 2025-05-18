// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class FlutterHeyteacherUtilsLocalizationsFr extends FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get account => 'Account';

  @override
  String get userNotAutenticated => 'Utilisateur non authentifié';

  @override
  String get notAuthenticated => 'Non Authentifié';

  @override
  String get errorOnRetrieveData => 'Erreur lors de la récupération des données';

  @override
  String get timeoutOnRetrieveData => 'Délai d\'attente dépassé lors de la récupération des données';

  @override
  String get confirm => 'Confirmer';

  @override
  String get areYouSureToConfirmTheAction => 'Êtes-vous sûr de vouloir confirmer l\'action ?';

  @override
  String get encryptionPassphraseIsEmptySetIt => 'La phrase de passe de chiffrement est vide, veuillez la définir';

  @override
  String get missingEncryptionSecretKeyImportIt => 'Clé secrète de chiffrement manquante, veuillez l\'importer';

  @override
  String get errorOnEncryptionCheckPassphrase => 'Erreur de chiffrement, vérifiez la phrase de passe de chiffrement';

  @override
  String get errorOnDecryptionCheckPassphrase => 'Erreur de déchiffrement, vérifiez la phrase de passe de chiffrement';

  @override
  String get id => 'Id : ';

  @override
  String get version => 'Version : ';

  @override
  String get askSupport => 'Demander de l\'aide';

  @override
  String get askSupportFor => 'Demander de l\'aide pour : ';

  @override
  String get logging => 'Journalisation';

  @override
  String nMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '$minutes minute',
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
