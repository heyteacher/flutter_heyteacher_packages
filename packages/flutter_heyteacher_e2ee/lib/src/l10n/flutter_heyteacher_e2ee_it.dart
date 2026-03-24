// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_e2ee.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class FlutterHeyteacherE2EELocalizationsIt
    extends FlutterHeyteacherE2EELocalizations {
  FlutterHeyteacherE2EELocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get encryptionPassphraseIsEmptySetIt =>
      'La password di crittografia è vuota, impostala';

  @override
  String get missingEncryptionSecretKeyImportIt =>
      'Chiave Crittografica mancante, importala';

  @override
  String get errorOnEncryptionCheckPassphrase =>
      'Errore di crittografia, controlla la password di crittografia';

  @override
  String get errorOnDecryptionCheckPassphrase =>
      'Errore di decrittografia, controlla la password di crittografia';

  @override
  String get areYouSureToChangeEncryptionPassphrase =>
      'Se modifichi la password crittografica, non potrai più accedere ai dati crittografati con la vecchia passphrase.\n\nSei sicuro di voler modificare la password crittografica?';

  @override
  String get areYouSureToImportEncryptionSecretKey =>
      'Se importi una chiave crittografica, la vecchia chiave verrà sovrascritta e i dati crittografati con la vecchia chiave andranno persi.\n\nSei sicuro di voler importare la chiave crittografica?';

  @override
  String get encryptionSecretKeyImported => 'Chiave crittografica importata';

  @override
  String get encryptionPassphrase => 'Password';

  @override
  String get encryptionSecretKey => 'Chiave Crittografica';

  @override
  String
  get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase =>
      'Scansiona il codice QR con un altro dispositivo o conservalo in un luogo sicuro.\nIl codice QR è crittografato con la password crittografica.\nDevi impostare la stessa password crittografica sul nuovo dispositivo.';

  @override
  String get missingMasterSecretKeyJwk =>
      'Master Secret Key JWK mancante, E2EE non inizializzato';
}
