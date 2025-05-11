// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class FlutterHeyteacherUtilsLocalizationsIt extends FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizationsIt([String locale = 'it']) : super(locale);

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
  String get support => 'Supporto';

  @override
  String get askSupportFor => 'Chiedi supporto per: ';
}
