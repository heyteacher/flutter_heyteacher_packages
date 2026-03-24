// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_e2ee.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class FlutterHeyteacherE2EELocalizationsFr
    extends FlutterHeyteacherE2EELocalizations {
  FlutterHeyteacherE2EELocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get encryptionPassphraseIsEmptySetIt =>
      'La Phrase Cryptographique de chiffrement est vide, définissez-la';

  @override
  String get missingEncryptionSecretKeyImportIt =>
      'Clé Cryptographique de chiffrement manquante, importez-la';

  @override
  String get errorOnEncryptionCheckPassphrase =>
      'Erreur de chiffrement, vérifiez la Phrase Cryptographique';

  @override
  String get errorOnDecryptionCheckPassphrase =>
      'Erreur de déchiffrement, vérifiez la Phrase Cryptographique';

  @override
  String get areYouSureToChangeEncryptionPassphrase =>
      'Si vous modifiez la Phrase Cryptographique, vous ne pourrez plus accéder aux données chiffrées avec l\'ancienne phrase secrète.\n\nÊtes-vous sûr de vouloir modifier la Phrase Cryptographique?';

  @override
  String get areYouSureToImportEncryptionSecretKey =>
      'Si vous importez une Clé Cryptographique, l\'ancienne clé sera écrasée et les données chiffrées avec l\'ancienne clé seront perdues.\n\nÊtes-vous sûr de vouloir importer la Clé Cryptographique?';

  @override
  String get encryptionSecretKeyImported => 'Clé Cryptographique importée';

  @override
  String get encryptionPassphrase => 'Mot de passe';

  @override
  String get encryptionSecretKey => 'Clé Cryptographique';

  @override
  String
  get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase =>
      'Scannez le code QR avec un autre appareil ou stockez-le dans un endroit sécurisé.\nLe code QR est chiffré avec la Cryptographique.\nVous devez définir la même Cryptographique sur le nouvel appareil.';

  @override
  String get missingMasterSecretKeyJwk =>
      'Clé secrète maître JWK manquante, E2EE non initialisé';
}
