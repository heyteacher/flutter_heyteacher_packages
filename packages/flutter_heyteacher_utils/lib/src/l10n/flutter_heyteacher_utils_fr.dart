// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class FlutterHeyteacherUtilsLocalizationsFr
    extends FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get account => 'Compte';

  @override
  String get userNotAuthenticated => 'Utilisateur non authentifié';

  @override
  String get notAuthenticated => 'Non Authentifié';

  @override
  String get errorOnRetrieveData =>
      'Erreur lors de la récupération des données';

  @override
  String get timeoutOnRetrieveData =>
      'Délai d\'attente dépassé lors de la récupération des données';

  @override
  String get confirm => 'Confirmer';

  @override
  String get areYouSureToConfirmTheAction =>
      'Êtes-vous sûr de vouloir confirmer l\'action ?';

  @override
  String get encryptionPassphraseIsEmptySetIt =>
      'La phrase de passe de chiffrement est vide, veuillez la définir';

  @override
  String get missingEncryptionSecretKeyImportIt =>
      'Clé secrète de chiffrement manquante, veuillez l\'importer';

  @override
  String get errorOnEncryptionCheckPassphrase =>
      'Erreur de chiffrement, vérifiez la phrase de passe de chiffrement';

  @override
  String get errorOnDecryptionCheckPassphrase =>
      'Erreur de déchiffrement, vérifiez la phrase de passe de chiffrement';

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
  String get loggingLevel => 'Niveau de journalisation';

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
  String get areYouSureToChangeEncryptionPassphrase =>
      'Êtes-vous sûr de vouloir changer la phrase de passe de chiffrement ?';

  @override
  String get areYouSureToImportEncryptionSecretKey =>
      'Êtes-vous sûr de vouloir importer la clé secrète de chiffrement ?';

  @override
  String get encryptionSecretKeyImported =>
      'Clé secrète de chiffrement importée';

  @override
  String get encryptionPassphrase => 'Phrase de passe de chiffrement';

  @override
  String get encryptionSecretKey => 'Clé secrète de chiffrement';

  @override
  String
  get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase =>
      'Scannez le code QR avec un autre appareil ou stockez-le dans un endroit sûr. N\'oubliez pas d\'utiliser la même phrase de passe.';

  @override
  String get errorWorkflowTaskAlreadyInitialized =>
      'La tâche du flux de travail a déjà été initialisée';

  @override
  String get errorWorkflowNotInitialized => 'Workflow non initialisé';

  @override
  String get contentUnavailableOfflineRetryWhenOnline =>
      'Contenu indisponible hors ligne.\\n\\nVeuillez réessayer lorsque vous êtes connecté à Internet.';

  @override
  String get deleteUserData => 'Supprimer les données utilisateur';

  @override
  String get doYouConfirmDeletionUserData =>
      'Confirmez-vous la suppression des données utilisateur ?';

  @override
  String get task => 'Tâche';

  @override
  String get description => 'Description';

  @override
  String get tasks => 'Tâches';

  @override
  String get skip => 'Sauter';

  @override
  String get deviceOfflineAskSupportWhenOnline =>
      'Appareil hors ligne. Demandez de l\'aide lorsque l\'appareil est connecté à Internet.';

  @override
  String defaultValue(Object defaultValue) {
    return 'Valeur par défaut : $defaultValue';
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
  String get search => 'Rechercher';

  @override
  String get enableLogsStorage => 'Activer le stockage des journaux';
}
