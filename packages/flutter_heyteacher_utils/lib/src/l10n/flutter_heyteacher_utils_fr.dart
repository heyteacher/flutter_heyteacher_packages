// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class FlutterHeyteacherUtilsLocalizationsFr extends FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizationsFr([String locale = 'fr']) : super(locale);

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
}
