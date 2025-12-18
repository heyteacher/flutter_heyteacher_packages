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
  String get userNotAuthenticated => 'Utente non autenticato';

  @override
  String get notAuthenticated => 'Non autenticato';

  @override
  String get errorOnRetrieveData => 'Errore nel recupero dei dati';

  @override
  String get timeoutOnRetrieveData => 'Timeout nel recupero dei dati';

  @override
  String get confirm => 'Conferma';

  @override
  String get areYouSureToConfirmTheAction =>
      'Sei sicuro di voler confermare l\'azione?';

  @override
  String get encryptionPassphraseIsEmptySetIt =>
      'La passphrase di crittografia è vuota, impostala';

  @override
  String get missingEncryptionSecretKeyImportIt =>
      'Chiave segreta di crittografia mancante, importala';

  @override
  String get errorOnEncryptionCheckPassphrase =>
      'Errore di crittografia, controlla la passphrase di crittografia';

  @override
  String get errorOnDecryptionCheckPassphrase =>
      'Errore di decrittografia, controlla la passphrase di crittografia';

  @override
  String get id => 'ID: ';

  @override
  String get version => 'Versione: ';

  @override
  String get askSupport => 'Chiedi supporto';

  @override
  String get askSupportFor => 'Chiedi supporto per: ';

  @override
  String get logging => 'Registrazione';

  @override
  String get loggingLevel => 'Livello di registrazione';

  @override
  String nMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minuti',
      one: 'un minuto',
    );
    return '$_temp0';
  }

  @override
  String get areYouSureToChangeEncryptionPassphrase =>
      'Se modifichi la passphrase di crittografia, non potrai più accedere ai dati crittografati con la vecchia passphrase.\n\nSei sicuro di voler modificare la passphrase di crittografia?';

  @override
  String get areYouSureToImportEncryptionSecretKey =>
      'Se importi una chiave segreta di crittografia, la vecchia chiave verrà sovrascritta e i dati crittografati con la vecchia chiave andranno persi.\n\nSei sicuro di voler importare la chiave segreta di crittografia?';

  @override
  String get encryptionSecretKeyImported =>
      'Chiave segreta di crittografia importata';

  @override
  String get encryptionPassphrase => 'Passphrase di crittografia';

  @override
  String get encryptionSecretKey => 'Chiave segreta di crittografia';

  @override
  String
  get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase =>
      'Scansiona il codice QR con un altro dispositivo o conservalo in un luogo sicuro.\nIl codice QR è crittografato con la passphrase di crittografia.\nDevi impostare la stessa passphrase di crittografia sul nuovo dispositivo.';

  @override
  String get errorWorkflowTaskAlreadyInitialized =>
      'Attività del flusso di lavoro già inizializzata';

  @override
  String get errorWorkflowNotInitialized =>
      'Flusso di lavoro non inizializzato';

  @override
  String get contentUnavailableOfflineRetryWhenOnline =>
      'Contenuto non disponibile offline.\n\nRiprova quando il dispositivo è connesso a internet.';

  @override
  String get deleteUserData => 'Pianifica eliminazione dati utente';

  @override
  String doYouConfirmDeletionUserData(Object expireDateTime) {
    return 'Confermi l\'eliminazione dei tuoi dati utente?\nAttenzione! Questa azione non può essere annullata fino a dopo $expireDateTime.';
  }

  @override
  String get restoreUserData => 'Ripristina dati utente';

  @override
  String doYouConfirmRestoringUserData(Object expireDateTime) {
    return 'Hai pianificato l\'eliminazione dei tuoi dati utente per il $expireDateTime.\nConfermi di voler annullare l\'eliminazione pianificata?';
  }

  @override
  String get task => 'Attività';

  @override
  String get description => 'Descrizione';

  @override
  String get tasks => 'Attività';

  @override
  String get skip => 'Salta';

  @override
  String get deviceOfflineAskSupportWhenOnline =>
      'Dispositivo offline. Chiedi supporto quando il dispositivo è connesso a internet.';

  @override
  String defaultValue(Object defaultValue) {
    return 'Predefinito: $defaultValue';
  }

  @override
  String nSeconds(num nSeconds) {
    String _temp0 = intl.Intl.pluralLogic(
      nSeconds,
      locale: localeName,
      other: '$nSeconds sec',
      one: '1 sec',
      zero: '0 sec',
    );
    return '$_temp0';
  }

  @override
  String get search => 'Cerca';

  @override
  String get enableLogsStorage => 'Abilita archiviazione log';
}
