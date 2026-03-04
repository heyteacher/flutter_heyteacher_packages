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
  String get notAuthenticated => 'Non authentifié';

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
  String get id => 'ID: ';

  @override
  String get version => 'Version: ';

  @override
  String get askSupport => 'Demander de l\'aide';

  @override
  String get askSupportFor => 'Demander de l\'aide pour : ';

  @override
  String get logging => 'Journalisation';

  @override
  String get loggingLevel => 'Niveau de journalisation';

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
  String get errorWorkflowTaskAlreadyInitialized =>
      'Tâche de workflow déjà initialisée';

  @override
  String get errorWorkflowNotInitialized => 'Workflow non initialisé';

  @override
  String get contentUnavailableOfflineRetryWhenOnline =>
      'Contenu indisponible hors ligne.\n\nRéessayez lorsque l\'appareil est connecté à internet.';

  @override
  String get deleteUserData =>
      'Planifier la suppression des données utilisateur';

  @override
  String doYouConfirmDeletionUserData(Object expireDateTime) {
    return 'Confirmez-vous la suppression de vos données utilisateur ?\nAttention ! Cette action ne peut pas être annulée avant le $expireDateTime.';
  }

  @override
  String get restoreUserData => 'Restaurer les données utilisateur';

  @override
  String doYouConfirmRestoringUserData(Object expireDateTime) {
    return 'Vous avez planifié la suppression de vos données utilisateur pour le $expireDateTime.\nConfirmez-vous l\'annulation de la suppression planifiée ?';
  }

  @override
  String get task => 'Tâche';

  @override
  String get description => 'Description';

  @override
  String get tasks => 'Tâches';

  @override
  String get skip => 'Passer';

  @override
  String get deviceOfflineAskSupportWhenOnline =>
      'Appareil hors ligne. Demandez de l\'aide lorsque l\'appareil est connecté à internet.';

  @override
  String defaultValue(Object defaultValue) {
    return 'Par défaut : $defaultValue';
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

  @override
  String nMinutes(num minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutesString minutes',
      one: '1 minute',
      zero: '0 minutes',
    );
    return '$_temp0';
  }

  @override
  String nHours(num hours) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);

    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hoursString heures',
      one: '1 heure',
      zero: '0 heure',
    );
    return '$_temp0';
  }
}
