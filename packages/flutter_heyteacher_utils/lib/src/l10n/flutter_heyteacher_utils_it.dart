// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class FlutterHeyteacherUtilsLocalizationsIt
    extends FlutterHeyteacherUtilsLocalizations {
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
  String get areYouSureToConfirmTheAction =>
      'Sei sicuro di confermare l\'azione?';

  @override
  String get encryptionPassphraseIsEmptySetIt =>
      'Password di Criptazione non valorizzata, impostala';

  @override
  String get missingEncryptionSecretKeyImportIt =>
      'Chiave Secreta di Criptazione non presente, importala';

  @override
  String get errorOnEncryptionCheckPassphrase =>
      'Errore durante la criptazione, controlla la Password di Criptazione';

  @override
  String get errorOnDecryptionCheckPassphrase =>
      'Errore durante la decriptazione, controlla la Password di Criptazione';

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
  String get areYouSureToChangeEncryptionPassphrase =>
      'Sei sicuro di voler cambiare la password di criptazione?';

  @override
  String get areYouSureToImportEncryptionSecretKey =>
      'Sei sicuro di voler importare la chiave segreta di criptazione?';

  @override
  String get encryptionSecretKeyImported =>
      'Chiave segreta di criptazione importata';

  @override
  String get encryptionPassphrase => 'Password di Criptazione';

  @override
  String get encryptionSecretKey => 'Chiave Segreta di Criptazione';

  @override
  String get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase =>
      'Scansiona il codice QR con un altro dispositivo o conservalo in un luogo sicuro. Ricorda di usare la stessa password di criptazione.';

  @override
  String get errorWorkflowTaskAlreadyInitialized =>
      'Errore: il task del workflow è già stato inizializzato';
}
